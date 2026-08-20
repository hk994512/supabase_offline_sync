
import '../sync_supabase.dart';

class ConnectivityWatcher {
  final SyncEngine syncEngine;
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _wasOffline = false;

  ConnectivityWatcher({required this.syncEngine});

  void start() {
    _subscription = Connectivity().onConnectivityChanged.listen((
      results,
    ) async {
      final isOffline = results.every((r) => r == ConnectivityResult.none);

      if (isOffline) {
        _wasOffline = true;
        print('📴 Connection lost — sync paused');
      } else if (_wasOffline) {
        // Connection wapis aayi hai after being offline
        _wasOffline = false;
        print('📶 Connection restored — triggering sync');
        try {
          await syncEngine.fullSync();
          print('✅ Auto-sync complete');
        } catch (e) {
          print('⚠️ Auto-sync failed: $e');
        }
      }
    });
  }

  void stop() {
    _subscription?.cancel();
  }
}
