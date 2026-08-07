/**
 * enrichInfo Cloud Function
 * 
 * Async enrichment — called from identifyPlant to generate:
 * - English description, origin, care guide, fun facts
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
3. Care guide with 5 fields: water needs, sunlight, soil type, temperature range, humidity preference
4. 3 fun facts (interesting, surprising)
5. All of the above translated into Khmer (ភាសាខ្មែរ)

Plant: {plant_name}
Scientific name: {scientific_name}
Taxonomy: {taxonomy}
Confidence: {confidence}

Respond with ONLY valid JSON, no markdown, no explanation:
{
  "en": {
    "description": "...",
    "origin": "...",
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
    "description": "...",
    "origin": "...",
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
export const enrichInfo = functions
  .runWith({
    timeoutSeconds: 45,
    memory: '256MB',
  })
  .https.onRequest(async (req, res) => {
    res.set('Access-Control-Allow-Origin', '*');

    if (req.method === 'OPTIONS') {
      res.status(204).send('');
      return;
    }

    if (req.method !== 'POST') {
      res.status(405).json({ error: 'method_not_allowed' });
      return;
    }

    try {
      const { plant_id, plant_name, scientific_name, taxonomy, confidence } = req.body;

      if (!plant_id || !plant_name || !scientific_name) {
        res.status(400).json({ error: 'Missing required fields' });
        return;
      }

      console.log(`[enrichInfo] Enriching plant: ${plant_name} (${plant_id})`);

      // Get AI gateway config (your airouter-kh.fly.dev endpoint)
      const aiUrl = process.env.SELF_HOSTED_AI_URL || 'https://airouter-kh.fly.dev/v1/chat/completions';
      const aiKey = process.env.SELF_HOSTED_AI_KEY || '';
      const aiModel = process.env.SELF_HOSTED_AI_MODEL || 'deepseek-chat';

      if (!aiUrl || !aiKey) {
        console.warn('[enrichInfo] AI gateway not configured — skipping enrichment');
        res.status(200).json({ status: 'skipped', reason: 'AI gateway not configured' });
        return;
      }

      // Build prompt
      const prompt = ENRICHMENT_PROMPT
        .replace('{plant_name}', plant_name)
        .replace('{scientific_name}', scientific_name)
        .replace('{taxonomy}', JSON.stringify(taxonomy || {}))
        .replace('{confidence}', String(confidence || 0));

      // Call AI gateway
      const response = await axios.post(
        aiUrl,
        {
          model: aiModel,
          messages: [
            {
              role: 'system',
              content: 'You are a helpful botanist assistant. You respond only with valid JSON.',
            },
            { role: 'user', content: prompt },
          ],
          temperature: 0.7,
          max_tokens: 2000,
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

      // Parse JSON from response
      let enriched: any;
      try {
        const jsonMatch = content.match(/\{[\s\S]*\}/);
        enriched = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(content);
      } catch (parseErr) {
        console.error('[enrichInfo] Failed to parse AI response JSON:', content.substring(0, 200));
        res.status(500).json({ error: 'Failed to parse enrichment response' });
        return;
      }

      // Update Firestore plant doc
      const plantRef = db.collection('plants').doc(plant_id);
      const updateData: Record<string, any> = {
        updated_at: admin.firestore.FieldValue.serverTimestamp(),
      };

      // English content
      if (enriched.en) {
        if (enriched.en.description) updateData.description_en = enriched.en.description;
        if (enriched.en.origin) updateData.origin_en = enriched.en.origin;
        if (enriched.en.care) updateData.care_en = enriched.en.care;
        if (enriched.en.fun_facts) updateData.fun_facts_en = enriched.en.fun_facts;
      }

      // Khmer content
      if (enriched.kh) {
        if (enriched.kh.description) updateData.description_kh = enriched.kh.description;
        if (enriched.kh.origin) updateData.origin_kh = enriched.kh.origin;
        if (enriched.kh.care) updateData.care_kh = enriched.kh.care;
        if (enriched.kh.fun_facts) updateData.fun_facts_kh = enriched.kh.fun_facts;
      }

      // Update search keywords
      if (enriched.en) {
        const keywords = new Set<string>();
        // Add plant name variations
        if (plant_name) keywords.add(plant_name.toLowerCase());
        if (scientific_name) keywords.add(scientific_name.toLowerCase());
        if (enriched.en.origin) keywords.add(enriched.en.origin.toLowerCase());
        if (enriched.en.fun_facts) {
          for (const fact of enriched.en.fun_facts) {
            fact.split(' ').slice(0, 5).forEach((w: string) => keywords.add(w.toLowerCase()));
          }
        }
        if (enriched.kh?.description) {
          enriched.kh.description.split(/[\s\u1780-\u17FF]+/).slice(0, 10).forEach((w: string) => {
            if (w.length > 1) keywords.add(w);
          });
        }
        updateData.search_keywords = Array.from(keywords).slice(0, 50);
      }

      await plantRef.update(updateData);
      console.log(`[enrichInfo] Successfully enriched plant: ${plant_name}`);

      res.status(200).json({ status: 'enriched', plant_id });
    } catch (error: any) {
      console.error('[enrichInfo] Error:', error.message);
      res.status(500).json({ error: 'Enrichment failed' });
    }
  });