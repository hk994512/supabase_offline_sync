

import 'package:supabase_offline_sync/sync_supabase.dart';
final sInstance = SecretsApi.instance;

void main() async {
  final supabaseClient = SupabaseClient(
    sInstance.projectUrl,
    sInstance.publishableKey,
  );

  final client = SupabaseSyncClient(client: supabaseClient, tableName: 'notes');

  final records = await client.fetchAll();
  print('Fetched ${records.length} records');
  for (var r in records) {
    print(r.data);
  }
}
