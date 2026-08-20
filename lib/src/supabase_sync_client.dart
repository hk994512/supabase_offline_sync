


import '../sync_supabase.dart';
class SupabaseSyncClient implements IRemoteClient {
  final SupabaseClient client;
  final String tableName;

  SupabaseSyncClient({required this.client, required this.tableName});

  @override
  Future<List<SyncRecord>> fetchAll() async {
    final response = await client.from(tableName).select();
    return (response as List)
        .map(
          (row) => SyncRecord(
            id: row['id'].toString(),
            data: Map<String, dynamic>.from(row),
            updatedAt: DateTime.parse(row['updated_at']),
            isSynced: true,
          ),
        )
        .toList();
  }

  @override
  Future<void> pushRecord(SyncRecord record) async {
    await client.from(tableName).upsert(record.data);
  }

  @override
  Future<void> deleteRecord(String id) async {
    await client.from(tableName).delete().eq('id', id);
  }
}
