import 'package:supabase/supabase.dart';
import 'package:sync_supabase/constants/secrets.dart';
import 'package:sync_supabase/src/supabase_sync_client.dart';

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
