import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class ScanRecord {
  final String id;
  final DateTime timestamp;
  final String? plantName;
  final String? plantDataJson;
  final String matchStatus;
  final int xpEarned;

  ScanRecord({
    required this.id,
    required this.timestamp,
    this.plantName,
    this.plantDataJson,
    required this.matchStatus,
    this.xpEarned = 0,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'timestamp': timestamp.toIso8601String(),
        'plant_name': plantName,
        'plant_data_json': plantDataJson,
        'match_status': matchStatus,
        'xp_earned': xpEarned,
      };

  factory ScanRecord.fromJson(Map<String, dynamic> json) => ScanRecord(
        id: json['id'] ?? '',
        timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
        plantName: json['plant_name'],
        plantDataJson: json['plant_data_json'],
        matchStatus: json['match_status'] ?? 'unmatched',
        xpEarned: json['xp_earned'] ?? 0,
      );
}

class LocalHistoryStore {
  static const _key = 'scan_history';

  static Future<void> saveScan(ScanRecord record) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getAllScans();

    // Insert at beginning (newest first), deduplicate by id
    list.removeWhere((r) => r.id == record.id);
    list.insert(0, record);

    // Keep last 100 scans max
    if (list.length > 100) list.removeRange(100, list.length);

    final encoded = jsonEncode(list.map((r) => r.toJson()).toList());
    await prefs.setString(_key, encoded);
  }

  static Future<List<ScanRecord>> getAllScans() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return [];

    try {
      final list = jsonDecode(raw) as List;
      return list.map((e) => ScanRecord.fromJson(e as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}