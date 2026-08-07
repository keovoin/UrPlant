/**
 * Anti-Spoofing Validation
 * 
 * Validates that uploaded images are real camera photos, not:
 * - Screenshots
 * - Downloaded images from internet
 * - Photos of a computer screen
 * - Gallery uploads (EXIF stripped on many Android devices)
 * 
 * Best-effort system — flagged scans still proceed but are marked for admin review.
 */

export interface ExifData {
  make?: string;
  model?: string;
  software?: string;
  date_time_original?: string;
  image_width?: number;
  image_height?: number;
  has_exif: boolean;
  source_type?: string;
}

export interface SpoofingResult {
  isFlagged: boolean;
  flags: string[];
  confidence: number; // 0 = definitely spoofed, 1 = definitely real
}

// Common screen resolutions that indicate a screenshot
const SCREEN_RESOLUTIONS = [
  { w: 1170, h: 2532 },  // iPhone 14/15 screen
  { w: 1080, h: 2400 },  // Common Android screen
  { w: 750, h: 1334 },   // iPhone 6/7/8/SE
  { w: 828, h: 1792 },   // iPhone 11/XR
  { w: 1125, h: 2436 },  // iPhone X/XS
  { w: 1284, h: 2778 },  // iPhone 12 Pro Max
  { w: 1179, h: 2556 },  // iPhone 15 Pro
  { w: 1440, h: 3200 },  // High-res Android
  { w: 1440, h: 3120 },  // Galaxy S series
];

// Software strings that indicate non-camera sources
const SUSPICIOUS_SOFTWARE = /screenshot|photoshop|gimp|preview|canva|lightroom|snapseed/i;

export function validateImage(exifData: ExifData): SpoofingResult {
  const flags: string[] = [];

  // 1. EXIF must exist — real camera photos always have EXIF
  if (!exifData.has_exif) {
    flags.push('no_exif');
  }

  // 2. Source type — must indicate camera
  if (exifData.source_type && exifData.source_type !== 'camera') {
    flags.push('non_camera_source');
  }

  // 3. Resolution check — must be reasonable camera resolution
  if (exifData.image_width && exifData.image_height) {
    const megapixels = (exifData.image_width * exifData.image_height) / 1_000_000;
    if (megapixels < 2) {
      flags.push('low_resolution');
    }

    // 4. Screen resolution match — screenshots often have exact screen dimensions
    const matchesScreen = SCREEN_RESOLUTIONS.some(
      (r) =>
        Math.abs(r.w - exifData.image_width!) < 5 &&
        Math.abs(r.h - exifData.image_height!) < 5
    );
    if (matchesScreen) {
      flags.push('screenshot_resolution');
    }
  }

  // 5. Suspicious software string
  if (exifData.software && SUSPICIOUS_SOFTWARE.test(exifData.software)) {
    flags.push('suspicious_software');
  }

  // Flag if 2+ red flags (allows for one-off issues like EXIF stripping on some Android devices)
  const isFlagged = flags.length >= 2;
  const confidence = flags.length === 0 ? 0.95
    : flags.length === 1 ? 0.7
    : flags.length === 2 ? 0.4
    : 0.2;

  console.log(`[Anti-Spoofing] Flags: [${flags.join(', ')}], Flagged: ${isFlagged}, Confidence: ${confidence}`);

  return { isFlagged, flags, confidence };
}