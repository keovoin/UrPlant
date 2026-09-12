/**
 * enrichInfo Cloud Function
 * 
 * Async enrichment — called from identifyPlant to generate:
 * - English description, origin, characteristics, habitat, uses, care guide, fun facts
 * - Khmer translations of all content
 * 
 * Uses self-hosted AI gateway (DeepSeek/OpenAI-compatible endpoint).
 * Updates Firestore plant doc when complete.
 */

import * as functions from 'firebase-functions/v1';
import axios from 'axios';
import * as admin from 'firebase-admin';

const db = admin.firestore();

// ─── Enrichment Prompt ────────────────────────────────────────────
const ENRICHMENT_PROMPT = `You are a botanist assistant. Given the following plant information, generate:
1. A 2-3 sentence description in English (engaging, educational)
2. Native origin/region (where this plant naturally grows)
3. Physical characteristics (2-3 sentences — leaf shape, flower type, height, color, etc.)
4. Habitat (where this plant naturally grows — forests, meadows, wetlands, deserts, etc.)
5. Uses (common uses — ornamental, medicinal, culinary, timber, etc.; include warnings if applicable)
6. Care guide with 5 fields: water needs, sunlight, soil type, temperature range, humidity preference
7. 3 fun facts (interesting, surprising)
8. All of the above translated into Khmer (ភាសាខ្មែរ)

Plant: {plant_name}
Scientific name: {scientific_name}
Taxonomy: {taxonomy}
Confidence: {confidence}

Respond with ONLY valid JSON, no markdown, no explanation:
{
  "en": {
    "description": "...",
    "origin": "...",
    "characteristics": "...",
    "habitat": "...",
    "uses": "...",
    "care": {
      "water": "...",
      "sunlight": "...",
      "soil": "...",
      "temperature": "...",
      "humidity": "..."
    },
    "fun_facts": ["...", "...", "..."]
  },
  "kh": {
    "name": "ភាសាខ្មែរ common name (leave empty string if no standard Khmer name exists)",
    "description": "...",
    "origin": "...",
    "characteristics": "...",
    "habitat": "...",
    "uses": "...",
    "care": {
      "water": "...",
      "sunlight": "...",
      "soil": "...",
      "temperature": "...",
      "humidity": "..."
    },
    "fun_facts": ["...", "...", "..."]
  }
}`;

// ─── Cloud Function ──────────────────────────────────────────────
// Firestore-triggered: identifyPlant queues a doc in `enrich_requests`;
// this runs automatically when one appears, fills EN+KH content into the
// `plants` catalog doc, marks the request done, and removes the queue doc.
// (Previously an open https endpoint nobody called — the headline Khmer
// feature silently never ran.)
export const enrichInfo = functions
  .runWith({
    timeoutSeconds: 54,
    memory: '256MB',
  })
  .firestore.document('enrich_requests/{requestId}')
  .onWrite(async (change, context) => {
    const requestId = context.params.requestId;
    const after = change.after.exists ? change.after.data() : null;

    // Only process fresh pending requests (creation or re-queue update);
    // skip our own status writes to avoid loops.
    if (!after || after.status !== 'pending') return;
    if (change.before.exists && change.before.data()?.status === 'pending') return;

    const snap = change.after.ref;
    await snap.update({ status: 'enriching' }).catch(() => {});

    try {
      const { plant_id, plant_name, scientific_name, taxonomy, confidence } = after;

      if (!plant_id || !plant_name || !scientific_name) {
        console.warn(`[enrichInfo] ${requestId}: missing fields — removing`);
        await snap.delete().catch(() => {});
        return;
      }

      console.log(`[enrichInfo] Enriching plant: ${plant_name} (${plant_id})`);

      const aiUrl = process.env.SELF_HOSTED_AI_URL || 'https://airouter-kh.fly.dev/v1/chat/completions';
      const aiKey = process.env.SELF_HOSTED_AI_KEY || '';
      const aiModel = process.env.SELF_HOSTED_AI_MODEL || 'deepseek-chat';

      if (!aiUrl || !aiKey) {
        console.warn('[enrichInfo] AI gateway not configured — skipping enrichment');
        await snap.update({ status: 'skipped', reason: 'no_gateway' }).catch(() => {});
        return;
      }

      const prompt = ENRICHMENT_PROMPT
        .replace('{plant_name}', plant_name)
        .replace('{scientific_name}', scientific_name)
        .replace('{taxonomy}', JSON.stringify(taxonomy || {}))
        .replace('{confidence}', String(confidence || 0));

      const response = await axios.post(
        aiUrl,
        {
          model: aiModel,
          messages: [
            { role: 'system', content: 'You are a helpful botanist assistant. You respond only with valid JSON.' },
            { role: 'user', content: prompt },
          ],
          temperature: 0.7,
          max_tokens: 2500,
        },
        {
          headers: {
            'Content-Type': 'application/json',
            Authorization: `Bearer ${aiKey}`,
          },
          timeout: 30000,
        }
      );

      const content = response.data?.choices?.[0]?.message?.content || '';
      console.log(`[enrichInfo] AI response length: ${content.length}`);

      let enriched: any;
      try {
        const jsonMatch = content.match(/\{[\s\S]*\}/);
        enriched = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(content);
      } catch (parseErr) {
        console.error('[enrichInfo] Failed to parse AI response JSON:', content.substring(0, 200));
        await snap.update({ status: 'failed', reason: 'bad_json' }).catch(() => {});
        return;
      }

      const plantRef = db.collection('plants').doc(plant_id);
      const updateData: Record<string, any> = {
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      };

      if (enriched.en) {
        if (enriched.en.description) { updateData.description_en = enriched.en.description; updateData.description = enriched.en.description; }
        if (enriched.en.origin) { updateData.origin_en = enriched.en.origin; updateData.origin = enriched.en.origin; }
        if (enriched.en.characteristics) { updateData.characteristics_en = enriched.en.characteristics; updateData.characteristics = enriched.en.characteristics; }
        if (enriched.en.habitat) { updateData.habitat_en = enriched.en.habitat; updateData.habitat = enriched.en.habitat; }
        if (enriched.en.uses) { updateData.uses_en = enriched.en.uses; updateData.uses = enriched.en.uses; }
        if (enriched.en.care) { updateData.care_en = enriched.en.care; updateData.care = enriched.en.care; }
        if (enriched.en.fun_facts) { updateData.fun_facts_en = enriched.en.fun_facts; updateData.fun_facts = enriched.en.fun_facts; }
        if (enriched.en.common_name_kh) updateData.name_kh = enriched.en.common_name_kh;
      }

      // Also add Khmer common name to enrichment prompt expectations via kh block
      if (enriched.kh) {
        if (enriched.kh.description) updateData.description_kh = enriched.kh.description;
        if (enriched.kh.origin) updateData.origin_kh = enriched.kh.origin;
        if (enriched.kh.characteristics) updateData.characteristics_kh = enriched.kh.characteristics;
        if (enriched.kh.habitat) updateData.habitat_kh = enriched.kh.habitat;
        if (enriched.kh.uses) updateData.uses_kh = enriched.kh.uses;
        if (enriched.kh.care) updateData.care_kh = enriched.kh.care;
        if (enriched.kh.fun_facts) updateData.fun_facts_kh = enriched.kh.fun_facts;
        if (enriched.kh.name) updateData.name_kh = enriched.kh.name;
      }

      if (enriched.en) {
        const keywords = new Set<string>();
        if (plant_name) keywords.add(plant_name.toLowerCase());
        if (scientific_name) keywords.add(scientific_name.toLowerCase());
        if (updateData.name_kh) keywords.add(String(updateData.name_kh));
        if (enriched.en.origin) keywords.add(enriched.en.origin.toLowerCase());
        if (enriched.en.fun_facts) {
          for (const fact of enriched.en.fun_facts) {
            fact.split(' ').slice(0, 5).forEach((w: string) => keywords.add(w.toLowerCase()));
          }
        }
        updateData.search_keywords = Array.from(keywords).slice(0, 50);
      }

      await plantRef.update(updateData);
      console.log(`[enrichInfo] Successfully enriched plant: ${plant_name}`);

      // Done — remove queue doc (keeps collection small; Firestore trigger
      // onWrite sees delete and the guard `after==null` no-ops).
      await snap.delete().catch(() => {});
    } catch (error: any) {
      console.error('[enrichInfo] Error:', error.message);
      await snap.update({ status: 'failed', reason: String(error.message).slice(0, 200) }).catch(() => {});
    }
  });