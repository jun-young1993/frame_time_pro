import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../timecode_calculator/application/timecode_calculator_notifier.dart';
import '../../timecode_calculator/application/timecode_calculator_state.dart';
import '../../timecode_calculator/domain/timecode.dart';
import '../application/history_notifier.dart';
import '../domain/conversion_record.dart';

// ──────────────────────────────────────────────
// Screen
// ──────────────────────────────────────────────

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  final _searchController = TextEditingController();

  // 검색 쿼리를 UI 로컬 상태로 관리 — Riverpod 반응성과 독립적으로 동작
  String _query = '';

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onQueryChanged);
  }

  void _onQueryChanged() {
    final text = _searchController.text;
    if (text != _query) setState(() => _query = text);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onQueryChanged);
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(historyProvider);
    final notifier = ref.read(historyProvider.notifier);
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    // 검색 필터링: UI 로컬 _query 기준
    final items = state.filter(_query);

    return Scaffold(
      appBar: AppBar(
        title: const Text('History'),
        actions: [
          if (state.records.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.delete_sweep_outlined),
              tooltip: 'Clear all',
              onPressed: () => _confirmClear(context, notifier),
            ),
        ],
      ),
      body: Column(
        children: [
          _SearchBar(
            controller: _searchController,
            hasQuery: _query.isNotEmpty,
            onClear: () {
              _searchController.clear();
              // addListener가 처리하므로 setState 불필요
            },
          ),
          Expanded(
            child: _buildBody(
              items: items,
              allEmpty: state.records.isEmpty,
              query: _query,
              notifier: notifier,
              scheme: scheme,
              textTheme: textTheme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBody({
    required List<ConversionRecord> items,
    required bool allEmpty,
    required String query,
    required HistoryNotifier notifier,
    required ColorScheme scheme,
    required TextTheme textTheme,
  }) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          allEmpty ? 'No saved records yet.' : 'No results for "$query"',
          style: textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      itemCount: items.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _HistoryItem(
        record: items[i],
        onDelete: () => notifier.delete(items[i]),
        onLoad: () => _loadIntoCalculator(context, items[i]),
      ),
    );
  }

  void _loadIntoCalculator(BuildContext context, ConversionRecord record) {
    final notifier = ref.read(timecodeCalculatorProvider.notifier);

    // conversionType 라벨로 ConversionMode 복원, 미매칭 시 fallback
    final mode = ConversionMode.values.firstWhere(
      (m) => m.label == record.conversionType,
      orElse: () => ConversionMode.frameToTimecode,
    );
    notifier.setConversionMode(mode);

    if (mode.inputIsTimecode) {
      notifier.setInputSegments(
        _parseTimecodeSegments(record.inputValue),
        isCommit: true,
        shouldAnimateResult: true,
      );
    } else if (mode.inputIsFrame) {
      notifier.setFrameInput(record.inputValue);
    } else {
      notifier.setSecondInput(record.inputValue);
    }

    Navigator.of(context).pop();
  }

  /// "HH:MM:SS:FF" 또는 "HH:MM:SS;FF" 형식을 TimecodeSegments로 파싱.
  TimecodeSegments _parseTimecodeSegments(String value) {
    final parts = value.replaceAll(';', ':').split(':');
    if (parts.length == 4) {
      return TimecodeSegments(
        hh: parts[0].padLeft(2, '0'),
        mm: parts[1].padLeft(2, '0'),
        ss: parts[2].padLeft(2, '0'),
        ff: parts[3].padLeft(2, '0'),
      );
    }
    return TimecodeSegments.empty;
  }

  Future<void> _confirmClear(
    BuildContext context,
    HistoryNotifier notifier,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear all history?'),
        content: const Text('This cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
    if (confirmed == true) notifier.clear();
  }
}

// ──────────────────────────────────────────────
// Search Bar
// ──────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.hasQuery,
    required this.onClear,
  });

  final TextEditingController controller;
  final bool hasQuery;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          hintText: 'Search input or output…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: hasQuery
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: onClear,
                )
              : null,
          isDense: true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}

// ──────────────────────────────────────────────
// History Item
// ──────────────────────────────────────────────

class _HistoryItem extends StatelessWidget {
  const _HistoryItem({
    required this.record,
    required this.onDelete,
    required this.onLoad,
  });

  final ConversionRecord record;
  final VoidCallback onDelete;
  final VoidCallback onLoad;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── 헤더: 타입 칩 + 시각 + 로드 + 삭제 ──
            Row(
              children: [
                _TypeChip(
                  label: record.conversionType,
                  color: scheme.secondaryContainer,
                  textColor: scheme.onSecondaryContainer,
                ),
                const Spacer(),
                Text(
                  _formatTimestamp(record.timestamp),
                  style: textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(width: 4),
                GestureDetector(
                  onTap: onLoad,
                  child: Tooltip(
                    message: 'Load into calculator',
                    child: Icon(
                      Icons.upload_outlined,
                      size: 16,
                      color: scheme.primary,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                GestureDetector(
                  onTap: onDelete,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            // ── IN → OUT 값 ──
            Row(
              children: [
                Expanded(child: _ValueBox(label: 'IN', value: record.inputValue)),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Icon(
                    Icons.arrow_forward,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                ),
                Expanded(
                  child: _ValueBox(label: 'OUT', value: record.outputValue),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inHours < 1) return '${diff.inMinutes}m ago';
    if (diff.inDays < 1) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.year}-${_p2(dt.month)}-${_p2(dt.day)}';
  }

  String _p2(int v) => v.toString().padLeft(2, '0');
}

// ──────────────────────────────────────────────
// Sub-widgets
// ──────────────────────────────────────────────

class _TypeChip extends StatelessWidget {
  const _TypeChip({
    required this.label,
    required this.color,
    required this.textColor,
  });

  final String label;
  final Color color;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: textColor,
              fontWeight: FontWeight.w600,
            ),
      ),
    );
  }
}

class _ValueBox extends StatelessWidget {
  const _ValueBox({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: textTheme.labelSmall
                ?.copyWith(color: scheme.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: textTheme.bodyMedium?.copyWith(
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
