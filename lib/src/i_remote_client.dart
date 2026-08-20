
import '../sync_supabase.dart';

abstract class IRemoteClient {
  Future<List<SyncRecord>> fetchAll();
  Future<void> pushRecord(SyncRecord record);
  Future<void> deleteRecord(String id);
}
