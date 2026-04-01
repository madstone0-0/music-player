import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:music_player/db/daos/track.dart';
import 'package:path_provider/path_provider.dart';

import 'tables/track.dart';

part 'db.g.dart';

@DriftDatabase(tables: [Track], daos: [TrackDao])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
      // Add indexes for the columns used in GROUP BY / ORDER BY clauses across
      // the Albums, Artists, and Album Artists list queries.
      await m.database.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_album ON track (album)',
      );
      await m.database.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_artist ON track (artist)',
      );
      await m.database.customStatement(
        'CREATE INDEX IF NOT EXISTS idx_album_artist ON track (album_artist)',
      );
    },
    onUpgrade: (m, from, to) async {
      if (from < 2) {
        // Schema v2: add indexes on album, artist, and album_artist.
        // These were missing in v1, causing full table scans for every
        // Albums / Artists / Album Artists list query.
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_album ON track (album)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_artist ON track (artist)',
        );
        await m.database.customStatement(
          'CREATE INDEX IF NOT EXISTS idx_album_artist ON track (album_artist)',
        );
      }
    },
  );
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    return driftDatabase(
      name: 'test_db_3.db',
      native: const DriftNativeOptions(
        // By default, `driftDatabase` from `package:drift_flutter` stores the
        // database files in `getApplicationDocumentsDirectory()`.
        databaseDirectory: getApplicationSupportDirectory,
      ),
      // If you need web support, see https://drift.simonbinder.eu/platforms/web/
    );
  });
}
