

import 'package:sync_supabase/sync_supabase.dart';
final sInstance = SecretsApi.instance;

void main() async {
  Hive.init('./hive_data');
  Hive.init('./hive_data');
  final box = await Hive.openBox('notes');
  await box.clear();
  final localStorage = TableStorage(box);

  final supabaseClient = SupabaseClient(
    sInstance.projectUrl,
    sInstance.publishableKey,
  );

  final remoteClient = SupabaseSyncClient(
    client: supabaseClient,
    tableName: 'notes',
  );

  final syncEngine = SyncEngine(
    localStorage: localStorage,
    remoteClient: remoteClient,
  );

  // Pull test
  await syncEngine.pullFromRemote();
  print('--- After pull ---');
  for (var r in localStorage.getAll()) {
    print(r.data);
  }

  final testId = DateTime.now().millisecondsSinceEpoch;

  await localStorage.save(
    SyncRecord(
      id: testId.toString(),
      data: {
        'id': testId,
        'title': 'Created offline',
        'updated_at': DateTime.now().toIso8601String(),
      },
      updatedAt: DateTime.now(),
      isSynced: false,
    ),
  );
  await syncEngine.pushToRemote();
  print('--- After push, check Supabase dashboard ---');
}
