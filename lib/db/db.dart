import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:music_player/db/daos/history.dart';
import 'package:music_player/db/daos/playlist.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:music_player/db/tables/history.dart';
import 'package:music_player/db/tables/playlist.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/track.dart';

part 'db.g.dart';

@DriftDatabase(tables: [Track, Playlist, PlaylistEntry, History], daos: [TrackDao, PlaylistDao, HistoryDao])
class Db extends _$Db {
  Db() : super(_openConnection());

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      if (from == 1) return;
      await m.createAll();
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return driftDatabase(
      name: 'test_db_7.db',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  });
}
