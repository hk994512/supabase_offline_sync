
import 'package:sync_supabase/sync_supabase.dart';
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
