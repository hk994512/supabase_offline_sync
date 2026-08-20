import 'package:mocktail/mocktail.dart';
import 'package:sync_supabase/sync_supabase.dart';

class MockRemoteClient extends Mock implements IRemoteClient {}

void main() {
  late Box box;
  late TableStorage localStorage;
  late MockRemoteClient mockRemoteClient;
  late SyncEngine syncEngine;

  setUpAll(() {
    registerFallbackValue(
      SyncRecord(id: 'fallback', data: {}, updatedAt: DateTime.now()),
    );
  });
  setUp(() async {
    Hive.init('./test_hive_data');
    box = await Hive.openBox('test_sync_engine');
    await box.clear();
    localStorage = TableStorage(box);
    mockRemoteClient = MockRemoteClient();
    syncEngine = SyncEngine(
      localStorage: localStorage,
      remoteClient: mockRemoteClient,
    );
  });

  tearDown(() async {
    await box.deleteFromDisk();
  });

  test('pullFromRemote saves new records to local storage', () async {
    final remoteRecord = SyncRecord(
      id: '1',
      data: {'id': '1', 'title': 'From Server'},
      updatedAt: DateTime.now(),
      isSynced: true,
    );

    when(
      () => mockRemoteClient.fetchAll(),
    ).thenAnswer((_) async => [remoteRecord]);

    await syncEngine.pullFromRemote();

    final local = localStorage.get('1');
    expect(local, isNotNull);
    expect(local!.data['title'], 'From Server');
  });

  test('pushToRemote sends unsynced records and marks them synced', () async {
    final localRecord = SyncRecord(
      id: '2',
      data: {'id': '2', 'title': 'Local Only'},
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await localStorage.save(localRecord);

    when(() => mockRemoteClient.pushRecord(any())).thenAnswer((_) async {});

    await syncEngine.pushToRemote();

    verify(() => mockRemoteClient.pushRecord(any())).called(1);

    final updated = localStorage.get('2');
    expect(updated!.isSynced, true);
  });

  test('pushToRemote handles failure gracefully without crashing', () async {
    final localRecord = SyncRecord(
      id: '3',
      data: {'id': '3', 'title': 'Will Fail'},
      updatedAt: DateTime.now(),
      isSynced: false,
    );
    await localStorage.save(localRecord);

    when(
      () => mockRemoteClient.pushRecord(any()),
    ).thenThrow(Exception('Network error'));

    // Should not throw
    await syncEngine.pushToRemote();

    // Record should remain unsynced since push failed
    final stillPending = localStorage.get('3');
    expect(stillPending!.isSynced, false);
  });

  test(
    'pullFromRemote resolves conflict by taking newer remote record',
    () async {
      final oldTime = DateTime.now().subtract(const Duration(minutes: 5));
      final newTime = DateTime.now();

      await localStorage.save(
        SyncRecord(
          id: '4',
          data: {'id': '4', 'title': 'Old Local Unsynced'},
          updatedAt: oldTime,
          isSynced: false,
        ),
      );

      final newerRemote = SyncRecord(
        id: '4',
        data: {'id': '4', 'title': 'Newer Remote'},
        updatedAt: newTime,
        isSynced: true,
      );

      when(
        () => mockRemoteClient.fetchAll(),
      ).thenAnswer((_) async => [newerRemote]);

      await syncEngine.pullFromRemote();

      final result = localStorage.get('4');
      expect(result!.data['title'], 'Newer Remote');
    },
  );
}
