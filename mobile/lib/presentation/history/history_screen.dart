import 'dart:convert';
import 'package:flutter/material.dart';
import '../../config/theme.dart';
import '../../data/services/local_history_store.dart';
import '../../l10n/app_localizations.dart';
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
    final l = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: UrPlantTheme.canvas,
      appBar: AppBar(
        backgroundColor: UrPlantTheme.canvas,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        title: Text(l.history_title),
      ),
      body: RefreshIndicator(
        color: UrPlantTheme.primary,
        onRefresh: _load,
        child: _loading
            ? const Center(child: CircularProgressIndicator(color: UrPlantTheme.primary))
            : _scans.isEmpty
                ? ListView(children: [
                    const SizedBox(height: 140),
                    _empty(l),
                  ])
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 140),
                    itemCount: _scans.length,
                    itemBuilder: (context, i) {
                      final scan = _scans[i];
                      final plantData = scan.plantDataJson != null
                          ? Map<String, dynamic>.from(_tryParse(scan.plantDataJson!) ?? {})
                          : <String, dynamic>{};
                      final name = plantData['name_en'] ?? scan.plantName ?? '—';
                      final statusColor = _statusColor(scan.matchStatus);
                      final isNew = plantData['is_new_unlock'] == true;

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: StaggerIn(
                          index: (i % 8),
                          child: Material(
                            color: UrPlantTheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(18),
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
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(18),
                                  border: Border.all(color: UrPlantTheme.line, width: 1.5),
                                ),
                                child: Row(children: [
                                  Container(
                                    width: 46, height: 46,
                                    decoration: BoxDecoration(
                                      color: statusColor.withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(13),
                                    ),
                                    child: Icon(_statusIcon(scan.matchStatus),
                                        color: statusColor, size: 23),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(name, maxLines: 1, overflow: TextOverflow.ellipsis,
                                            style: const TextStyle(
                                                fontWeight: FontWeight.w800, fontSize: 15,
                                                color: UrPlantTheme.ink)),
                                        const SizedBox(height: 3),
                                        Row(children: [
                                          Text(_formatDate(scan.timestamp),
                                              style: const TextStyle(
                                                  fontSize: 12, color: UrPlantTheme.inkFaint,
                                                  fontWeight: FontWeight.w600)),
                                          const SizedBox(width: 8),
                                          if (scan.xpEarned > 0)
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1.5),
                                              decoration: BoxDecoration(
                                                color: const Color(0xFFFBEEDA),
                                                borderRadius: BorderRadius.circular(20),
                                              ),
                                              child: Text('+${scan.xpEarned} XP',
                                                  style: const TextStyle(
                                                      fontSize: 10.5, fontWeight: FontWeight.w900,
                                                      color: UrPlantTheme.goldEdge)),
                                            )
                                          else
                                            Text(_statusLabel(scan.matchStatus, l),
                                                style: const TextStyle(
                                                    fontSize: 11.5, color: UrPlantTheme.inkFaint,
                                                    fontWeight: FontWeight.w700)),
                                        ]),
                                      ],
                                    ),
                                  ),
                                  if (isNew)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        gradient: UrPlantTheme.leafGradient,
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(l.result_new_species_label,
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 10,
                                            fontWeight: FontWeight.w900)),
                                    )
                                  else
                                    const Icon(Icons.chevron_right_rounded,
                                        color: UrPlantTheme.inkFaint),
                                ]),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
      ),
    );
  }

  Widget _empty(AppLocalizations l) => Center(
    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
      Container(
        width: 74, height: 74,
        decoration: BoxDecoration(
            color: UrPlantTheme.primarySoft, shape: BoxShape.circle),
        child: const Icon(Icons.photo_camera_rounded, size: 34, color: UrPlantTheme.primaryDark),
      ),
      const SizedBox(height: 14),
      Text(l.history_empty_title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w900, color: UrPlantTheme.ink)),
      const SizedBox(height: 5),
      Text(l.history_empty_body,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 13, color: UrPlantTheme.inkFaint, height: 1.4)),
      const SizedBox(height: 16),
      const LeafDivider(width: 150),
    ]),
  );

  Map<String, dynamic>? _tryParse(String json) {
    try {
      final decoded = jsonDecode(json);
      if (decoded is Map) return Map<String, dynamic>.from(decoded);
      return null;
    } catch (_) {
      return null;
    }
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'matched': return UrPlantTheme.success;
      case 'unmatched': return UrPlantTheme.gold;
      default: return UrPlantTheme.inkFaint;
    }
  }

  String _statusLabel(String status, AppLocalizations l) {
    switch (status) {
      case 'matched': return l.history_status_matched;
      case 'unmatched': return l.history_status_new;
      default: return l.history_status_pending;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'matched': return Icons.verified_rounded;
      case 'unmatched': return Icons.auto_awesome_rounded;
      default: return Icons.help_outline_rounded;
    }
  }

  String _formatDate(DateTime dt) =>
      '${dt.year}-${dt.month.toString().padLeft(2, '0')}-${dt.day.toString().padLeft(2, '0')}';
}
