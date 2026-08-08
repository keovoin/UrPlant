import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final size = 1024;
  final icon = img.Image(width: size, height: size);

  // Green gradient background
  for (var y = 0; y < size; y++) {
    for (var x = 0; x < size; x++) {
      final t = (x + y) / (size * 2);
      final r = (13 * (1 - t) + 46 * t).toInt();
      final g = (59 * (1 - t) + 175 * t).toInt();
      final b = (30 * (1 - t) + 80 * t).toInt();
      icon.setPixelRgba(x, y, r, g, b, 255);
    }
  }

  // White rounded rect in center
  final rectX1 = 250;
  final rectY1 = 250;
  final rectX2 = 774;
  final rectY2 = 774;
  final radius = 120;
  for (var y = rectY1; y < rectY2; y++) {
    for (var x = rectX1; x < rectX2; x++) {
      final dx = (x < 512 ? 512 - x : x - 512).abs();
      final dy = (y < 512 ? 512 - y : y - 512).abs();
      final cornerDist = (dx - (262 - radius)).clamp(0, 999) + (dy - (262 - radius)).clamp(0, 999);
      if (cornerDist <= radius || (x >= rectX1 + radius && x <= rectX2 - radius && y >= rectY1 + radius && y <= rectY2 - radius)) {
        icon.setPixelRgba(x, y, 255, 255, 255, 30);
      }
    }
  }

  // Leaf icon in center (simplified)
  final cx = 512;
  final cy = 512;

  // Draw a leaf-like shape using overlay
  for (var y = cy - 130; y < cy + 130; y++) {
    for (var x = cx - 60; x < cx + 60; x++) {
      final dx = ((x - cx) / 60.0).abs();
      final dy = ((y - cy) / 130.0).abs();
      if (dx * dx + dy * dy < 0.7) {
        icon.setPixelRgba(x, y, 255, 255, 255, 255);
      }
    }
    // Stem
    if (y >= cy && y <= cy + 80) {
      for (var x = cx - 6; x <= cx + 6; x++) {
        icon.setPixelRgba(x, y, 255, 255, 255, 255);
      }
    }
  }

  // Save
  final outputDir = Directory('assets/icons');
  if (!outputDir.existsSync()) outputDir.createSync(recursive: true);
  File('assets/icons/app_icon.png').writeAsBytesSync(img.encodePng(icon));

  // Generate Android mipmap sizes
  final androidSizes = {
    'mipmap-hdpi': 72,
    'mipmap-mdpi': 48,
    'mipmap-xhdpi': 96,
    'mipmap-xxhdpi': 144,
    'mipmap-xxxhdpi': 192,
  };

  for (final entry in androidSizes.entries) {
    final resized = img.copyResize(icon, width: entry.value, height: entry.value);
    final dir = Directory('android/app/src/main/res/${entry.key}');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    File('android/app/src/main/res/${entry.key}/ic_launcher.png')
        .writeAsBytesSync(img.encodePng(resized));
  }

  print('App icon generated successfully!');
}