
import '../sync_supabase.dart';
class SyncEngine {
  final TableStorage localStorage;
  final IRemoteClient remoteClient;

  SyncEngine({required this.localStorage, required this.remoteClient});

  /// Pull: Supabase se latest data lao aur local mein save karo
  Future<void> pullFromRemote() async {
    final remoteRecords = await remoteClient.fetchAll();

    for (var record in remoteRecords) {
      final localRecord = localStorage.get(record.id);

      if (localRecord == null) {
        // Naya record, seedha save karo
        await localStorage.save(record);
      } else if (!localRecord.isSynced &&
          record.updatedAt.isAfter(localRecord.updatedAt)) {
        // CONFLICT: local mein unsynced changes hain, lekin remote bhi newer hai
        print('⚠️ Conflict detected for id: ${record.id}');
        print('   Local (unsynced): ${localRecord.data}');
        print('   Remote (newer): ${record.data}');
        // Simple strategy for now: remote wins (v1)
        await localStorage.save(record);
      } else if (localRecord.isSynced &&
          record.updatedAt.isAfter(localRecord.updatedAt)) {
        // Normal update, no conflict
        await localStorage.save(record);
      }
    }
  }

  /// Push: Local pending changes Supabase pe bhejo
  Future<void> pushToRemote() async {
    final pending = localStorage.getPendingSync();
    final List<String> failedIds = [];

    for (var record in pending) {
      try {
        if (record.isDeleted) {
          await remoteClient.deleteRecord(record.id);
          await localStorage.delete(record.id); // local se bhi hata do
        } else {
          await remoteClient.pushRecord(record);
          final synced = SyncRecord(
            id: record.id,
            data: record.data,
            updatedAt: record.updatedAt,
            isSynced: true,
          );
          await localStorage.save(synced);
        }
      } catch (e) {
        print('⚠️ Failed to sync record ${record.id}: $e');
      }
    }
    if (failedIds.isNotEmpty) {
      print('❌ ${failedIds.length} record(s) failed to sync: $failedIds');
    }
  }

  /// Full sync: pehle push karo (local changes bhejo), phir pull karo (latest lao)
  Future<void> fullSync() async {
    await pushToRemote();
    await pullFromRemote();
  }
}
