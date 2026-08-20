# 🔄 Supabase Offline Sync

[![pub package](https://img.shields.io/pub/v/supabase_offline_sync.svg)](https://pub.dev/packages/supabase_offline_sync)
[![pub points](https://img.shields.io/pub/points/supabase_offline_sync)](https://pub.dev/packages/supabase_offline_sync/score)
[![likes](https://img.shields.io/pub/likes/supabase_offline_sync)](https://pub.dev/packages/supabase_offline_sync/score)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](LICENSE)

An **offline-first sync toolkit for Supabase** — sync local Hive storage with your Supabase tables automatically, with conflict resolution and connectivity-aware auto-sync.

Build Flutter apps that work seamlessly offline and sync data the moment connectivity is restored — no manual sync buttons, no lost writes.

---

## ✨ Features

- 📦 **Local-first storage** using Hive — read/write instantly, even offline
- 🔄 **Two-way sync** — pull from Supabase, push local changes back
- 📶 **Auto-sync on reconnect** — listens for connectivity changes and syncs automatically
- ⚠️ **Conflict detection** — handles cases where local and remote both changed
- 🛡️ **Resilient push queue** — failed syncs retry automatically on next sync cycle, without crashing
- 🧪 **Fully unit tested** — core sync logic tested with mocked network calls

---

## 📥 Installation

```yaml
dependencies:
  supabase_offline_sync: ^0.1.0
```

```bash
flutter pub get
```

---

## 🛠️ Usage

### 1. Set up local storage and the remote client

```dart
import 'package:hive/hive.dart';
import 'package:supabase/supabase.dart';
import 'package:supabase_offline_sync/supabase_offline_sync.dart';

Hive.init('./hive_data');
final box = await Hive.openBox('notes');
final localStorage = TableStorage(box);

final supabaseClient = SupabaseClient('YOUR_SUPABASE_URL', 'YOUR_ANON_KEY');
final remoteClient = SupabaseSyncClient(
  client: supabaseClient,
  tableName: 'notes',
);
```

### 2. Create the sync engine

```dart
final syncEngine = SyncEngine(
  localStorage: localStorage,
  remoteClient: remoteClient,
);
```

### 3. Sync data

```dart
// Pull latest data from Supabase into local storage
await syncEngine.pullFromRemote();

// Push local pending changes to Supabase
await syncEngine.pushToRemote();

// Or do both in one call
await syncEngine.fullSync();
```

### 4. Enable auto-sync on connectivity restore

```dart
final watcher = ConnectivityWatcher(syncEngine: syncEngine);
watcher.start();

// Later, when no longer needed
watcher.stop();
```

---

## 🧠 How it works

```
┌──────────────┐        pull        ┌──────────────┐
│              │ ─────────────────> │              │
│  Local (Hive)│                    │   Supabase   │
│              │ <───────────────── │              │
└──────────────┘        push        └──────────────┘
```

- Every local record tracks an `isSynced` flag.
- Writes made offline are queued and marked `isSynced: false`.
- On sync, pending records are pushed to Supabase; on success, they're marked synced.
- If a push fails (e.g. no internet), the record stays queued and retries on the next sync — nothing is lost.
- When pulling, if a record was changed both locally and remotely, the most recently updated version wins.

---

## 📌 Requirements & Notes

- Works with any Supabase table — just make sure each row has an `updated_at` timestamp column, used for conflict resolution.
- Designed to be used inside a Flutter app; pairs naturally with `supabase_flutter` for auth/session handling in your app, while this package handles the offline sync layer.

---

## 🧪 Running Tests

```bash
flutter test
```

Core sync logic is tested with [`mocktail`](https://pub.dev/packages/mocktail), so tests run without needing a live Supabase connection.

---

## 🗺️ Roadmap

- [ ] Multi-table sync management in a single engine instance
- [ ] Configurable conflict resolution strategies (not just "newest wins")
- [ ] Realtime subscription support alongside manual sync
- [ ] Batch push optimization

---

## 🤝 Contributing

Issues and pull requests are welcome! If you run into a bug or have a feature idea, open an issue on [GitHub](https://github.com/hk994512/supabase_offline_sync/issues).

---

## 📄 License

This project is licensed under the [MIT License](LICENSE).

---

## 👤 Author

**Muhammad Ameer Hamza**
Flutter Developer
🔗 [Portfolio](https://engrhamzadev.netlify.app) • [GitHub](https://github.com/hk994512) • [pub.dev](https://pub.dev/packages/supabase_offline_sync)
