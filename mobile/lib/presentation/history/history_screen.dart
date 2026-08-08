import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/services/local_history_store.dart';
import '../plant_detail/plant_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({super.key});

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  List<ScanRecord> _scans = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final scans = await LocalHistoryStore.getAllScans();
    if (mounted) setState(() { _scans = scans; _loading = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('History')),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _scans.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.photo_camera_outlined, size: 64,
                          color: UrPlantTheme.textTertiary.withValues(alpha: 0.3)),
                      const SizedBox(height: 12),
                      const Text('No scans yet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500,
                              color: UrPlantTheme.textSecondary)),
                      const SizedBox(height: 4),
                      Text('Take a photo to start your history',
                          style: TextStyle(fontSize: 13, color: UrPlantTheme.textTertiary)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _scans.length,
                  itemBuilder: (context, i) {
                    final scan = _scans[i];
                    final plantData = scan.plantDataJson != null
                        ? Map<String, dynamic>.from(
                            // safe parse; fall back gracefully
                            _tryParse(scan.plantDataJson!) ?? {})
                        : <String, dynamic>{};
                    final name = plantData['name_en'] ?? scan.plantName ?? 'Unknown Plant';
                    final statusColor = _statusColor(scan.matchStatus);
                    final statusLabel = _statusLabel(scan.matchStatus);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      child: ListTile(
                        leading: Container(
                          width: 44, height: 44,
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(_statusIcon(scan.matchStatus),
                              color: statusColor, size: 22),
                        ),
                        title: Text(name,
                            style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
                        subtitle: Text(
                          '${_formatDate(scan.timestamp)}  •  ${scan.xpEarned > 0 ? '+${scan.xpEarned} XP' : statusLabel}',
                          style: const TextStyle(fontSize: 12, color: UrPlantTheme.textTertiary),
                        ),
                        trailing: const Icon(Icons.chevron_right, color: UrPlantTheme.textTertiary),
                        onTap: () {
                          if (plantData.isNotEmpty) {
                            Navigator.push(context, MaterialPageRoute(
                              builder: (_) => PlantDetailScreen(
                                plantId: plantData['id'] ?? '',
                                plantData: plantData,
                              ),
                            ));
                          }
                        },
                      ),
                    );
                  },
                ),
    );
  }

  Map<String, dynamic>? _tryParse(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'matched': return UrPlantTheme.success;
      case 'unmatched': return UrPlantTheme.warning;
      default: return UrPlantTheme.textTertiary;
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'matched': return 'Identified';
      case 'unmatched': return 'Not in DB';
      default: return 'Unknown';
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'matched': return Icons.check_circle;
      case 'unmatched': return Icons.explore_outlined;
      default: return Icons.help_outline;
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}