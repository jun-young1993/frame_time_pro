import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/history_repository.dart';
import '../domain/conversion_record.dart';

// ──────────────────────────────────────────────
// State
// ──────────────────────────────────────────────

class HistoryState {
  const HistoryState({this.records = const []});

  final List<ConversionRecord> records;

  /// 검색어 기준 필터링 — 검색 쿼리는 UI 로컬 상태로 분리.
  List<ConversionRecord> filter(String query) {
    if (query.isEmpty) return records;
    final q = query.toLowerCase();
    return records
        .where(
          (r) =>
              r.inputValue.toLowerCase().contains(q) ||
              r.outputValue.toLowerCase().contains(q),
        )
        .toList();
  }

  HistoryState copyWith({List<ConversionRecord>? records}) =>
      HistoryState(records: records ?? this.records);
}

// ──────────────────────────────────────────────
// Notifier
// ──────────────────────────────────────────────

class HistoryNotifier extends StateNotifier<HistoryState> {
  HistoryNotifier(this._repo) : super(const HistoryState()) {
    _load();
  }

  final HistoryRepository _repo;

  void _load() => state = state.copyWith(records: _repo.getAll());

  Future<void> save(ConversionRecord record) async {
    await _repo.save(record);
    _load();
  }

  Future<void> delete(ConversionRecord record) async {
    await _repo.delete(record);
    _load();
  }

  Future<void> clear() async {
    await _repo.clear();
    _load();
  }
}

// ──────────────────────────────────────────────
// Providers
// ──────────────────────────────────────────────

final historyRepositoryProvider = Provider<HistoryRepository>(
  (_) => HistoryRepository(),
);

final historyProvider =
    StateNotifierProvider<HistoryNotifier, HistoryState>((ref) {
  return HistoryNotifier(ref.read(historyRepositoryProvider));
});
