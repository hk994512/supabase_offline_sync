
import '../sync_supabase.dart';

class LocalStorage {
  static Future<void> init() async {
    await Hive.initFlutter();
  }

  static Future<Box> openBox(String tableName) async {
    return await Hive.openBox(tableName);
  }
}