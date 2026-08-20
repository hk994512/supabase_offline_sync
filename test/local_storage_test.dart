
import 'package:sync_supabase/sync_supabase.dart';

void main() {
  setUp(() async {
    Hive.init('./test/hive_test_data'); // temp folder for test data
  });

  tearDown(() async {
    await Hive.deleteFromDisk(); // clean up after each test
  });

  test('save and get record from local storage', () async {
    final box = await Hive.openBox('test_table');
    final storage = TableStorage(box);

    final record = SyncRecord(
      id: '1',
      data: {'title': 'Test Note'},
      updatedAt: DateTime.now(),
      isSynced: false,
    );

    await storage.save(record);
    final result = storage.get('1');

    expect(result, isNotNull);
    expect(result!.data['title'], 'Test Note');
    expect(result.isSynced, false);
  });

  test('getPendingSync returns only unsynced records', () async {
    final box = await Hive.openBox('test_table2');
    final storage = TableStorage(box);

    await storage.save(
      SyncRecord(
        id: '1',
        data: {'title': 'Synced'},
        updatedAt: DateTime.now(),
        isSynced: true,
      ),
    );

    await storage.save(
      SyncRecord(
        id: '2',
        data: {'title': 'Not Synced'},
        updatedAt: DateTime.now(),
        isSynced: false,
      ),
    );

    final pending = storage.getPendingSync();
    expect(pending.length, 1);
    expect(pending.first.id, '2');
  });
}
