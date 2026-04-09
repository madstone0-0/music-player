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
  static const VerificationMeta _trackNoMeta = const VerificationMeta(
    'trackNo',
  );
  @override
  late final GeneratedColumn<int> trackNo = GeneratedColumn<int>(
    'track_no',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
    $customConstraints: 'NOT NULL COLLATE NOCASE',
  );
  static const VerificationMeta _artistMeta = const VerificationMeta('artist');
  @override
  late final GeneratedColumn<String> artist = GeneratedColumn<String>(
    'artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'COLLATE NOCASE',
  );
  static const VerificationMeta _albumArtistMeta = const VerificationMeta(
    'albumArtist',
  );
  @override
  late final GeneratedColumn<String> albumArtist = GeneratedColumn<String>(
    'album_artist',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'COLLATE NOCASE',
  );
  static const VerificationMeta _albumMeta = const VerificationMeta('album');
  @override
  late final GeneratedColumn<String> album = GeneratedColumn<String>(
    'album',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'COLLATE NOCASE',
  );
  static const VerificationMeta _genreMeta = const VerificationMeta('genre');
  @override
  late final GeneratedColumn<String> genre = GeneratedColumn<String>(
    'genre',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    $customConstraints: 'COLLATE NOCASE',
  );
  static const VerificationMeta _yearMeta = const VerificationMeta('year');
  @override
  late final GeneratedColumn<int> year = GeneratedColumn<int>(
    'year',
    aliasedName,
    true,
    type: DriftSqlType.int,
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
    trackNo,
    path,
    title,
    artist,
    albumArtist,
    album,
    genre,
    year,
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
    if (data.containsKey('track_no')) {
      context.handle(
        _trackNoMeta,
        trackNo.isAcceptableOrUnknown(data['track_no']!, _trackNoMeta),
      );
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
    if (data.containsKey('album_artist')) {
      context.handle(
        _albumArtistMeta,
        albumArtist.isAcceptableOrUnknown(
          data['album_artist']!,
          _albumArtistMeta,
        ),
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
    if (data.containsKey('year')) {
      context.handle(
        _yearMeta,
        year.isAcceptableOrUnknown(data['year']!, _yearMeta),
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
      trackNo: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_no'],
      ),
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
      albumArtist: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album_artist'],
      ),
      album: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}album'],
      ),
      genre: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}genre'],
      ),
      year: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year'],
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
  final int? trackNo;
  final String path;
  final String title;
  final String? artist;
  final String? albumArtist;
  final String? album;
  final String? genre;
  final int? year;
  final String? coverPath;
  final DateTime? lastModified;
  final bool isIndexed;
  const TrackData({
    required this.id,
    this.trackNo,
    required this.path,
    required this.title,
    this.artist,
    this.albumArtist,
    this.album,
    this.genre,
    this.year,
    this.coverPath,
    this.lastModified,
    required this.isIndexed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || trackNo != null) {
      map['track_no'] = Variable<int>(trackNo);
    }
    map['path'] = Variable<String>(path);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || artist != null) {
      map['artist'] = Variable<String>(artist);
    }
    if (!nullToAbsent || albumArtist != null) {
      map['album_artist'] = Variable<String>(albumArtist);
    }
    if (!nullToAbsent || album != null) {
      map['album'] = Variable<String>(album);
    }
    if (!nullToAbsent || genre != null) {
      map['genre'] = Variable<String>(genre);
    }
    if (!nullToAbsent || year != null) {
      map['year'] = Variable<int>(year);
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
      trackNo: trackNo == null && nullToAbsent
          ? const Value.absent()
          : Value(trackNo),
      path: Value(path),
      title: Value(title),
      artist: artist == null && nullToAbsent
          ? const Value.absent()
          : Value(artist),
      albumArtist: albumArtist == null && nullToAbsent
          ? const Value.absent()
          : Value(albumArtist),
      album: album == null && nullToAbsent
          ? const Value.absent()
          : Value(album),
      genre: genre == null && nullToAbsent
          ? const Value.absent()
          : Value(genre),
      year: year == null && nullToAbsent ? const Value.absent() : Value(year),
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
      trackNo: serializer.fromJson<int?>(json['trackNo']),
      path: serializer.fromJson<String>(json['path']),
      title: serializer.fromJson<String>(json['title']),
      artist: serializer.fromJson<String?>(json['artist']),
      albumArtist: serializer.fromJson<String?>(json['albumArtist']),
      album: serializer.fromJson<String?>(json['album']),
      genre: serializer.fromJson<String?>(json['genre']),
      year: serializer.fromJson<int?>(json['year']),
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
      'trackNo': serializer.toJson<int?>(trackNo),
      'path': serializer.toJson<String>(path),
      'title': serializer.toJson<String>(title),
      'artist': serializer.toJson<String?>(artist),
      'albumArtist': serializer.toJson<String?>(albumArtist),
      'album': serializer.toJson<String?>(album),
      'genre': serializer.toJson<String?>(genre),
      'year': serializer.toJson<int?>(year),
      'coverPath': serializer.toJson<String?>(coverPath),
      'lastModified': serializer.toJson<DateTime?>(lastModified),
      'isIndexed': serializer.toJson<bool>(isIndexed),
    };
  }

  TrackData copyWith({
    int? id,
    Value<int?> trackNo = const Value.absent(),
    String? path,
    String? title,
    Value<String?> artist = const Value.absent(),
    Value<String?> albumArtist = const Value.absent(),
    Value<String?> album = const Value.absent(),
    Value<String?> genre = const Value.absent(),
    Value<int?> year = const Value.absent(),
    Value<String?> coverPath = const Value.absent(),
    Value<DateTime?> lastModified = const Value.absent(),
    bool? isIndexed,
  }) => TrackData(
    id: id ?? this.id,
    trackNo: trackNo.present ? trackNo.value : this.trackNo,
    path: path ?? this.path,
    title: title ?? this.title,
    artist: artist.present ? artist.value : this.artist,
    albumArtist: albumArtist.present ? albumArtist.value : this.albumArtist,
    album: album.present ? album.value : this.album,
    genre: genre.present ? genre.value : this.genre,
    year: year.present ? year.value : this.year,
    coverPath: coverPath.present ? coverPath.value : this.coverPath,
    lastModified: lastModified.present ? lastModified.value : this.lastModified,
    isIndexed: isIndexed ?? this.isIndexed,
  );
  TrackData copyWithCompanion(TrackCompanion data) {
    return TrackData(
      id: data.id.present ? data.id.value : this.id,
      trackNo: data.trackNo.present ? data.trackNo.value : this.trackNo,
      path: data.path.present ? data.path.value : this.path,
      title: data.title.present ? data.title.value : this.title,
      artist: data.artist.present ? data.artist.value : this.artist,
      albumArtist: data.albumArtist.present
          ? data.albumArtist.value
          : this.albumArtist,
      album: data.album.present ? data.album.value : this.album,
      genre: data.genre.present ? data.genre.value : this.genre,
      year: data.year.present ? data.year.value : this.year,
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
          ..write('trackNo: $trackNo, ')
          ..write('path: $path, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('album: $album, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('coverPath: $coverPath, ')
          ..write('lastModified: $lastModified, ')
          ..write('isIndexed: $isIndexed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    trackNo,
    path,
    title,
    artist,
    albumArtist,
    album,
    genre,
    year,
    coverPath,
    lastModified,
    isIndexed,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TrackData &&
          other.id == this.id &&
          other.trackNo == this.trackNo &&
          other.path == this.path &&
          other.title == this.title &&
          other.artist == this.artist &&
          other.albumArtist == this.albumArtist &&
          other.album == this.album &&
          other.genre == this.genre &&
          other.year == this.year &&
          other.coverPath == this.coverPath &&
          other.lastModified == this.lastModified &&
          other.isIndexed == this.isIndexed);
}

class TrackCompanion extends UpdateCompanion<TrackData> {
  final Value<int> id;
  final Value<int?> trackNo;
  final Value<String> path;
  final Value<String> title;
  final Value<String?> artist;
  final Value<String?> albumArtist;
  final Value<String?> album;
  final Value<String?> genre;
  final Value<int?> year;
  final Value<String?> coverPath;
  final Value<DateTime?> lastModified;
  final Value<bool> isIndexed;
  const TrackCompanion({
    this.id = const Value.absent(),
    this.trackNo = const Value.absent(),
    this.path = const Value.absent(),
    this.title = const Value.absent(),
    this.artist = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.album = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.isIndexed = const Value.absent(),
  });
  TrackCompanion.insert({
    this.id = const Value.absent(),
    this.trackNo = const Value.absent(),
    required String path,
    required String title,
    this.artist = const Value.absent(),
    this.albumArtist = const Value.absent(),
    this.album = const Value.absent(),
    this.genre = const Value.absent(),
    this.year = const Value.absent(),
    this.coverPath = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.isIndexed = const Value.absent(),
  }) : path = Value(path),
       title = Value(title);
  static Insertable<TrackData> custom({
    Expression<int>? id,
    Expression<int>? trackNo,
    Expression<String>? path,
    Expression<String>? title,
    Expression<String>? artist,
    Expression<String>? albumArtist,
    Expression<String>? album,
    Expression<String>? genre,
    Expression<int>? year,
    Expression<String>? coverPath,
    Expression<DateTime>? lastModified,
    Expression<bool>? isIndexed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (trackNo != null) 'track_no': trackNo,
      if (path != null) 'path': path,
      if (title != null) 'title': title,
      if (artist != null) 'artist': artist,
      if (albumArtist != null) 'album_artist': albumArtist,
      if (album != null) 'album': album,
      if (genre != null) 'genre': genre,
      if (year != null) 'year': year,
      if (coverPath != null) 'cover_path': coverPath,
      if (lastModified != null) 'last_modified': lastModified,
      if (isIndexed != null) 'is_indexed': isIndexed,
    });
  }

  TrackCompanion copyWith({
    Value<int>? id,
    Value<int?>? trackNo,
    Value<String>? path,
    Value<String>? title,
    Value<String?>? artist,
    Value<String?>? albumArtist,
    Value<String?>? album,
    Value<String?>? genre,
    Value<int?>? year,
    Value<String?>? coverPath,
    Value<DateTime?>? lastModified,
    Value<bool>? isIndexed,
  }) {
    return TrackCompanion(
      id: id ?? this.id,
      trackNo: trackNo ?? this.trackNo,
      path: path ?? this.path,
      title: title ?? this.title,
      artist: artist ?? this.artist,
      albumArtist: albumArtist ?? this.albumArtist,
      album: album ?? this.album,
      genre: genre ?? this.genre,
      year: year ?? this.year,
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
    if (trackNo.present) {
      map['track_no'] = Variable<int>(trackNo.value);
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
    if (albumArtist.present) {
      map['album_artist'] = Variable<String>(albumArtist.value);
    }
    if (album.present) {
      map['album'] = Variable<String>(album.value);
    }
    if (genre.present) {
      map['genre'] = Variable<String>(genre.value);
    }
    if (year.present) {
      map['year'] = Variable<int>(year.value);
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
          ..write('trackNo: $trackNo, ')
          ..write('path: $path, ')
          ..write('title: $title, ')
          ..write('artist: $artist, ')
          ..write('albumArtist: $albumArtist, ')
          ..write('album: $album, ')
          ..write('genre: $genre, ')
          ..write('year: $year, ')
          ..write('coverPath: $coverPath, ')
          ..write('lastModified: $lastModified, ')
          ..write('isIndexed: $isIndexed')
          ..write(')'))
        .toString();
  }
}

class $PlaylistTable extends Playlist
    with TableInfo<$PlaylistTable, PlaylistData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    $customConstraints: 'NOT NULL COLLATE NOCASE UNIQUE',
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
    defaultValue: currentDateAndTime,
  );
  static const VerificationMeta _lastPlayedMeta = const VerificationMeta(
    'lastPlayed',
  );
  @override
  late final GeneratedColumn<DateTime> lastPlayed = GeneratedColumn<DateTime>(
    'last_played',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    createdAt,
    updatedAt,
    lastPlayed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    }
    if (data.containsKey('last_played')) {
      context.handle(
        _lastPlayedMeta,
        lastPlayed.isAcceptableOrUnknown(data['last_played']!, _lastPlayedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaylistData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      lastPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_played'],
      ),
    );
  }

  @override
  $PlaylistTable createAlias(String alias) {
    return $PlaylistTable(attachedDatabase, alias);
  }
}

class PlaylistData extends DataClass implements Insertable<PlaylistData> {
  final int id;
  final String name;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? lastPlayed;
  const PlaylistData({
    required this.id,
    required this.name,
    required this.createdAt,
    required this.updatedAt,
    this.lastPlayed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || lastPlayed != null) {
      map['last_played'] = Variable<DateTime>(lastPlayed);
    }
    return map;
  }

  PlaylistCompanion toCompanion(bool nullToAbsent) {
    return PlaylistCompanion(
      id: Value(id),
      name: Value(name),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      lastPlayed: lastPlayed == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPlayed),
    );
  }

  factory PlaylistData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistData(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      lastPlayed: serializer.fromJson<DateTime?>(json['lastPlayed']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'lastPlayed': serializer.toJson<DateTime?>(lastPlayed),
    };
  }

  PlaylistData copyWith({
    int? id,
    String? name,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> lastPlayed = const Value.absent(),
  }) => PlaylistData(
    id: id ?? this.id,
    name: name ?? this.name,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    lastPlayed: lastPlayed.present ? lastPlayed.value : this.lastPlayed,
  );
  PlaylistData copyWithCompanion(PlaylistCompanion data) {
    return PlaylistData(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      lastPlayed: data.lastPlayed.present
          ? data.lastPlayed.value
          : this.lastPlayed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistData(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastPlayed: $lastPlayed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, createdAt, updatedAt, lastPlayed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistData &&
          other.id == this.id &&
          other.name == this.name &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.lastPlayed == this.lastPlayed);
}

class PlaylistCompanion extends UpdateCompanion<PlaylistData> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> lastPlayed;
  const PlaylistCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastPlayed = const Value.absent(),
  });
  PlaylistCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.lastPlayed = const Value.absent(),
  }) : name = Value(name);
  static Insertable<PlaylistData> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? lastPlayed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (lastPlayed != null) 'last_played': lastPlayed,
    });
  }

  PlaylistCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? lastPlayed,
  }) {
    return PlaylistCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastPlayed: lastPlayed ?? this.lastPlayed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (lastPlayed.present) {
      map['last_played'] = Variable<DateTime>(lastPlayed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('lastPlayed: $lastPlayed')
          ..write(')'))
        .toString();
  }
}

class $PlaylistEntryTable extends PlaylistEntry
    with TableInfo<$PlaylistEntryTable, PlaylistEntryData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaylistEntryTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _playlistIdMeta = const VerificationMeta(
    'playlistId',
  );
  @override
  late final GeneratedColumn<int> playlistId = GeneratedColumn<int>(
    'playlist_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES playlist (id) ON DELETE CASCADE',
    ),
  );
  static const VerificationMeta _trackIdMeta = const VerificationMeta(
    'trackId',
  );
  @override
  late final GeneratedColumn<int> trackId = GeneratedColumn<int>(
    'track_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES track (id)',
    ),
  );
  static const VerificationMeta _positionMeta = const VerificationMeta(
    'position',
  );
  @override
  late final GeneratedColumn<int> position = GeneratedColumn<int>(
    'position',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, playlistId, trackId, position];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playlist_entry';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaylistEntryData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('playlist_id')) {
      context.handle(
        _playlistIdMeta,
        playlistId.isAcceptableOrUnknown(data['playlist_id']!, _playlistIdMeta),
      );
    } else if (isInserting) {
      context.missing(_playlistIdMeta);
    }
    if (data.containsKey('track_id')) {
      context.handle(
        _trackIdMeta,
        trackId.isAcceptableOrUnknown(data['track_id']!, _trackIdMeta),
      );
    } else if (isInserting) {
      context.missing(_trackIdMeta);
    }
    if (data.containsKey('position')) {
      context.handle(
        _positionMeta,
        position.isAcceptableOrUnknown(data['position']!, _positionMeta),
      );
    } else if (isInserting) {
      context.missing(_positionMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {playlistId, position},
  ];
  @override
  PlaylistEntryData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaylistEntryData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      playlistId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}playlist_id'],
      )!,
      trackId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}track_id'],
      )!,
      position: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position'],
      )!,
    );
  }

  @override
  $PlaylistEntryTable createAlias(String alias) {
    return $PlaylistEntryTable(attachedDatabase, alias);
  }
}

class PlaylistEntryData extends DataClass
    implements Insertable<PlaylistEntryData> {
  final int id;
  final int playlistId;
  final int trackId;
  final int position;
  const PlaylistEntryData({
    required this.id,
    required this.playlistId,
    required this.trackId,
    required this.position,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['playlist_id'] = Variable<int>(playlistId);
    map['track_id'] = Variable<int>(trackId);
    map['position'] = Variable<int>(position);
    return map;
  }

  PlaylistEntryCompanion toCompanion(bool nullToAbsent) {
    return PlaylistEntryCompanion(
      id: Value(id),
      playlistId: Value(playlistId),
      trackId: Value(trackId),
      position: Value(position),
    );
  }

  factory PlaylistEntryData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaylistEntryData(
      id: serializer.fromJson<int>(json['id']),
      playlistId: serializer.fromJson<int>(json['playlistId']),
      trackId: serializer.fromJson<int>(json['trackId']),
      position: serializer.fromJson<int>(json['position']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'playlistId': serializer.toJson<int>(playlistId),
      'trackId': serializer.toJson<int>(trackId),
      'position': serializer.toJson<int>(position),
    };
  }

  PlaylistEntryData copyWith({
    int? id,
    int? playlistId,
    int? trackId,
    int? position,
  }) => PlaylistEntryData(
    id: id ?? this.id,
    playlistId: playlistId ?? this.playlistId,
    trackId: trackId ?? this.trackId,
    position: position ?? this.position,
  );
  PlaylistEntryData copyWithCompanion(PlaylistEntryCompanion data) {
    return PlaylistEntryData(
      id: data.id.present ? data.id.value : this.id,
      playlistId: data.playlistId.present
          ? data.playlistId.value
          : this.playlistId,
      trackId: data.trackId.present ? data.trackId.value : this.trackId,
      position: data.position.present ? data.position.value : this.position,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntryData(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, playlistId, trackId, position);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaylistEntryData &&
          other.id == this.id &&
          other.playlistId == this.playlistId &&
          other.trackId == this.trackId &&
          other.position == this.position);
}

class PlaylistEntryCompanion extends UpdateCompanion<PlaylistEntryData> {
  final Value<int> id;
  final Value<int> playlistId;
  final Value<int> trackId;
  final Value<int> position;
  const PlaylistEntryCompanion({
    this.id = const Value.absent(),
    this.playlistId = const Value.absent(),
    this.trackId = const Value.absent(),
    this.position = const Value.absent(),
  });
  PlaylistEntryCompanion.insert({
    this.id = const Value.absent(),
    required int playlistId,
    required int trackId,
    required int position,
  }) : playlistId = Value(playlistId),
       trackId = Value(trackId),
       position = Value(position);
  static Insertable<PlaylistEntryData> custom({
    Expression<int>? id,
    Expression<int>? playlistId,
    Expression<int>? trackId,
    Expression<int>? position,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (playlistId != null) 'playlist_id': playlistId,
      if (trackId != null) 'track_id': trackId,
      if (position != null) 'position': position,
    });
  }

  PlaylistEntryCompanion copyWith({
    Value<int>? id,
    Value<int>? playlistId,
    Value<int>? trackId,
    Value<int>? position,
  }) {
    return PlaylistEntryCompanion(
      id: id ?? this.id,
      playlistId: playlistId ?? this.playlistId,
      trackId: trackId ?? this.trackId,
      position: position ?? this.position,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (playlistId.present) {
      map['playlist_id'] = Variable<int>(playlistId.value);
    }
    if (trackId.present) {
      map['track_id'] = Variable<int>(trackId.value);
    }
    if (position.present) {
      map['position'] = Variable<int>(position.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaylistEntryCompanion(')
          ..write('id: $id, ')
          ..write('playlistId: $playlistId, ')
          ..write('trackId: $trackId, ')
          ..write('position: $position')
          ..write(')'))
        .toString();
  }
}

abstract class _$Db extends GeneratedDatabase {
  _$Db(QueryExecutor e) : super(e);
  $DbManager get managers => $DbManager(this);
  late final $TrackTable track = $TrackTable(this);
  late final $PlaylistTable playlist = $PlaylistTable(this);
  late final $PlaylistEntryTable playlistEntry = $PlaylistEntryTable(this);
  late final Index titleArtist = Index(
    'title_artist',
    'CREATE INDEX title_artist ON track (title, artist)',
  );
  late final Index path = Index('path', 'CREATE INDEX path ON track (path)');
  late final Index artistAlbum = Index(
    'artist_album',
    'CREATE INDEX artist_album ON track (artist, album)',
  );
  late final Index albumArtistAlbum = Index(
    'album_artist_album',
    'CREATE INDEX album_artist_album ON track (album_artist, album)',
  );
  late final Index artist = Index(
    'artist',
    'CREATE INDEX artist ON track (artist)',
  );
  late final Index album = Index(
    'album',
    'CREATE INDEX album ON track (album)',
  );
  late final Index albumArtist = Index(
    'albumArtist',
    'CREATE INDEX albumArtist ON track (album_artist)',
  );
  late final TrackDao trackDao = TrackDao(this as Db);
  late final PlaylistDao playlistDao = PlaylistDao(this as Db);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    track,
    playlist,
    playlistEntry,
    titleArtist,
    path,
    artistAlbum,
    albumArtistAlbum,
    artist,
    album,
    albumArtist,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'playlist',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('playlist_entry', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$TrackTableCreateCompanionBuilder =
    TrackCompanion Function({
      Value<int> id,
      Value<int?> trackNo,
      required String path,
      required String title,
      Value<String?> artist,
      Value<String?> albumArtist,
      Value<String?> album,
      Value<String?> genre,
      Value<int?> year,
      Value<String?> coverPath,
      Value<DateTime?> lastModified,
      Value<bool> isIndexed,
    });
typedef $$TrackTableUpdateCompanionBuilder =
    TrackCompanion Function({
      Value<int> id,
      Value<int?> trackNo,
      Value<String> path,
      Value<String> title,
      Value<String?> artist,
      Value<String?> albumArtist,
      Value<String?> album,
      Value<String?> genre,
      Value<int?> year,
      Value<String?> coverPath,
      Value<DateTime?> lastModified,
      Value<bool> isIndexed,
    });

final class $$TrackTableReferences
    extends BaseReferences<_$Db, $TrackTable, TrackData> {
  $$TrackTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistEntryTable, List<PlaylistEntryData>>
  _playlistEntryRefsTable(_$Db db) => MultiTypedResultKey.fromTable(
    db.playlistEntry,
    aliasName: $_aliasNameGenerator(db.track.id, db.playlistEntry.trackId),
  );

  $$PlaylistEntryTableProcessedTableManager get playlistEntryRefs {
    final manager = $$PlaylistEntryTableTableManager(
      $_db,
      $_db.playlistEntry,
    ).filter((f) => f.trackId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistEntryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TrackTableFilterComposer extends Composer<_$Db, $TrackTable> {
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

  ColumnFilters<int> get trackNo => $composableBuilder(
    column: $table.trackNo,
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

  ColumnFilters<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
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

  ColumnFilters<int> get year => $composableBuilder(
    column: $table.year,
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

  Expression<bool> playlistEntryRefs(
    Expression<bool> Function($$PlaylistEntryTableFilterComposer f) f,
  ) {
    final $$PlaylistEntryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntry,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntryTableFilterComposer(
            $db: $db,
            $table: $db.playlistEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackTableOrderingComposer extends Composer<_$Db, $TrackTable> {
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

  ColumnOrderings<int> get trackNo => $composableBuilder(
    column: $table.trackNo,
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

  ColumnOrderings<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
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

  ColumnOrderings<int> get year => $composableBuilder(
    column: $table.year,
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

class $$TrackTableAnnotationComposer extends Composer<_$Db, $TrackTable> {
  $$TrackTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get trackNo =>
      $composableBuilder(column: $table.trackNo, builder: (column) => column);

  GeneratedColumn<String> get path =>
      $composableBuilder(column: $table.path, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get artist =>
      $composableBuilder(column: $table.artist, builder: (column) => column);

  GeneratedColumn<String> get albumArtist => $composableBuilder(
    column: $table.albumArtist,
    builder: (column) => column,
  );

  GeneratedColumn<String> get album =>
      $composableBuilder(column: $table.album, builder: (column) => column);

  GeneratedColumn<String> get genre =>
      $composableBuilder(column: $table.genre, builder: (column) => column);

  GeneratedColumn<int> get year =>
      $composableBuilder(column: $table.year, builder: (column) => column);

  GeneratedColumn<String> get coverPath =>
      $composableBuilder(column: $table.coverPath, builder: (column) => column);

  GeneratedColumn<DateTime> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isIndexed =>
      $composableBuilder(column: $table.isIndexed, builder: (column) => column);

  Expression<T> playlistEntryRefs<T extends Object>(
    Expression<T> Function($$PlaylistEntryTableAnnotationComposer a) f,
  ) {
    final $$PlaylistEntryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntry,
      getReferencedColumn: (t) => t.trackId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntryTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TrackTableTableManager
    extends
        RootTableManager<
          _$Db,
          $TrackTable,
          TrackData,
          $$TrackTableFilterComposer,
          $$TrackTableOrderingComposer,
          $$TrackTableAnnotationComposer,
          $$TrackTableCreateCompanionBuilder,
          $$TrackTableUpdateCompanionBuilder,
          (TrackData, $$TrackTableReferences),
          TrackData,
          PrefetchHooks Function({bool playlistEntryRefs})
        > {
  $$TrackTableTableManager(_$Db db, $TrackTable table)
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
                Value<int?> trackNo = const Value.absent(),
                Value<String> path = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String?> artist = const Value.absent(),
                Value<String?> albumArtist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<DateTime?> lastModified = const Value.absent(),
                Value<bool> isIndexed = const Value.absent(),
              }) => TrackCompanion(
                id: id,
                trackNo: trackNo,
                path: path,
                title: title,
                artist: artist,
                albumArtist: albumArtist,
                album: album,
                genre: genre,
                year: year,
                coverPath: coverPath,
                lastModified: lastModified,
                isIndexed: isIndexed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int?> trackNo = const Value.absent(),
                required String path,
                required String title,
                Value<String?> artist = const Value.absent(),
                Value<String?> albumArtist = const Value.absent(),
                Value<String?> album = const Value.absent(),
                Value<String?> genre = const Value.absent(),
                Value<int?> year = const Value.absent(),
                Value<String?> coverPath = const Value.absent(),
                Value<DateTime?> lastModified = const Value.absent(),
                Value<bool> isIndexed = const Value.absent(),
              }) => TrackCompanion.insert(
                id: id,
                trackNo: trackNo,
                path: path,
                title: title,
                artist: artist,
                albumArtist: albumArtist,
                album: album,
                genre: genre,
                year: year,
                coverPath: coverPath,
                lastModified: lastModified,
                isIndexed: isIndexed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$TrackTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback: ({playlistEntryRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistEntryRefs) db.playlistEntry,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistEntryRefs)
                    await $_getPrefetchedData<
                      TrackData,
                      $TrackTable,
                      PlaylistEntryData
                    >(
                      currentTable: table,
                      referencedTable: $$TrackTableReferences
                          ._playlistEntryRefsTable(db),
                      managerFromTypedResult: (p0) => $$TrackTableReferences(
                        db,
                        table,
                        p0,
                      ).playlistEntryRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.trackId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$TrackTableProcessedTableManager =
    ProcessedTableManager<
      _$Db,
      $TrackTable,
      TrackData,
      $$TrackTableFilterComposer,
      $$TrackTableOrderingComposer,
      $$TrackTableAnnotationComposer,
      $$TrackTableCreateCompanionBuilder,
      $$TrackTableUpdateCompanionBuilder,
      (TrackData, $$TrackTableReferences),
      TrackData,
      PrefetchHooks Function({bool playlistEntryRefs})
    >;
typedef $$PlaylistTableCreateCompanionBuilder =
    PlaylistCompanion Function({
      Value<int> id,
      required String name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastPlayed,
    });
typedef $$PlaylistTableUpdateCompanionBuilder =
    PlaylistCompanion Function({
      Value<int> id,
      Value<String> name,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> lastPlayed,
    });

final class $$PlaylistTableReferences
    extends BaseReferences<_$Db, $PlaylistTable, PlaylistData> {
  $$PlaylistTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PlaylistEntryTable, List<PlaylistEntryData>>
  _playlistEntryRefsTable(_$Db db) => MultiTypedResultKey.fromTable(
    db.playlistEntry,
    aliasName: $_aliasNameGenerator(
      db.playlist.id,
      db.playlistEntry.playlistId,
    ),
  );

  $$PlaylistEntryTableProcessedTableManager get playlistEntryRefs {
    final manager = $$PlaylistEntryTableTableManager(
      $_db,
      $_db.playlistEntry,
    ).filter((f) => f.playlistId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_playlistEntryRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlaylistTableFilterComposer extends Composer<_$Db, $PlaylistTable> {
  $$PlaylistTableFilterComposer({
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

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> playlistEntryRefs(
    Expression<bool> Function($$PlaylistEntryTableFilterComposer f) f,
  ) {
    final $$PlaylistEntryTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntry,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntryTableFilterComposer(
            $db: $db,
            $table: $db.playlistEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistTableOrderingComposer extends Composer<_$Db, $PlaylistTable> {
  $$PlaylistTableOrderingComposer({
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

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaylistTableAnnotationComposer extends Composer<_$Db, $PlaylistTable> {
  $$PlaylistTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPlayed => $composableBuilder(
    column: $table.lastPlayed,
    builder: (column) => column,
  );

  Expression<T> playlistEntryRefs<T extends Object>(
    Expression<T> Function($$PlaylistEntryTableAnnotationComposer a) f,
  ) {
    final $$PlaylistEntryTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.playlistEntry,
      getReferencedColumn: (t) => t.playlistId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistEntryTableAnnotationComposer(
            $db: $db,
            $table: $db.playlistEntry,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlaylistTableTableManager
    extends
        RootTableManager<
          _$Db,
          $PlaylistTable,
          PlaylistData,
          $$PlaylistTableFilterComposer,
          $$PlaylistTableOrderingComposer,
          $$PlaylistTableAnnotationComposer,
          $$PlaylistTableCreateCompanionBuilder,
          $$PlaylistTableUpdateCompanionBuilder,
          (PlaylistData, $$PlaylistTableReferences),
          PlaylistData,
          PrefetchHooks Function({bool playlistEntryRefs})
        > {
  $$PlaylistTableTableManager(_$Db db, $PlaylistTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
              }) => PlaylistCompanion(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastPlayed: lastPlayed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> lastPlayed = const Value.absent(),
              }) => PlaylistCompanion.insert(
                id: id,
                name: name,
                createdAt: createdAt,
                updatedAt: updatedAt,
                lastPlayed: lastPlayed,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistEntryRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (playlistEntryRefs) db.playlistEntry,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (playlistEntryRefs)
                    await $_getPrefetchedData<
                      PlaylistData,
                      $PlaylistTable,
                      PlaylistEntryData
                    >(
                      currentTable: table,
                      referencedTable: $$PlaylistTableReferences
                          ._playlistEntryRefsTable(db),
                      managerFromTypedResult: (p0) => $$PlaylistTableReferences(
                        db,
                        table,
                        p0,
                      ).playlistEntryRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.playlistId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistTableProcessedTableManager =
    ProcessedTableManager<
      _$Db,
      $PlaylistTable,
      PlaylistData,
      $$PlaylistTableFilterComposer,
      $$PlaylistTableOrderingComposer,
      $$PlaylistTableAnnotationComposer,
      $$PlaylistTableCreateCompanionBuilder,
      $$PlaylistTableUpdateCompanionBuilder,
      (PlaylistData, $$PlaylistTableReferences),
      PlaylistData,
      PrefetchHooks Function({bool playlistEntryRefs})
    >;
typedef $$PlaylistEntryTableCreateCompanionBuilder =
    PlaylistEntryCompanion Function({
      Value<int> id,
      required int playlistId,
      required int trackId,
      required int position,
    });
typedef $$PlaylistEntryTableUpdateCompanionBuilder =
    PlaylistEntryCompanion Function({
      Value<int> id,
      Value<int> playlistId,
      Value<int> trackId,
      Value<int> position,
    });

final class $$PlaylistEntryTableReferences
    extends BaseReferences<_$Db, $PlaylistEntryTable, PlaylistEntryData> {
  $$PlaylistEntryTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlaylistTable _playlistIdTable(_$Db db) => db.playlist.createAlias(
    $_aliasNameGenerator(db.playlistEntry.playlistId, db.playlist.id),
  );

  $$PlaylistTableProcessedTableManager get playlistId {
    final $_column = $_itemColumn<int>('playlist_id')!;

    final manager = $$PlaylistTableTableManager(
      $_db,
      $_db.playlist,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_playlistIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $TrackTable _trackIdTable(_$Db db) => db.track.createAlias(
    $_aliasNameGenerator(db.playlistEntry.trackId, db.track.id),
  );

  $$TrackTableProcessedTableManager get trackId {
    final $_column = $_itemColumn<int>('track_id')!;

    final manager = $$TrackTableTableManager(
      $_db,
      $_db.track,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_trackIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlaylistEntryTableFilterComposer
    extends Composer<_$Db, $PlaylistEntryTable> {
  $$PlaylistEntryTableFilterComposer({
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

  ColumnFilters<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnFilters(column),
  );

  $$PlaylistTableFilterComposer get playlistId {
    final $$PlaylistTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlist,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableFilterComposer(
            $db: $db,
            $table: $db.playlist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackTableFilterComposer get trackId {
    final $$TrackTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.track,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableFilterComposer(
            $db: $db,
            $table: $db.track,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntryTableOrderingComposer
    extends Composer<_$Db, $PlaylistEntryTable> {
  $$PlaylistEntryTableOrderingComposer({
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

  ColumnOrderings<int> get position => $composableBuilder(
    column: $table.position,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlaylistTableOrderingComposer get playlistId {
    final $$PlaylistTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlist,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableOrderingComposer(
            $db: $db,
            $table: $db.playlist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackTableOrderingComposer get trackId {
    final $$TrackTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.track,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableOrderingComposer(
            $db: $db,
            $table: $db.track,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntryTableAnnotationComposer
    extends Composer<_$Db, $PlaylistEntryTable> {
  $$PlaylistEntryTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get position =>
      $composableBuilder(column: $table.position, builder: (column) => column);

  $$PlaylistTableAnnotationComposer get playlistId {
    final $$PlaylistTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.playlistId,
      referencedTable: $db.playlist,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlaylistTableAnnotationComposer(
            $db: $db,
            $table: $db.playlist,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$TrackTableAnnotationComposer get trackId {
    final $$TrackTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.trackId,
      referencedTable: $db.track,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TrackTableAnnotationComposer(
            $db: $db,
            $table: $db.track,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlaylistEntryTableTableManager
    extends
        RootTableManager<
          _$Db,
          $PlaylistEntryTable,
          PlaylistEntryData,
          $$PlaylistEntryTableFilterComposer,
          $$PlaylistEntryTableOrderingComposer,
          $$PlaylistEntryTableAnnotationComposer,
          $$PlaylistEntryTableCreateCompanionBuilder,
          $$PlaylistEntryTableUpdateCompanionBuilder,
          (PlaylistEntryData, $$PlaylistEntryTableReferences),
          PlaylistEntryData,
          PrefetchHooks Function({bool playlistId, bool trackId})
        > {
  $$PlaylistEntryTableTableManager(_$Db db, $PlaylistEntryTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaylistEntryTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlaylistEntryTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlaylistEntryTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> playlistId = const Value.absent(),
                Value<int> trackId = const Value.absent(),
                Value<int> position = const Value.absent(),
              }) => PlaylistEntryCompanion(
                id: id,
                playlistId: playlistId,
                trackId: trackId,
                position: position,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int playlistId,
                required int trackId,
                required int position,
              }) => PlaylistEntryCompanion.insert(
                id: id,
                playlistId: playlistId,
                trackId: trackId,
                position: position,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PlaylistEntryTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({playlistId = false, trackId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (playlistId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.playlistId,
                                referencedTable: $$PlaylistEntryTableReferences
                                    ._playlistIdTable(db),
                                referencedColumn: $$PlaylistEntryTableReferences
                                    ._playlistIdTable(db)
                                    .id,
                              )
                              as T;
                    }
                    if (trackId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.trackId,
                                referencedTable: $$PlaylistEntryTableReferences
                                    ._trackIdTable(db),
                                referencedColumn: $$PlaylistEntryTableReferences
                                    ._trackIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlaylistEntryTableProcessedTableManager =
    ProcessedTableManager<
      _$Db,
      $PlaylistEntryTable,
      PlaylistEntryData,
      $$PlaylistEntryTableFilterComposer,
      $$PlaylistEntryTableOrderingComposer,
      $$PlaylistEntryTableAnnotationComposer,
      $$PlaylistEntryTableCreateCompanionBuilder,
      $$PlaylistEntryTableUpdateCompanionBuilder,
      (PlaylistEntryData, $$PlaylistEntryTableReferences),
      PlaylistEntryData,
      PrefetchHooks Function({bool playlistId, bool trackId})
    >;

class $DbManager {
  final _$Db _db;
  $DbManager(this._db);
  $$TrackTableTableManager get track =>
      $$TrackTableTableManager(_db, _db.track);
  $$PlaylistTableTableManager get playlist =>
      $$PlaylistTableTableManager(_db, _db.playlist);
  $$PlaylistEntryTableTableManager get playlistEntry =>
      $$PlaylistEntryTableTableManager(_db, _db.playlistEntry);
}
