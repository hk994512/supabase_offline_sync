import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:supabase/supabase.dart';
import 'package:sync_supabase/constants/secrets.dart';
import 'package:sync_supabase/src/supabase_sync_client.dart';
import 'package:sync_supabase/src/table_storage.dart';
import 'package:sync_supabase/src/sync_engine.dart';
import 'package:sync_supabase/src/connectivity_watcher.dart';

final sInstance = SecretsApi.instance;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('connectivity watcher test', () async {
    Hive.init('./hive_data');
    final box = await Hive.openBox('notes');
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

    final watcher = ConnectivityWatcher(syncEngine: syncEngine);
    watcher.start();

    print(' Watching for connectivity changes... (turn off/on wifi to test)');

    await Future.delayed(const Duration(seconds: 60));
    watcher.stop();
  }, timeout: const Timeout(Duration(seconds: 90)));
}
