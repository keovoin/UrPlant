/**
 * Plant Safety Analyzer
 *
 * Second AI pass to determine if an identified plant is:
 * - Poisonous / toxic
 * - Edible
 * - Medicinal
 * - Invasive
 *
 * Results are cached per species_name_lower in Firestore to avoid repeated AI costs.
 */

import axios from 'axios';
import * as admin from 'firebase-admin';

export interface SafetyInfo {
  poisonous: boolean;
  edible: boolean;
  medicinal: boolean;
  invasive: boolean;
  warning: string | null;
  verified_at?: any;
}

const SAFETY_PROMPT = `You are a plant toxicologist. Given the plant below, determine ONLY the safety properties.
Respond with ONLY valid JSON, no markdown, no explanation:

{
  "poisonous": true or false,
  "edible": true or false,
  "medicinal": true or false,
  "invasive": true or false,
  "warning": "Short safety warning if poisonous/toxic, or null if safe. Max 100 chars."
}

Plant: {plant_name}
Scientific name: {scientific_name}
Confidence: {confidence}`;

const db = admin.firestore();

export async function analyzeSafety(
  plantName: string,
  scientificName: string,
  confidence: number
): Promise<SafetyInfo> {
  const speciesLower = scientificName.trim().toLowerCase();

  // Check cache first
  const cacheDoc = await db.collection('plant_safety').doc(speciesLower).get();
  if (cacheDoc.exists) {
    console.log(`[Safety] Cache hit for: ${scientificName}`);
    return cacheDoc.data() as SafetyInfo;
  }

  console.log(`[Safety] Analyzing: ${scientificName}`);

  const aiUrl = process.env.SELF_HOSTED_AI_URL || 'https://airouter-kh.fly.dev/v1/chat/completions';
  const aiKey = process.env.SELF_HOSTED_AI_KEY || '';
  const aiModel = process.env.SELF_HOSTED_AI_MODEL || 'deepseek-chat';

  if (!aiUrl || !aiKey) {
    console.warn('[Safety] AI gateway not configured — returning safe defaults');
    return { poisonous: false, edible: false, medicinal: false, invasive: false, warning: null };
  }

  try {
    const prompt = SAFETY_PROMPT
      .replace('{plant_name}', plantName)
      .replace('{scientific_name}', scientificName)
      .replace('{confidence}', String(confidence));

    const response = await axios.post(
      aiUrl,
      {
        model: aiModel,
        messages: [
          { role: 'system', content: 'You are a plant toxicologist. You respond only with valid JSON.' },
          { role: 'user', content: prompt },
        ],
        temperature: 0.1,
        max_tokens: 300,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${aiKey}`,
        },
        timeout: 20000,
      }
    );

    const content = response.data?.choices?.[0]?.message?.content || '';
    let parsed: SafetyInfo;

    try {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      parsed = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(content);
    } catch {
      return { poisonous: false, edible: false, medicinal: false, invasive: false, warning: 'Safety data unavailable.' };
    }

    const result: SafetyInfo = {
      poisonous: parsed.poisonous === true,
      edible: parsed.edible === true,
      medicinal: parsed.medicinal === true,
      invasive: parsed.invasive === true,
      warning: parsed.warning || null,
      verified_at: admin.firestore.FieldValue.serverTimestamp(),
    };

    // Cache the result
    await db.collection('plant_safety').doc(speciesLower).set(result);

    console.log(`[Safety] Result for ${scientificName}: poisonous=${result.poisonous}, edible=${result.edible}, medicinal=${result.medicinal}, invasive=${result.invasive}`);
    return result;
  } catch (error: any) {
    console.error('[Safety] Analysis failed:', error.message);
    return { poisonous: false, edible: false, medicinal: false, invasive: false, warning: null };
  }
}