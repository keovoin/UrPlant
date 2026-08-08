/**
 * AI Provider Abstraction Layer
 * 
 * Swappable AI for plant identification via process.env "AI_PROVIDER".
 * Options: "openai_vision_gateway" | "self_hosted_vlm" | "plantid"
 * 
 * All providers return a unified IdentificationResult.
 */

import axios from 'axios';

// ─── Unified Response Type ────────────────────────────────────────
export interface IdentificationResult {
  species: string;
  common_names: string[];
  confidence: number;
  characteristics: string;
  habitat: string;
  uses: string;
  taxonomy: {
    kingdom: string;
    family: string;
    genus: string;
    species: string;
  };
  raw_response: string;
  provider: string;
}

// ─── Env Helpers ──────────────────────────────────────────────────
const getEnv = (key: string, fallback = ''): string => {
  return process.env[key] || fallback;
};

// ─── Plant Identification Prompt ─────────────────────────────────
const PLANT_ID_PROMPT = `You are a plant identification expert. Identify this plant from the photo.
Respond ONLY with valid JSON, no markdown, no explanation:

{
  "scientific_name": "Genus species",
  "common_names": ["common name 1", "common name 2"],
  "confidence": 0.0 to 1.0,
  "characteristics": "2-3 sentences describing physical features, leaf shape, flower type, height, etc.",
  "habitat": "Where this plant naturally grows — forests, meadows, wetlands, deserts, etc.",
  "uses": "Common uses — ornamental, medicinal, culinary, timber, etc. Include warnings if applicable.",
  "taxonomy": {
    "kingdom": "Plantae",
    "family": "Family name",
    "genus": "Genus",
    "species": "species"
  }
}

If you cannot identify the plant, set confidence to 0 and use "Unknown" for names.`;

// ─── Provider 1: OpenAI-compatible Vision Gateway (airouter-kh.fly.dev) ──
async function identifyWithOpenAIVision(imageBase64: string): Promise<IdentificationResult> {
  const apiUrl = getEnv('OPENAI_VISION_URL', 'https://airouter-kh.fly.dev/v1/chat/completions');
  const apiKey = getEnv('OPENAI_VISION_KEY', '');
  const model = getEnv('OPENAI_VISION_MODEL', 'gpt-4o-mini');

  console.log(`[AI Provider] Calling OpenAI Vision Gateway at ${apiUrl} with model ${model}`);

  try {
    const response = await axios.post(
      apiUrl,
      {
        model,
        messages: [
          {
            role: 'user',
            content: [
              { type: 'text', text: PLANT_ID_PROMPT },
              {
                type: 'image_url',
                image_url: { url: `data:image/webp;base64,${imageBase64}` },
              },
            ],
          },
        ],
        max_tokens: 800,
        temperature: 0.2,
      },
      {
        headers: {
          'Content-Type': 'application/json',
          Authorization: `Bearer ${apiKey}`,
        },
        timeout: 30000,
      }
    );

    const content = response.data?.choices?.[0]?.message?.content || '';
    console.log(`[AI Provider] Vision gateway response length: ${content.length}`);

    let parsed: any;
    try {
      const jsonMatch = content.match(/\{[\s\S]*\}/);
      parsed = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(content);
    } catch {
      console.warn('[AI Provider] Failed to parse vision gateway JSON, returning low confidence');
      return {
        species: 'Unknown',
        common_names: [],
        confidence: 0,
        characteristics: '',
        habitat: '',
        uses: '',
        taxonomy: { kingdom: 'Plantae', family: '', genus: '', species: '' },
        raw_response: content,
        provider: 'openai_vision_gateway',
      };
    }

    return {
      species: parsed.scientific_name || 'Unknown',
      common_names: Array.isArray(parsed.common_names) ? parsed.common_names : [],
      confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0,
      characteristics: parsed.characteristics || '',
      habitat: parsed.habitat || '',
      uses: parsed.uses || '',
      taxonomy: {
        kingdom: parsed.taxonomy?.kingdom || 'Plantae',
        family: parsed.taxonomy?.family || '',
        genus: parsed.taxonomy?.genus || '',
        species: parsed.taxonomy?.species || '',
      },
      raw_response: JSON.stringify(parsed),
      provider: 'openai_vision_gateway',
    };
  } catch (error: any) {
    console.error('[AI Provider] Vision gateway call failed:', error.message);
    throw new Error(`Vision gateway unavailable: ${error.message}`);
  }
}

// ─── Provider 2: Self-Hosted VLM (Ollama + Qwen2-VL) ─────────────
async function identifyWithOllama(imageBase64: string): Promise<IdentificationResult> {
  const ollamaUrl = getEnv('OLLAMA_URL', 'http://localhost:11434');
  const model = getEnv('OLLAMA_MODEL', 'qwen2-vl:7b');

  console.log(`[AI Provider] Calling Ollama at ${ollamaUrl} with model ${model}`);

  try {
    const response = await axios.post(`${ollamaUrl}/api/generate`, {
      model,
      prompt: PLANT_ID_PROMPT,
      images: [imageBase64],
      stream: false,
      format: 'json',
    }, {
      timeout: 30000,
      headers: { 'Content-Type': 'application/json' },
    });

    const text = response.data?.response || '';
    console.log(`[AI Provider] Ollama raw response length: ${text.length}`);

    let parsed: any;
    try {
      const jsonMatch = text.match(/\{[\s\S]*\}/);
      parsed = jsonMatch ? JSON.parse(jsonMatch[0]) : JSON.parse(text);
    } catch {
      console.warn('[AI Provider] Failed to parse Ollama JSON, returning low confidence');
      return {
        species: 'Unknown',
        common_names: [],
        confidence: 0,
        characteristics: '',
        habitat: '',
        uses: '',
        taxonomy: { kingdom: 'Plantae', family: '', genus: '', species: '' },
        raw_response: text,
        provider: 'ollama_qwen2_vl',
      };
    }

    return {
      species: parsed.scientific_name || 'Unknown',
      common_names: Array.isArray(parsed.common_names) ? parsed.common_names : [],
      confidence: typeof parsed.confidence === 'number' ? parsed.confidence : 0,
      characteristics: parsed.characteristics || '',
      habitat: parsed.habitat || '',
      uses: parsed.uses || '',
      taxonomy: {
        kingdom: parsed.taxonomy?.kingdom || 'Plantae',
        family: parsed.taxonomy?.family || '',
        genus: parsed.taxonomy?.genus || '',
        species: parsed.taxonomy?.species || '',
      },
      raw_response: JSON.stringify(parsed),
      provider: 'ollama_qwen2_vl',
    };
  } catch (error: any) {
    console.error('[AI Provider] Ollama call failed:', error.message);
    throw new Error(`Ollama unavailable: ${error.message}`);
  }
}

// ─── Provider 3: Plant.id API (Production Upgrade) ───────────────
async function identifyWithPlantId(imageBase64: string): Promise<IdentificationResult> {
  const apiKey = getEnv('PLANT_ID_API_KEY');
  const apiUrl = getEnv('PLANT_ID_API_URL', 'https://api.plant.id/v3');

  if (!apiKey) {
    throw new Error('Plant.id API key not configured');
  }

  console.log('[AI Provider] Calling Plant.id API');

  try {
    const response = await axios.post(`${apiUrl}/identification`, {
      images: [`data:image/jpeg;base64,${imageBase64}`],
      similar_images: false,
      classification_level: 'species',
      details: ['common_names', 'taxonomy'],
    }, {
      headers: {
        'Api-Key': apiKey,
        'Content-Type': 'application/json',
      },
      timeout: 15000,
    });

    const suggestion = response.data?.suggestions?.[0];
    if (!suggestion) {
      return {
        species: 'Unknown',
        common_names: [],
        confidence: 0,
        characteristics: '',
        habitat: '',
        uses: '',
        taxonomy: { kingdom: 'Plantae', family: '', genus: '', species: '' },
        raw_response: JSON.stringify(response.data),
        provider: 'plantid_api',
      };
    }

    const taxonomy = suggestion.plant_details?.taxonomy || {};

    return {
      species: suggestion.plant_name || 'Unknown',
      common_names: suggestion.plant_details?.common_names || [],
      confidence: suggestion.probability || 0,
      characteristics: suggestion.plant_details?.structured_description?.characteristics || '',
      habitat: suggestion.plant_details?.structured_description?.habitat || '',
      uses: suggestion.plant_details?.structured_description?.uses || '',
      taxonomy: {
        kingdom: taxonomy.kingdom || 'Plantae',
        family: taxonomy.family || '',
        genus: taxonomy.genus || '',
        species: taxonomy.species || '',
      },
      raw_response: JSON.stringify(response.data),
      provider: 'plantid_api',
    };
  } catch (error: any) {
    console.error('[AI Provider] Plant.id call failed:', error.message);
    throw new Error(`Plant.id unavailable: ${error.message}`);
  }
}

// ─── Master Dispatcher ────────────────────────────────────────────
export async function identifyPlantImage(imageBase64: string): Promise<IdentificationResult> {
  const provider = getEnv('AI_PROVIDER', 'openai_vision_gateway');

  console.log(`[AI Provider] Using provider: ${provider}`);

  switch (provider) {
    case 'plantid':
      return identifyWithPlantId(imageBase64);

    case 'self_hosted_vlm':
      return identifyWithOllama(imageBase64);

    case 'openai_vision_gateway':
    default:
      return identifyWithOpenAIVision(imageBase64);
  }
}