import '../sync_supabase.dart';

class TableStorage {
  final Box box;
  TableStorage(this.box);

  Future<void> save(SyncRecord record) async {
    await box.put(record.id, record.toMap());
  }

  SyncRecord? get(String id) {
    final map = box.get(id);
    if (map == null) return null;
    return SyncRecord.fromMap(Map<String, dynamic>.from(map));
  }

  List<SyncRecord> getAll() {
    return box.values
        .map((e) => SyncRecord.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> delete(String id) async {
    await box.delete(id);
  }

  List<SyncRecord> getPendingSync() {
    return getAll().where((r) => !r.isSynced).toList();
  }
}
