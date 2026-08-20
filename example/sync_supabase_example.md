# Example

## Setup

```dart
import 'package:supabase/supabase.dart';
import 'package:hive/hive.dart';
import 'package:supabase_offline_sync/supabase_offline_sync.dart';

void main() async {
  Hive.init('./hive_data');
  final box = await Hive.openBox('notes');
  final localStorage = TableStorage(box);

  final supabaseClient = SupabaseClient('YOUR_URL', 'YOUR_ANON_KEY');
  final remoteClient = SupabaseSyncClient(client: supabaseClient, tableName: 'notes');

  final syncEngine = SyncEngine(localStorage: localStorage, remoteClient: remoteClient);

  // Pull latest data from Supabase
  await syncEngine.pullFromRemote();

  // Push local pending changes
  await syncEngine.pushToRemote();

  // Or do both
  await syncEngine.fullSync();
}
```

## Auto-sync on connectivity restore

```dart
final watcher = ConnectivityWatcher(syncEngine: syncEngine);
watcher.start();
```
