// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'db.dart';

// ignore_for_file: type=lint
class $TrackTable extends Track with TableInfo<$TrackTable, TrackData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TrackTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _pathMeta = const VerificationMeta('path');
  @override
  late final GeneratedColumn<String> path = GeneratedColumn<String>(
    'path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways('UNIQUE'),
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _coverPathMeta = const VerificationMeta(
    'coverPath',
  );
  @override
  late final GeneratedColumn<String> coverPath = GeneratedColumn<String>(
    'cover_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<DateTime> lastModified = GeneratedColumn<DateTime>(
    'last_modified',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isIndexedMeta = const VerificationMeta(
    'isIndexed',
  );
  @override
  late final GeneratedColumn<bool> isIndexed = GeneratedColumn<bool>(
    'is_indexed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_indexed" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    path,
    title,
    artist,
    album,
    genre,
    coverPath,
    lastModified,
    isIndexed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'track';
  @override
  VerificationContext validateIntegrity(
    Insertable<TrackData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('path')) {
      context.handle(
        _pathMeta,
        path.isAcceptableOrUnknown(data['path']!, _pathMeta),
      );
    } else if (isInserting) {
      context.missing(_pathMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('artist')) {
      context.handle(
        _artistMeta,
        artist.isAcceptableOrUnknown(data['artist']!, _artistMeta),
      );
    }
    if (data.containsKey('album')) {
      context.handle(
        _albumMeta,
        album.isAcceptableOrUnknown(data['album']!, _albumMeta),
      );
    }
    if (data.containsKey('genre')) {
      context.handle(
        _genreMeta,
        genre.isAcceptableOrUnknown(data['genre']!, _genreMeta),
      );
    }
    if (data.containsKey('cover_path')) {
      context.handle(
        _coverPathMeta,
        coverPath.isAcceptableOrUnknown(data['cover_path']!, _coverPathMeta),
      );
    }
    if (data.containsKey('last_modified')) {
      context.handle(
        _lastModifiedMeta,
        lastModified.isAcceptableOrUnknown(
          data['last_modified']!,
          _lastModifiedMeta,
        ),
      );
    }
    if (data.containsKey('is_indexed')) {
      context.handle(
        _isIndexedMeta,
        isIndexed.isAcceptableOrUnknown(data['is_indexed']!, _isIndexedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TrackData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TrackData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      path: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}path'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      artist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      coverPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}cover_path'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_modified'],
      ),
      isIndexed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_indexed'],
      )!,
    );
  }

  @override
  $TrackTable createAlias(String alias) {
    return $TrackTable(attachedDatabase, alias);
  }
}

class TrackData extends DataClass implements Insertable<TrackData> {
  final int id;
  final String path;
  final String title;
  final String? artist;
  final String? album;
  final String? genre;
  final String? coverPath;
  final DateTime? lastModified;
  final bool isIndexed;
  const TrackData({
    required this.id,
    required this.path,
    required this.title,
    this.artist,
    this.album,
    this.genre,
    this.coverPath,
    this.lastModified,
    required this.isIndexed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['path'] = Variable<String>(path);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || coverPath != null) {
      map['cover_path'] = Variable<String>(coverPath);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<DateTime>(lastModified);
    }
    map['is_indexed'] = Variable<bool>(isIndexed);
    return map;
  }

  TrackCompanion toCompanion(bool nullToAbsent) {
    return TrackCompanion(
      id: Value(id),
      path: Value(path),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      coverPath: coverPath == null && nullToAbsent
          ? const Value.absent()
          : Value(coverPath),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      isIndexed: Value(isIndexed),
    );
  }

  factory TrackData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TrackData(
      id: serializer.fromJson<int>(json['id']),
      path: serializer.fromJson<String>(json['path']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      album: serializer.fromJson<String?>(json['album']),
      genre: serializer.fromJson<String?>(json['genre']),
      coverPath: serializer.fromJson<String?>(json['coverPath']),
      lastModified: serializer.fromJson<DateTime?>(json['lastModified']),
      isIndexed: serializer.fromJson<bool>(json['isIndexed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'path': serializer.toJson<String>(path),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'album': serializer.toJson<String?>(album),
      'genre': serializer.toJson<String?>(genre),
      'coverPath': serializer.toJson<String?>(coverPath),
      'lastModified': serializer.toJson<DateTime?>(lastModified),
      'isIndexed': serializer.toJson<bool>(isIndexed),
    };
  }

  TrackData copyWith({
    int? id,
    String? path,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<String?> coverPath = const Value.absent(),
    Value<DateTime?> lastModified = const Value.absent(),
    bool? isIndexed,
  }) => TrackData(
    id: id ?? this.id,
    path: path ?? this.path,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    album: album.present ? album.value : this.album,
    genre: genre.present ? genre.value : this.genre,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    lastModified: lastModified.present ? lastModified.value : this.lastModified,
    isIndexed: isIndexed ?? this.isIndexed,
  );
  TrackData copyWithCompanion(TrackCompanion data) {
    return TrackData(
      id: data.id.present ? data.id.value : this.id,
      path: data.path.present ? data.path.value : this.path,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      album: data.album.present ? data.album.value : this.album,
      genre: data.genre.present ? data.genre.value : this.genre,
      coverPath: data.coverPath.present ? data.coverPath.value : this.coverPath,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      isIndexed: data.isIndexed.present ? data.isIndexed.value : this.isIndexed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TrackData(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('genre: $genre, ')
          ..write('coverPath: $coverPath, ')
          ..write('lastModified: $lastModified, ')
          ..write('isIndexed: $isIndexed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    path,
    title,
    artist,
    album,
    genre,
    coverPath,
    lastModified,
    isIndexed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackData &&
          other.id == this.id &&
          other.path == this.path &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.album == this.album &&
          other.genre == this.genre &&
          other.coverPath == this.coverPath &&
          other.lastModified == this.lastModified &&
          other.isIndexed == this.isIndexed);
}

class TrackCompanion extends UpdateCompanion<TrackData> {
  final Value<int> id;
  final Value<String> path;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> album;
  final Value<String?> genre;
  final Value<String?> coverPath;
  final Value<DateTime?> lastModified;
  final Value<bool> isIndexed;
  const TrackCompanion({
    this.id = const Value.absent(),
    this.path = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.genre = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.isIndexed = const Value.absent(),
  });
  TrackCompanion.insert({
    this.id = const Value.absent(),
    required String path,
    required String title,
    this.artist = const Value.absent(),
    this.album = const Value.absent(),
    this.genre = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.isIndexed = const Value.absent(),
  }) : path = Value(path),
       title = Value(title);
  static Insertable<TrackData> custom({
    Expression<int>? id,
    Expression<String>? path,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? album,
    Expression<String>? genre,
    Expression<String>? coverPath,
    Expression<DateTime>? lastModified,
    Expression<bool>? isIndexed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (path != null) 'path': path,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (album != null) 'album': album,
      if (genre != null) 'genre': genre,
      if (coverPath != null) 'cover_path': coverPath,
      if (lastModified != null) 'last_modified': lastModified,
      if (isIndexed != null) 'is_indexed': isIndexed,
    });
  }

  TrackCompanion copyWith({
    Value<int>? id,
    Value<String>? path,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? album,
    Value<String?>? genre,
    Value<String?>? coverPath,
    Value<DateTime?>? lastModified,
    Value<bool>? isIndexed,
  }) {
    return TrackCompanion(
      id: id ?? this.id,
      path: path ?? this.path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      coverPath: coverPath ?? this.coverPath,
      lastModified: lastModified ?? this.lastModified,
      isIndexed: isIndexed ?? this.isIndexed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (path.present) {
      map['path'] = Variable<String>(path.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (artist.present) {
      map['artist'] = Variable<String>(artist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (coverPath.present) {
      map['cover_path'] = Variable<String>(coverPath.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<DateTime>(lastModified.value);
    }
    if (isIndexed.present) {
      map['is_indexed'] = Variable<bool>(isIndexed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TrackCompanion(')
          ..write('id: $id, ')
          ..write('path: $path, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('album: $album, ')
          ..write('genre: $genre, ')
          ..write('coverPath: $coverPath, ')
          ..write('lastModified: $lastModified, ')
          ..write('isIndexed: $isIndexed')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $TrackTable track = $TrackTable(this);
  late final Index titleArtist = Index(
    'title_artist',
    'CREATE INDEX title_artist ON track (title, artist)',
  );
  late final TrackDao trackDao = TrackDao(this as AppDatabase);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [track, titleArtist];
}

typedef $$TrackTableCreateCompanionBuilder =
    TrackCompanion Function({
      Value<int> id,
      required String path,
      required String title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> genre,
      Value<String?> coverPath,
      Value<DateTime?> lastModified,
      Value<bool> isIndexed,
    });
typedef $$TrackTableUpdateCompanionBuilder =
    TrackCompanion Function({
      Value<int> id,
      Value<String> path,
      Value<String> title,
      Value<String?> artist,
      Value<String?> album,
      Value<String?> genre,
      Value<String?> coverPath,
      Value<DateTime?> lastModified,
      Value<bool> isIndexed,
    });

class $$TrackTableFilterComposer extends Composer<_$AppDatabase, $TrackTable> {
  $$TrackTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isIndexed => $composableBuilder(
    column: $table.isIndexed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TrackTableOrderingComposer
    extends Composer<_$AppDatabase, $TrackTable> {
  $$TrackTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get path => $composableBuilder(
    column: $table.path,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artist => $composableBuilder(
    column: $table.artist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get album => $composableBuilder(
    column: $table.album,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get genre => $composableBuilder(
    column: $table.genre,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get coverPath => $composableBuilder(
    column: $table.coverPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isIndexed => $composableBuilder(
    column: $table.isIndexed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TrackTableAnnotationComposer
    extends Composer<_$AppDatabase, $TrackTable> {
  $$TrackTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIndexed =>
      $composableBuilder(column: $table.isIndexed, builder: (column) => column);
}

class $$TrackTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TrackTable,
          TrackData,
          $$TrackTableFilterComposer,
          $$TrackTableOrderingComposer,
          $$TrackTableAnnotationComposer,
          $$TrackTableCreateCompanionBuilder,
          $$TrackTableUpdateCompanionBuilder,
          (TrackData, BaseReferences<_$AppDatabase, $TrackTable, TrackData>),
          TrackData,
          PrefetchHooks Function()
        > {
  $$TrackTableTableManager(_$AppDatabase db, $TrackTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TrackTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TrackTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TrackTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<DateTime?> lastModified = const Value.absent(),
                Value<bool> isIndexed = const Value.absent(),
              }) => TrackCompanion(
                id: id,
                path: path,
                title: title,
                artist: artist,
                album: album,
                genre: genre,
                coverPath: coverPath,
                lastModified: lastModified,
                isIndexed: isIndexed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String path,
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<DateTime?> lastModified = const Value.absent(),
                Value<bool> isIndexed = const Value.absent(),
              }) => TrackCompanion.insert(
                id: id,
                path: path,
                title: title,
                artist: artist,
                album: album,
                genre: genre,
                coverPath: coverPath,
                lastModified: lastModified,
                isIndexed: isIndexed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TrackTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TrackTable,
      TrackData,
      $$TrackTableFilterComposer,
      $$TrackTableOrderingComposer,
      $$TrackTableAnnotationComposer,
      $$TrackTableCreateCompanionBuilder,
      $$TrackTableUpdateCompanionBuilder,
      (TrackData, BaseReferences<_$AppDatabase, $TrackTable, TrackData>),
      TrackData,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$TrackTableTableManager get track =>
      $$TrackTableTableManager(_db, _db.track);
}
