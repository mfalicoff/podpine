// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $PodcastRowsTable extends PodcastRows
    with TableInfo<$PodcastRowsTable, PodcastRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
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
  static const VerificationMeta _authorMeta = const VerificationMeta('author');
  @override
  late final GeneratedColumn<String> author = GeneratedColumn<String>(
    'author',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _episodeCountMeta = const VerificationMeta(
    'episodeCount',
  );
  @override
  late final GeneratedColumn<int> episodeCount = GeneratedColumn<int>(
    'episode_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    title,
    author,
    artworkUrl,
    description,
    feedUrl,
    episodeCount,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PodcastRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('author')) {
      context.handle(
        _authorMeta,
        author.isAcceptableOrUnknown(data['author']!, _authorMeta),
      );
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    }
    if (data.containsKey('episode_count')) {
      context.handle(
        _episodeCountMeta,
        episodeCount.isAcceptableOrUnknown(
          data['episode_count']!,
          _episodeCountMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PodcastRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      author: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}author'],
      )!,
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      episodeCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_count'],
      )!,
    );
  }

  @override
  $PodcastRowsTable createAlias(String alias) {
    return $PodcastRowsTable(attachedDatabase, alias);
  }
}

class PodcastRecord extends DataClass implements Insertable<PodcastRecord> {
  final int id;
  final String title;
  final String author;
  final String artworkUrl;
  final String description;
  final String feedUrl;
  final int episodeCount;
  const PodcastRecord({
    required this.id,
    required this.title,
    required this.author,
    required this.artworkUrl,
    required this.description,
    required this.feedUrl,
    required this.episodeCount,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['title'] = Variable<String>(title);
    map['author'] = Variable<String>(author);
    map['artwork_url'] = Variable<String>(artworkUrl);
    map['description'] = Variable<String>(description);
    map['feed_url'] = Variable<String>(feedUrl);
    map['episode_count'] = Variable<int>(episodeCount);
    return map;
  }

  PodcastRowsCompanion toCompanion(bool nullToAbsent) {
    return PodcastRowsCompanion(
      id: Value(id),
      title: Value(title),
      author: Value(author),
      artworkUrl: Value(artworkUrl),
      description: Value(description),
      feedUrl: Value(feedUrl),
      episodeCount: Value(episodeCount),
    );
  }

  factory PodcastRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastRecord(
      id: serializer.fromJson<int>(json['id']),
      title: serializer.fromJson<String>(json['title']),
      author: serializer.fromJson<String>(json['author']),
      artworkUrl: serializer.fromJson<String>(json['artworkUrl']),
      description: serializer.fromJson<String>(json['description']),
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      episodeCount: serializer.fromJson<int>(json['episodeCount']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'title': serializer.toJson<String>(title),
      'author': serializer.toJson<String>(author),
      'artworkUrl': serializer.toJson<String>(artworkUrl),
      'description': serializer.toJson<String>(description),
      'feedUrl': serializer.toJson<String>(feedUrl),
      'episodeCount': serializer.toJson<int>(episodeCount),
    };
  }

  PodcastRecord copyWith({
    int? id,
    String? title,
    String? author,
    String? artworkUrl,
    String? description,
    String? feedUrl,
    int? episodeCount,
  }) => PodcastRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    artworkUrl: artworkUrl ?? this.artworkUrl,
    description: description ?? this.description,
    feedUrl: feedUrl ?? this.feedUrl,
    episodeCount: episodeCount ?? this.episodeCount,
  );
  PodcastRecord copyWithCompanion(PodcastRowsCompanion data) {
    return PodcastRecord(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      author: data.author.present ? data.author.value : this.author,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      description: data.description.present
          ? data.description.value
          : this.description,
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      episodeCount: data.episodeCount.present
          ? data.episodeCount.value
          : this.episodeCount,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastRecord(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('description: $description, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('episodeCount: $episodeCount')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    title,
    author,
    artworkUrl,
    description,
    feedUrl,
    episodeCount,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastRecord &&
          other.id == this.id &&
          other.title == this.title &&
          other.author == this.author &&
          other.artworkUrl == this.artworkUrl &&
          other.description == this.description &&
          other.feedUrl == this.feedUrl &&
          other.episodeCount == this.episodeCount);
}

class PodcastRowsCompanion extends UpdateCompanion<PodcastRecord> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String> artworkUrl;
  final Value<String> description;
  final Value<String> feedUrl;
  final Value<int> episodeCount;
  const PodcastRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.episodeCount = const Value.absent(),
  });
  PodcastRowsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.episodeCount = const Value.absent(),
  }) : title = Value(title);
  static Insertable<PodcastRecord> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? artworkUrl,
    Expression<String>? description,
    Expression<String>? feedUrl,
    Expression<int>? episodeCount,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (description != null) 'description': description,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (episodeCount != null) 'episode_count': episodeCount,
    });
  }

  PodcastRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? title,
    Value<String>? author,
    Value<String>? artworkUrl,
    Value<String>? description,
    Value<String>? feedUrl,
    Value<int>? episodeCount,
  }) {
    return PodcastRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      description: description ?? this.description,
      feedUrl: feedUrl ?? this.feedUrl,
      episodeCount: episodeCount ?? this.episodeCount,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (author.present) {
      map['author'] = Variable<String>(author.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (episodeCount.present) {
      map['episode_count'] = Variable<int>(episodeCount.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastRowsCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('author: $author, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('description: $description, ')
          ..write('feedUrl: $feedUrl, ')
          ..write('episodeCount: $episodeCount')
          ..write(')'))
        .toString();
  }
}

class $EpisodeRowsTable extends EpisodeRows
    with TableInfo<$EpisodeRowsTable, EpisodeRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $EpisodeRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _podcastIdMeta = const VerificationMeta(
    'podcastId',
  );
  @override
  late final GeneratedColumn<int> podcastId = GeneratedColumn<int>(
    'podcast_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES podcast_rows (id)',
    ),
  );
  static const VerificationMeta _podcastTitleMeta = const VerificationMeta(
    'podcastTitle',
  );
  @override
  late final GeneratedColumn<String> podcastTitle = GeneratedColumn<String>(
    'podcast_title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _artworkUrlMeta = const VerificationMeta(
    'artworkUrl',
  );
  @override
  late final GeneratedColumn<String> artworkUrl = GeneratedColumn<String>(
    'artwork_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _audioUrlMeta = const VerificationMeta(
    'audioUrl',
  );
  @override
  late final GeneratedColumn<String> audioUrl = GeneratedColumn<String>(
    'audio_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _publishedAtMeta = const VerificationMeta(
    'publishedAt',
  );
  @override
  late final GeneratedColumn<DateTime> publishedAt = GeneratedColumn<DateTime>(
    'published_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _durationSecondsMeta = const VerificationMeta(
    'durationSeconds',
  );
  @override
  late final GeneratedColumn<int> durationSeconds = GeneratedColumn<int>(
    'duration_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _positionSecondsMeta = const VerificationMeta(
    'positionSeconds',
  );
  @override
  late final GeneratedColumn<int> positionSeconds = GeneratedColumn<int>(
    'position_seconds',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _completedMeta = const VerificationMeta(
    'completed',
  );
  @override
  late final GeneratedColumn<bool> completed = GeneratedColumn<bool>(
    'completed',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("completed" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _queuedMeta = const VerificationMeta('queued');
  @override
  late final GeneratedColumn<bool> queued = GeneratedColumn<bool>(
    'queued',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("queued" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _downloadedMeta = const VerificationMeta(
    'downloaded',
  );
  @override
  late final GeneratedColumn<bool> downloaded = GeneratedColumn<bool>(
    'downloaded',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("downloaded" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isYoutubeMeta = const VerificationMeta(
    'isYoutube',
  );
  @override
  late final GeneratedColumn<bool> isYoutube = GeneratedColumn<bool>(
    'is_youtube',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_youtube" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    podcastId,
    podcastTitle,
    title,
    description,
    artworkUrl,
    audioUrl,
    publishedAt,
    durationSeconds,
    positionSeconds,
    completed,
    queued,
    downloaded,
    isYoutube,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'episode_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<EpisodeRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('podcast_id')) {
      context.handle(
        _podcastIdMeta,
        podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta),
      );
    } else if (isInserting) {
      context.missing(_podcastIdMeta);
    }
    if (data.containsKey('podcast_title')) {
      context.handle(
        _podcastTitleMeta,
        podcastTitle.isAcceptableOrUnknown(
          data['podcast_title']!,
          _podcastTitleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_podcastTitleMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('artwork_url')) {
      context.handle(
        _artworkUrlMeta,
        artworkUrl.isAcceptableOrUnknown(data['artwork_url']!, _artworkUrlMeta),
      );
    }
    if (data.containsKey('audio_url')) {
      context.handle(
        _audioUrlMeta,
        audioUrl.isAcceptableOrUnknown(data['audio_url']!, _audioUrlMeta),
      );
    }
    if (data.containsKey('published_at')) {
      context.handle(
        _publishedAtMeta,
        publishedAt.isAcceptableOrUnknown(
          data['published_at']!,
          _publishedAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_publishedAtMeta);
    }
    if (data.containsKey('duration_seconds')) {
      context.handle(
        _durationSecondsMeta,
        durationSeconds.isAcceptableOrUnknown(
          data['duration_seconds']!,
          _durationSecondsMeta,
        ),
      );
    }
    if (data.containsKey('position_seconds')) {
      context.handle(
        _positionSecondsMeta,
        positionSeconds.isAcceptableOrUnknown(
          data['position_seconds']!,
          _positionSecondsMeta,
        ),
      );
    }
    if (data.containsKey('completed')) {
      context.handle(
        _completedMeta,
        completed.isAcceptableOrUnknown(data['completed']!, _completedMeta),
      );
    }
    if (data.containsKey('queued')) {
      context.handle(
        _queuedMeta,
        queued.isAcceptableOrUnknown(data['queued']!, _queuedMeta),
      );
    }
    if (data.containsKey('downloaded')) {
      context.handle(
        _downloadedMeta,
        downloaded.isAcceptableOrUnknown(data['downloaded']!, _downloadedMeta),
      );
    }
    if (data.containsKey('is_youtube')) {
      context.handle(
        _isYoutubeMeta,
        isYoutube.isAcceptableOrUnknown(data['is_youtube']!, _isYoutubeMeta),
      );
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  EpisodeRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return EpisodeRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      podcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}podcast_id'],
      )!,
      podcastTitle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}podcast_title'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      )!,
      artworkUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}artwork_url'],
      )!,
      audioUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}audio_url'],
      )!,
      publishedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}published_at'],
      )!,
      durationSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}duration_seconds'],
      )!,
      positionSeconds: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}position_seconds'],
      )!,
      completed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}completed'],
      )!,
      queued: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}queued'],
      )!,
      downloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}downloaded'],
      )!,
      isYoutube: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_youtube'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $EpisodeRowsTable createAlias(String alias) {
    return $EpisodeRowsTable(attachedDatabase, alias);
  }
}

class EpisodeRecord extends DataClass implements Insertable<EpisodeRecord> {
  final int id;
  final int podcastId;
  final String podcastTitle;
  final String title;
  final String description;
  final String artworkUrl;
  final String audioUrl;
  final DateTime publishedAt;
  final int durationSeconds;
  final int positionSeconds;
  final bool completed;
  final bool queued;
  final bool downloaded;
  final bool isYoutube;
  final DateTime updatedAt;
  const EpisodeRecord({
    required this.id,
    required this.podcastId,
    required this.podcastTitle,
    required this.title,
    required this.description,
    required this.artworkUrl,
    required this.audioUrl,
    required this.publishedAt,
    required this.durationSeconds,
    required this.positionSeconds,
    required this.completed,
    required this.queued,
    required this.downloaded,
    required this.isYoutube,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['podcast_id'] = Variable<int>(podcastId);
    map['podcast_title'] = Variable<String>(podcastTitle);
    map['title'] = Variable<String>(title);
    map['description'] = Variable<String>(description);
    map['artwork_url'] = Variable<String>(artworkUrl);
    map['audio_url'] = Variable<String>(audioUrl);
    map['published_at'] = Variable<DateTime>(publishedAt);
    map['duration_seconds'] = Variable<int>(durationSeconds);
    map['position_seconds'] = Variable<int>(positionSeconds);
    map['completed'] = Variable<bool>(completed);
    map['queued'] = Variable<bool>(queued);
    map['downloaded'] = Variable<bool>(downloaded);
    map['is_youtube'] = Variable<bool>(isYoutube);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  EpisodeRowsCompanion toCompanion(bool nullToAbsent) {
    return EpisodeRowsCompanion(
      id: Value(id),
      podcastId: Value(podcastId),
      podcastTitle: Value(podcastTitle),
      title: Value(title),
      description: Value(description),
      artworkUrl: Value(artworkUrl),
      audioUrl: Value(audioUrl),
      publishedAt: Value(publishedAt),
      durationSeconds: Value(durationSeconds),
      positionSeconds: Value(positionSeconds),
      completed: Value(completed),
      queued: Value(queued),
      downloaded: Value(downloaded),
      isYoutube: Value(isYoutube),
      updatedAt: Value(updatedAt),
    );
  }

  factory EpisodeRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return EpisodeRecord(
      id: serializer.fromJson<int>(json['id']),
      podcastId: serializer.fromJson<int>(json['podcastId']),
      podcastTitle: serializer.fromJson<String>(json['podcastTitle']),
      title: serializer.fromJson<String>(json['title']),
      description: serializer.fromJson<String>(json['description']),
      artworkUrl: serializer.fromJson<String>(json['artworkUrl']),
      audioUrl: serializer.fromJson<String>(json['audioUrl']),
      publishedAt: serializer.fromJson<DateTime>(json['publishedAt']),
      durationSeconds: serializer.fromJson<int>(json['durationSeconds']),
      positionSeconds: serializer.fromJson<int>(json['positionSeconds']),
      completed: serializer.fromJson<bool>(json['completed']),
      queued: serializer.fromJson<bool>(json['queued']),
      downloaded: serializer.fromJson<bool>(json['downloaded']),
      isYoutube: serializer.fromJson<bool>(json['isYoutube']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'podcastId': serializer.toJson<int>(podcastId),
      'podcastTitle': serializer.toJson<String>(podcastTitle),
      'title': serializer.toJson<String>(title),
      'description': serializer.toJson<String>(description),
      'artworkUrl': serializer.toJson<String>(artworkUrl),
      'audioUrl': serializer.toJson<String>(audioUrl),
      'publishedAt': serializer.toJson<DateTime>(publishedAt),
      'durationSeconds': serializer.toJson<int>(durationSeconds),
      'positionSeconds': serializer.toJson<int>(positionSeconds),
      'completed': serializer.toJson<bool>(completed),
      'queued': serializer.toJson<bool>(queued),
      'downloaded': serializer.toJson<bool>(downloaded),
      'isYoutube': serializer.toJson<bool>(isYoutube),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  EpisodeRecord copyWith({
    int? id,
    int? podcastId,
    String? podcastTitle,
    String? title,
    String? description,
    String? artworkUrl,
    String? audioUrl,
    DateTime? publishedAt,
    int? durationSeconds,
    int? positionSeconds,
    bool? completed,
    bool? queued,
    bool? downloaded,
    bool? isYoutube,
    DateTime? updatedAt,
  }) => EpisodeRecord(
    id: id ?? this.id,
    podcastId: podcastId ?? this.podcastId,
    podcastTitle: podcastTitle ?? this.podcastTitle,
    title: title ?? this.title,
    description: description ?? this.description,
    artworkUrl: artworkUrl ?? this.artworkUrl,
    audioUrl: audioUrl ?? this.audioUrl,
    publishedAt: publishedAt ?? this.publishedAt,
    durationSeconds: durationSeconds ?? this.durationSeconds,
    positionSeconds: positionSeconds ?? this.positionSeconds,
    completed: completed ?? this.completed,
    queued: queued ?? this.queued,
    downloaded: downloaded ?? this.downloaded,
    isYoutube: isYoutube ?? this.isYoutube,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  EpisodeRecord copyWithCompanion(EpisodeRowsCompanion data) {
    return EpisodeRecord(
      id: data.id.present ? data.id.value : this.id,
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      podcastTitle: data.podcastTitle.present
          ? data.podcastTitle.value
          : this.podcastTitle,
      title: data.title.present ? data.title.value : this.title,
      description: data.description.present
          ? data.description.value
          : this.description,
      artworkUrl: data.artworkUrl.present
          ? data.artworkUrl.value
          : this.artworkUrl,
      audioUrl: data.audioUrl.present ? data.audioUrl.value : this.audioUrl,
      publishedAt: data.publishedAt.present
          ? data.publishedAt.value
          : this.publishedAt,
      durationSeconds: data.durationSeconds.present
          ? data.durationSeconds.value
          : this.durationSeconds,
      positionSeconds: data.positionSeconds.present
          ? data.positionSeconds.value
          : this.positionSeconds,
      completed: data.completed.present ? data.completed.value : this.completed,
      queued: data.queued.present ? data.queued.value : this.queued,
      downloaded: data.downloaded.present
          ? data.downloaded.value
          : this.downloaded,
      isYoutube: data.isYoutube.present ? data.isYoutube.value : this.isYoutube,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeRecord(')
          ..write('id: $id, ')
          ..write('podcastId: $podcastId, ')
          ..write('podcastTitle: $podcastTitle, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('positionSeconds: $positionSeconds, ')
          ..write('completed: $completed, ')
          ..write('queued: $queued, ')
          ..write('downloaded: $downloaded, ')
          ..write('isYoutube: $isYoutube, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    podcastId,
    podcastTitle,
    title,
    description,
    artworkUrl,
    audioUrl,
    publishedAt,
    durationSeconds,
    positionSeconds,
    completed,
    queued,
    downloaded,
    isYoutube,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is EpisodeRecord &&
          other.id == this.id &&
          other.podcastId == this.podcastId &&
          other.podcastTitle == this.podcastTitle &&
          other.title == this.title &&
          other.description == this.description &&
          other.artworkUrl == this.artworkUrl &&
          other.audioUrl == this.audioUrl &&
          other.publishedAt == this.publishedAt &&
          other.durationSeconds == this.durationSeconds &&
          other.positionSeconds == this.positionSeconds &&
          other.completed == this.completed &&
          other.queued == this.queued &&
          other.downloaded == this.downloaded &&
          other.isYoutube == this.isYoutube &&
          other.updatedAt == this.updatedAt);
}

class EpisodeRowsCompanion extends UpdateCompanion<EpisodeRecord> {
  final Value<int> id;
  final Value<int> podcastId;
  final Value<String> podcastTitle;
  final Value<String> title;
  final Value<String> description;
  final Value<String> artworkUrl;
  final Value<String> audioUrl;
  final Value<DateTime> publishedAt;
  final Value<int> durationSeconds;
  final Value<int> positionSeconds;
  final Value<bool> completed;
  final Value<bool> queued;
  final Value<bool> downloaded;
  final Value<bool> isYoutube;
  final Value<DateTime> updatedAt;
  const EpisodeRowsCompanion({
    this.id = const Value.absent(),
    this.podcastId = const Value.absent(),
    this.podcastTitle = const Value.absent(),
    this.title = const Value.absent(),
    this.description = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.audioUrl = const Value.absent(),
    this.publishedAt = const Value.absent(),
    this.durationSeconds = const Value.absent(),
    this.positionSeconds = const Value.absent(),
    this.completed = const Value.absent(),
    this.queued = const Value.absent(),
    this.downloaded = const Value.absent(),
    this.isYoutube = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  EpisodeRowsCompanion.insert({
    this.id = const Value.absent(),
    required int podcastId,
    required String podcastTitle,
    required String title,
    this.description = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.audioUrl = const Value.absent(),
    required DateTime publishedAt,
    this.durationSeconds = const Value.absent(),
    this.positionSeconds = const Value.absent(),
    this.completed = const Value.absent(),
    this.queued = const Value.absent(),
    this.downloaded = const Value.absent(),
    this.isYoutube = const Value.absent(),
    required DateTime updatedAt,
  }) : podcastId = Value(podcastId),
       podcastTitle = Value(podcastTitle),
       title = Value(title),
       publishedAt = Value(publishedAt),
       updatedAt = Value(updatedAt);
  static Insertable<EpisodeRecord> custom({
    Expression<int>? id,
    Expression<int>? podcastId,
    Expression<String>? podcastTitle,
    Expression<String>? title,
    Expression<String>? description,
    Expression<String>? artworkUrl,
    Expression<String>? audioUrl,
    Expression<DateTime>? publishedAt,
    Expression<int>? durationSeconds,
    Expression<int>? positionSeconds,
    Expression<bool>? completed,
    Expression<bool>? queued,
    Expression<bool>? downloaded,
    Expression<bool>? isYoutube,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (podcastId != null) 'podcast_id': podcastId,
      if (podcastTitle != null) 'podcast_title': podcastTitle,
      if (title != null) 'title': title,
      if (description != null) 'description': description,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (audioUrl != null) 'audio_url': audioUrl,
      if (publishedAt != null) 'published_at': publishedAt,
      if (durationSeconds != null) 'duration_seconds': durationSeconds,
      if (positionSeconds != null) 'position_seconds': positionSeconds,
      if (completed != null) 'completed': completed,
      if (queued != null) 'queued': queued,
      if (downloaded != null) 'downloaded': downloaded,
      if (isYoutube != null) 'is_youtube': isYoutube,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  EpisodeRowsCompanion copyWith({
    Value<int>? id,
    Value<int>? podcastId,
    Value<String>? podcastTitle,
    Value<String>? title,
    Value<String>? description,
    Value<String>? artworkUrl,
    Value<String>? audioUrl,
    Value<DateTime>? publishedAt,
    Value<int>? durationSeconds,
    Value<int>? positionSeconds,
    Value<bool>? completed,
    Value<bool>? queued,
    Value<bool>? downloaded,
    Value<bool>? isYoutube,
    Value<DateTime>? updatedAt,
  }) {
    return EpisodeRowsCompanion(
      id: id ?? this.id,
      podcastId: podcastId ?? this.podcastId,
      podcastTitle: podcastTitle ?? this.podcastTitle,
      title: title ?? this.title,
      description: description ?? this.description,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      audioUrl: audioUrl ?? this.audioUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      durationSeconds: durationSeconds ?? this.durationSeconds,
      positionSeconds: positionSeconds ?? this.positionSeconds,
      completed: completed ?? this.completed,
      queued: queued ?? this.queued,
      downloaded: downloaded ?? this.downloaded,
      isYoutube: isYoutube ?? this.isYoutube,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (podcastId.present) {
      map['podcast_id'] = Variable<int>(podcastId.value);
    }
    if (podcastTitle.present) {
      map['podcast_title'] = Variable<String>(podcastTitle.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (artworkUrl.present) {
      map['artwork_url'] = Variable<String>(artworkUrl.value);
    }
    if (audioUrl.present) {
      map['audio_url'] = Variable<String>(audioUrl.value);
    }
    if (publishedAt.present) {
      map['published_at'] = Variable<DateTime>(publishedAt.value);
    }
    if (durationSeconds.present) {
      map['duration_seconds'] = Variable<int>(durationSeconds.value);
    }
    if (positionSeconds.present) {
      map['position_seconds'] = Variable<int>(positionSeconds.value);
    }
    if (completed.present) {
      map['completed'] = Variable<bool>(completed.value);
    }
    if (queued.present) {
      map['queued'] = Variable<bool>(queued.value);
    }
    if (downloaded.present) {
      map['downloaded'] = Variable<bool>(downloaded.value);
    }
    if (isYoutube.present) {
      map['is_youtube'] = Variable<bool>(isYoutube.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('EpisodeRowsCompanion(')
          ..write('id: $id, ')
          ..write('podcastId: $podcastId, ')
          ..write('podcastTitle: $podcastTitle, ')
          ..write('title: $title, ')
          ..write('description: $description, ')
          ..write('artworkUrl: $artworkUrl, ')
          ..write('audioUrl: $audioUrl, ')
          ..write('publishedAt: $publishedAt, ')
          ..write('durationSeconds: $durationSeconds, ')
          ..write('positionSeconds: $positionSeconds, ')
          ..write('completed: $completed, ')
          ..write('queued: $queued, ')
          ..write('downloaded: $downloaded, ')
          ..write('isYoutube: $isYoutube, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $QueueRowsTable extends QueueRows
    with TableInfo<$QueueRowsTable, QueueRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES episode_rows (id)',
    ),
  );
  static const VerificationMeta _sortKeyMeta = const VerificationMeta(
    'sortKey',
  );
  @override
  late final GeneratedColumn<double> sortKey = GeneratedColumn<double>(
    'sort_key',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _addedAtMeta = const VerificationMeta(
    'addedAt',
  );
  @override
  late final GeneratedColumn<DateTime> addedAt = GeneratedColumn<DateTime>(
    'added_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [episodeId, sortKey, addedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    }
    if (data.containsKey('sort_key')) {
      context.handle(
        _sortKeyMeta,
        sortKey.isAcceptableOrUnknown(data['sort_key']!, _sortKeyMeta),
      );
    } else if (isInserting) {
      context.missing(_sortKeyMeta);
    }
    if (data.containsKey('added_at')) {
      context.handle(
        _addedAtMeta,
        addedAt.isAcceptableOrUnknown(data['added_at']!, _addedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_addedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  QueueRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueRecord(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      sortKey: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}sort_key'],
      )!,
      addedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}added_at'],
      )!,
    );
  }

  @override
  $QueueRowsTable createAlias(String alias) {
    return $QueueRowsTable(attachedDatabase, alias);
  }
}

class QueueRecord extends DataClass implements Insertable<QueueRecord> {
  final int episodeId;
  final double sortKey;
  final DateTime addedAt;
  const QueueRecord({
    required this.episodeId,
    required this.sortKey,
    required this.addedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<int>(episodeId);
    map['sort_key'] = Variable<double>(sortKey);
    map['added_at'] = Variable<DateTime>(addedAt);
    return map;
  }

  QueueRowsCompanion toCompanion(bool nullToAbsent) {
    return QueueRowsCompanion(
      episodeId: Value(episodeId),
      sortKey: Value(sortKey),
      addedAt: Value(addedAt),
    );
  }

  factory QueueRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueRecord(
      episodeId: serializer.fromJson<int>(json['episodeId']),
      sortKey: serializer.fromJson<double>(json['sortKey']),
      addedAt: serializer.fromJson<DateTime>(json['addedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<int>(episodeId),
      'sortKey': serializer.toJson<double>(sortKey),
      'addedAt': serializer.toJson<DateTime>(addedAt),
    };
  }

  QueueRecord copyWith({int? episodeId, double? sortKey, DateTime? addedAt}) =>
      QueueRecord(
        episodeId: episodeId ?? this.episodeId,
        sortKey: sortKey ?? this.sortKey,
        addedAt: addedAt ?? this.addedAt,
      );
  QueueRecord copyWithCompanion(QueueRowsCompanion data) {
    return QueueRecord(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      sortKey: data.sortKey.present ? data.sortKey.value : this.sortKey,
      addedAt: data.addedAt.present ? data.addedAt.value : this.addedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueRecord(')
          ..write('episodeId: $episodeId, ')
          ..write('sortKey: $sortKey, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(episodeId, sortKey, addedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueRecord &&
          other.episodeId == this.episodeId &&
          other.sortKey == this.sortKey &&
          other.addedAt == this.addedAt);
}

class QueueRowsCompanion extends UpdateCompanion<QueueRecord> {
  final Value<int> episodeId;
  final Value<double> sortKey;
  final Value<DateTime> addedAt;
  const QueueRowsCompanion({
    this.episodeId = const Value.absent(),
    this.sortKey = const Value.absent(),
    this.addedAt = const Value.absent(),
  });
  QueueRowsCompanion.insert({
    this.episodeId = const Value.absent(),
    required double sortKey,
    required DateTime addedAt,
  }) : sortKey = Value(sortKey),
       addedAt = Value(addedAt);
  static Insertable<QueueRecord> custom({
    Expression<int>? episodeId,
    Expression<double>? sortKey,
    Expression<DateTime>? addedAt,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (sortKey != null) 'sort_key': sortKey,
      if (addedAt != null) 'added_at': addedAt,
    });
  }

  QueueRowsCompanion copyWith({
    Value<int>? episodeId,
    Value<double>? sortKey,
    Value<DateTime>? addedAt,
  }) {
    return QueueRowsCompanion(
      episodeId: episodeId ?? this.episodeId,
      sortKey: sortKey ?? this.sortKey,
      addedAt: addedAt ?? this.addedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (sortKey.present) {
      map['sort_key'] = Variable<double>(sortKey.value);
    }
    if (addedAt.present) {
      map['added_at'] = Variable<DateTime>(addedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueRowsCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('sortKey: $sortKey, ')
          ..write('addedAt: $addedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncMutationsTable extends SyncMutations
    with TableInfo<$SyncMutationsTable, PendingMutation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncMutationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _typeMeta = const VerificationMeta('type');
  @override
  late final GeneratedColumn<String> type = GeneratedColumn<String>(
    'type',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodeIdMeta = const VerificationMeta(
    'episodeId',
  );
  @override
  late final GeneratedColumn<int> episodeId = GeneratedColumn<int>(
    'episode_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
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
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    episodeId,
    payload,
    createdAt,
    attempts,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_mutations';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingMutation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('type')) {
      context.handle(
        _typeMeta,
        type.isAcceptableOrUnknown(data['type']!, _typeMeta),
      );
    } else if (isInserting) {
      context.missing(_typeMeta);
    }
    if (data.containsKey('episode_id')) {
      context.handle(
        _episodeIdMeta,
        episodeId.isAcceptableOrUnknown(data['episode_id']!, _episodeIdMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PendingMutation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingMutation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      type: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}type'],
      )!,
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
    );
  }

  @override
  $SyncMutationsTable createAlias(String alias) {
    return $SyncMutationsTable(attachedDatabase, alias);
  }
}

class PendingMutation extends DataClass implements Insertable<PendingMutation> {
  final String id;
  final String type;
  final int? episodeId;
  final String payload;
  final DateTime createdAt;
  final int attempts;
  const PendingMutation({
    required this.id,
    required this.type,
    this.episodeId,
    required this.payload,
    required this.createdAt,
    required this.attempts,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['type'] = Variable<String>(type);
    if (!nullToAbsent || episodeId != null) {
      map['episode_id'] = Variable<int>(episodeId);
    }
    map['payload'] = Variable<String>(payload);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    return map;
  }

  SyncMutationsCompanion toCompanion(bool nullToAbsent) {
    return SyncMutationsCompanion(
      id: Value(id),
      type: Value(type),
      episodeId: episodeId == null && nullToAbsent
          ? const Value.absent()
          : Value(episodeId),
      payload: Value(payload),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
    );
  }

  factory PendingMutation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingMutation(
      id: serializer.fromJson<String>(json['id']),
      type: serializer.fromJson<String>(json['type']),
      episodeId: serializer.fromJson<int?>(json['episodeId']),
      payload: serializer.fromJson<String>(json['payload']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'type': serializer.toJson<String>(type),
      'episodeId': serializer.toJson<int?>(episodeId),
      'payload': serializer.toJson<String>(payload),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
    };
  }

  PendingMutation copyWith({
    String? id,
    String? type,
    Value<int?> episodeId = const Value.absent(),
    String? payload,
    DateTime? createdAt,
    int? attempts,
  }) => PendingMutation(
    id: id ?? this.id,
    type: type ?? this.type,
    episodeId: episodeId.present ? episodeId.value : this.episodeId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
  );
  PendingMutation copyWithCompanion(SyncMutationsCompanion data) {
    return PendingMutation(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingMutation(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('episodeId: $episodeId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, type, episodeId, payload, createdAt, attempts);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingMutation &&
          other.id == this.id &&
          other.type == this.type &&
          other.episodeId == this.episodeId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts);
}

class SyncMutationsCompanion extends UpdateCompanion<PendingMutation> {
  final Value<String> id;
  final Value<String> type;
  final Value<int?> episodeId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<int> rowid;
  const SyncMutationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMutationsCompanion.insert({
    required String id,
    required String type,
    this.episodeId = const Value.absent(),
    this.payload = const Value.absent(),
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       type = Value(type),
       createdAt = Value(createdAt);
  static Insertable<PendingMutation> custom({
    Expression<String>? id,
    Expression<String>? type,
    Expression<int>? episodeId,
    Expression<String>? payload,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (episodeId != null) 'episode_id': episodeId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncMutationsCompanion copyWith({
    Value<String>? id,
    Value<String>? type,
    Value<int?>? episodeId,
    Value<String>? payload,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<int>? rowid,
  }) {
    return SyncMutationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      episodeId: episodeId ?? this.episodeId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (type.present) {
      map['type'] = Variable<String>(type.value);
    }
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncMutationsCompanion(')
          ..write('id: $id, ')
          ..write('type: $type, ')
          ..write('episodeId: $episodeId, ')
          ..write('payload: $payload, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PodcastRowsTable podcastRows = $PodcastRowsTable(this);
  late final $EpisodeRowsTable episodeRows = $EpisodeRowsTable(this);
  late final $QueueRowsTable queueRows = $QueueRowsTable(this);
  late final $SyncMutationsTable syncMutations = $SyncMutationsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    podcastRows,
    episodeRows,
    queueRows,
    syncMutations,
  ];
}

typedef $$PodcastRowsTableCreateCompanionBuilder =
    PodcastRowsCompanion Function({
      Value<int> id,
      required String title,
      Value<String> author,
      Value<String> artworkUrl,
      Value<String> description,
      Value<String> feedUrl,
      Value<int> episodeCount,
    });
typedef $$PodcastRowsTableUpdateCompanionBuilder =
    PodcastRowsCompanion Function({
      Value<int> id,
      Value<String> title,
      Value<String> author,
      Value<String> artworkUrl,
      Value<String> description,
      Value<String> feedUrl,
      Value<int> episodeCount,
    });

final class $$PodcastRowsTableReferences
    extends BaseReferences<_$AppDatabase, $PodcastRowsTable, PodcastRecord> {
  $$PodcastRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$EpisodeRowsTable, List<EpisodeRecord>>
  _episodeRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.episodeRows,
    aliasName: 'podcast_rows__id__episode_rows__podcast_id',
  );

  $$EpisodeRowsTableProcessedTableManager get episodeRowsRefs {
    final manager = $$EpisodeRowsTableTableManager(
      $_db,
      $_db.episodeRows,
    ).filter((f) => f.podcastId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_episodeRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PodcastRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PodcastRowsTable> {
  $$PodcastRowsTableFilterComposer({
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

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeCount => $composableBuilder(
    column: $table.episodeCount,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> episodeRowsRefs(
    Expression<bool> Function($$EpisodeRowsTableFilterComposer f) f,
  ) {
    final $$EpisodeRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodeRows,
      getReferencedColumn: (t) => t.podcastId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodeRowsTableFilterComposer(
            $db: $db,
            $table: $db.episodeRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PodcastRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PodcastRowsTable> {
  $$PodcastRowsTableOrderingComposer({
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

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get author => $composableBuilder(
    column: $table.author,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeCount => $composableBuilder(
    column: $table.episodeCount,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PodcastRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PodcastRowsTable> {
  $$PodcastRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get author =>
      $composableBuilder(column: $table.author, builder: (column) => column);

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<int> get episodeCount => $composableBuilder(
    column: $table.episodeCount,
    builder: (column) => column,
  );

  Expression<T> episodeRowsRefs<T extends Object>(
    Expression<T> Function($$EpisodeRowsTableAnnotationComposer a) f,
  ) {
    final $$EpisodeRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.episodeRows,
      getReferencedColumn: (t) => t.podcastId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodeRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.episodeRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PodcastRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PodcastRowsTable,
          PodcastRecord,
          $$PodcastRowsTableFilterComposer,
          $$PodcastRowsTableOrderingComposer,
          $$PodcastRowsTableAnnotationComposer,
          $$PodcastRowsTableCreateCompanionBuilder,
          $$PodcastRowsTableUpdateCompanionBuilder,
          (PodcastRecord, $$PodcastRowsTableReferences),
          PodcastRecord,
          PrefetchHooks Function({bool episodeRowsRefs})
        > {
  $$PodcastRowsTableTableManager(_$AppDatabase db, $PodcastRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PodcastRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PodcastRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> author = const Value.absent(),
                Value<String> artworkUrl = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<int> episodeCount = const Value.absent(),
              }) => PodcastRowsCompanion(
                id: id,
                title: title,
                author: author,
                artworkUrl: artworkUrl,
                description: description,
                feedUrl: feedUrl,
                episodeCount: episodeCount,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String title,
                Value<String> author = const Value.absent(),
                Value<String> artworkUrl = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> feedUrl = const Value.absent(),
                Value<int> episodeCount = const Value.absent(),
              }) => PodcastRowsCompanion.insert(
                id: id,
                title: title,
                author: author,
                artworkUrl: artworkUrl,
                description: description,
                feedUrl: feedUrl,
                episodeCount: episodeCount,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PodcastRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (episodeRowsRefs) db.episodeRows],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (episodeRowsRefs)
                    await $_getPrefetchedData<
                      PodcastRecord,
                      $PodcastRowsTable,
                      EpisodeRecord
                    >(
                      currentTable: table,
                      referencedTable: $$PodcastRowsTableReferences
                          ._episodeRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$PodcastRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).episodeRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.podcastId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PodcastRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PodcastRowsTable,
      PodcastRecord,
      $$PodcastRowsTableFilterComposer,
      $$PodcastRowsTableOrderingComposer,
      $$PodcastRowsTableAnnotationComposer,
      $$PodcastRowsTableCreateCompanionBuilder,
      $$PodcastRowsTableUpdateCompanionBuilder,
      (PodcastRecord, $$PodcastRowsTableReferences),
      PodcastRecord,
      PrefetchHooks Function({bool episodeRowsRefs})
    >;
typedef $$EpisodeRowsTableCreateCompanionBuilder =
    EpisodeRowsCompanion Function({
      Value<int> id,
      required int podcastId,
      required String podcastTitle,
      required String title,
      Value<String> description,
      Value<String> artworkUrl,
      Value<String> audioUrl,
      required DateTime publishedAt,
      Value<int> durationSeconds,
      Value<int> positionSeconds,
      Value<bool> completed,
      Value<bool> queued,
      Value<bool> downloaded,
      Value<bool> isYoutube,
      required DateTime updatedAt,
    });
typedef $$EpisodeRowsTableUpdateCompanionBuilder =
    EpisodeRowsCompanion Function({
      Value<int> id,
      Value<int> podcastId,
      Value<String> podcastTitle,
      Value<String> title,
      Value<String> description,
      Value<String> artworkUrl,
      Value<String> audioUrl,
      Value<DateTime> publishedAt,
      Value<int> durationSeconds,
      Value<int> positionSeconds,
      Value<bool> completed,
      Value<bool> queued,
      Value<bool> downloaded,
      Value<bool> isYoutube,
      Value<DateTime> updatedAt,
    });

final class $$EpisodeRowsTableReferences
    extends BaseReferences<_$AppDatabase, $EpisodeRowsTable, EpisodeRecord> {
  $$EpisodeRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PodcastRowsTable _podcastIdTable(_$AppDatabase db) =>
      db.podcastRows.createAlias('episode_rows__podcast_id__podcast_rows__id');

  $$PodcastRowsTableProcessedTableManager get podcastId {
    final $_column = $_itemColumn<int>('podcast_id')!;

    final manager = $$PodcastRowsTableTableManager(
      $_db,
      $_db.podcastRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_podcastIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$QueueRowsTable, List<QueueRecord>>
  _queueRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.queueRows,
    aliasName: 'episode_rows__id__queue_rows__episode_id',
  );

  $$QueueRowsTableProcessedTableManager get queueRowsRefs {
    final manager = $$QueueRowsTableTableManager(
      $_db,
      $_db.queueRows,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_queueRowsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$EpisodeRowsTableFilterComposer
    extends Composer<_$AppDatabase, $EpisodeRowsTable> {
  $$EpisodeRowsTableFilterComposer({
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

  ColumnFilters<String> get podcastTitle => $composableBuilder(
    column: $table.podcastTitle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get positionSeconds => $composableBuilder(
    column: $table.positionSeconds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get queued => $composableBuilder(
    column: $table.queued,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get downloaded => $composableBuilder(
    column: $table.downloaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isYoutube => $composableBuilder(
    column: $table.isYoutube,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PodcastRowsTableFilterComposer get podcastId {
    final $$PodcastRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.podcastRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastRowsTableFilterComposer(
            $db: $db,
            $table: $db.podcastRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> queueRowsRefs(
    Expression<bool> Function($$QueueRowsTableFilterComposer f) f,
  ) {
    final $$QueueRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueRows,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueRowsTableFilterComposer(
            $db: $db,
            $table: $db.queueRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EpisodeRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $EpisodeRowsTable> {
  $$EpisodeRowsTableOrderingComposer({
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

  ColumnOrderings<String> get podcastTitle => $composableBuilder(
    column: $table.podcastTitle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get audioUrl => $composableBuilder(
    column: $table.audioUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get positionSeconds => $composableBuilder(
    column: $table.positionSeconds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get completed => $composableBuilder(
    column: $table.completed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get queued => $composableBuilder(
    column: $table.queued,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get downloaded => $composableBuilder(
    column: $table.downloaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isYoutube => $composableBuilder(
    column: $table.isYoutube,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PodcastRowsTableOrderingComposer get podcastId {
    final $$PodcastRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.podcastRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastRowsTableOrderingComposer(
            $db: $db,
            $table: $db.podcastRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$EpisodeRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $EpisodeRowsTable> {
  $$EpisodeRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get podcastTitle => $composableBuilder(
    column: $table.podcastTitle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<String> get artworkUrl => $composableBuilder(
    column: $table.artworkUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get audioUrl =>
      $composableBuilder(column: $table.audioUrl, builder: (column) => column);

  GeneratedColumn<DateTime> get publishedAt => $composableBuilder(
    column: $table.publishedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get durationSeconds => $composableBuilder(
    column: $table.durationSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<int> get positionSeconds => $composableBuilder(
    column: $table.positionSeconds,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get completed =>
      $composableBuilder(column: $table.completed, builder: (column) => column);

  GeneratedColumn<bool> get queued =>
      $composableBuilder(column: $table.queued, builder: (column) => column);

  GeneratedColumn<bool> get downloaded => $composableBuilder(
    column: $table.downloaded,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isYoutube =>
      $composableBuilder(column: $table.isYoutube, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$PodcastRowsTableAnnotationComposer get podcastId {
    final $$PodcastRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.podcastId,
      referencedTable: $db.podcastRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PodcastRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.podcastRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> queueRowsRefs<T extends Object>(
    Expression<T> Function($$QueueRowsTableAnnotationComposer a) f,
  ) {
    final $$QueueRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.queueRows,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$QueueRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.queueRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$EpisodeRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $EpisodeRowsTable,
          EpisodeRecord,
          $$EpisodeRowsTableFilterComposer,
          $$EpisodeRowsTableOrderingComposer,
          $$EpisodeRowsTableAnnotationComposer,
          $$EpisodeRowsTableCreateCompanionBuilder,
          $$EpisodeRowsTableUpdateCompanionBuilder,
          (EpisodeRecord, $$EpisodeRowsTableReferences),
          EpisodeRecord,
          PrefetchHooks Function({bool podcastId, bool queueRowsRefs})
        > {
  $$EpisodeRowsTableTableManager(_$AppDatabase db, $EpisodeRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$EpisodeRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$EpisodeRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$EpisodeRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> podcastId = const Value.absent(),
                Value<String> podcastTitle = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> description = const Value.absent(),
                Value<String> artworkUrl = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                Value<DateTime> publishedAt = const Value.absent(),
                Value<int> durationSeconds = const Value.absent(),
                Value<int> positionSeconds = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> queued = const Value.absent(),
                Value<bool> downloaded = const Value.absent(),
                Value<bool> isYoutube = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => EpisodeRowsCompanion(
                id: id,
                podcastId: podcastId,
                podcastTitle: podcastTitle,
                title: title,
                description: description,
                artworkUrl: artworkUrl,
                audioUrl: audioUrl,
                publishedAt: publishedAt,
                durationSeconds: durationSeconds,
                positionSeconds: positionSeconds,
                completed: completed,
                queued: queued,
                downloaded: downloaded,
                isYoutube: isYoutube,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int podcastId,
                required String podcastTitle,
                required String title,
                Value<String> description = const Value.absent(),
                Value<String> artworkUrl = const Value.absent(),
                Value<String> audioUrl = const Value.absent(),
                required DateTime publishedAt,
                Value<int> durationSeconds = const Value.absent(),
                Value<int> positionSeconds = const Value.absent(),
                Value<bool> completed = const Value.absent(),
                Value<bool> queued = const Value.absent(),
                Value<bool> downloaded = const Value.absent(),
                Value<bool> isYoutube = const Value.absent(),
                required DateTime updatedAt,
              }) => EpisodeRowsCompanion.insert(
                id: id,
                podcastId: podcastId,
                podcastTitle: podcastTitle,
                title: title,
                description: description,
                artworkUrl: artworkUrl,
                audioUrl: audioUrl,
                publishedAt: publishedAt,
                durationSeconds: durationSeconds,
                positionSeconds: positionSeconds,
                completed: completed,
                queued: queued,
                downloaded: downloaded,
                isYoutube: isYoutube,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$EpisodeRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({podcastId = false, queueRowsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (queueRowsRefs) db.queueRows],
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
                    if (podcastId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.podcastId,
                                referencedTable: $$EpisodeRowsTableReferences
                                    ._podcastIdTable(db),
                                referencedColumn: $$EpisodeRowsTableReferences
                                    ._podcastIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [
                  if (queueRowsRefs)
                    await $_getPrefetchedData<
                      EpisodeRecord,
                      $EpisodeRowsTable,
                      QueueRecord
                    >(
                      currentTable: table,
                      referencedTable: $$EpisodeRowsTableReferences
                          ._queueRowsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$EpisodeRowsTableReferences(
                            db,
                            table,
                            p0,
                          ).queueRowsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.episodeId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$EpisodeRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $EpisodeRowsTable,
      EpisodeRecord,
      $$EpisodeRowsTableFilterComposer,
      $$EpisodeRowsTableOrderingComposer,
      $$EpisodeRowsTableAnnotationComposer,
      $$EpisodeRowsTableCreateCompanionBuilder,
      $$EpisodeRowsTableUpdateCompanionBuilder,
      (EpisodeRecord, $$EpisodeRowsTableReferences),
      EpisodeRecord,
      PrefetchHooks Function({bool podcastId, bool queueRowsRefs})
    >;
typedef $$QueueRowsTableCreateCompanionBuilder =
    QueueRowsCompanion Function({
      Value<int> episodeId,
      required double sortKey,
      required DateTime addedAt,
    });
typedef $$QueueRowsTableUpdateCompanionBuilder =
    QueueRowsCompanion Function({
      Value<int> episodeId,
      Value<double> sortKey,
      Value<DateTime> addedAt,
    });

final class $$QueueRowsTableReferences
    extends BaseReferences<_$AppDatabase, $QueueRowsTable, QueueRecord> {
  $$QueueRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EpisodeRowsTable _episodeIdTable(_$AppDatabase db) =>
      db.episodeRows.createAlias('queue_rows__episode_id__episode_rows__id');

  $$EpisodeRowsTableProcessedTableManager get episodeId {
    final $_column = $_itemColumn<int>('episode_id')!;

    final manager = $$EpisodeRowsTableTableManager(
      $_db,
      $_db.episodeRows,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_episodeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$QueueRowsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueRowsTable> {
  $$QueueRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$EpisodeRowsTableFilterComposer get episodeId {
    final $$EpisodeRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodeRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodeRowsTableFilterComposer(
            $db: $db,
            $table: $db.episodeRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueRowsTable> {
  $$QueueRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get sortKey => $composableBuilder(
    column: $table.sortKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get addedAt => $composableBuilder(
    column: $table.addedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$EpisodeRowsTableOrderingComposer get episodeId {
    final $$EpisodeRowsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodeRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodeRowsTableOrderingComposer(
            $db: $db,
            $table: $db.episodeRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueRowsTable> {
  $$QueueRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get sortKey =>
      $composableBuilder(column: $table.sortKey, builder: (column) => column);

  GeneratedColumn<DateTime> get addedAt =>
      $composableBuilder(column: $table.addedAt, builder: (column) => column);

  $$EpisodeRowsTableAnnotationComposer get episodeId {
    final $$EpisodeRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.episodeId,
      referencedTable: $db.episodeRows,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$EpisodeRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.episodeRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$QueueRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueRowsTable,
          QueueRecord,
          $$QueueRowsTableFilterComposer,
          $$QueueRowsTableOrderingComposer,
          $$QueueRowsTableAnnotationComposer,
          $$QueueRowsTableCreateCompanionBuilder,
          $$QueueRowsTableUpdateCompanionBuilder,
          (QueueRecord, $$QueueRowsTableReferences),
          QueueRecord,
          PrefetchHooks Function({bool episodeId})
        > {
  $$QueueRowsTableTableManager(_$AppDatabase db, $QueueRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                Value<double> sortKey = const Value.absent(),
                Value<DateTime> addedAt = const Value.absent(),
              }) => QueueRowsCompanion(
                episodeId: episodeId,
                sortKey: sortKey,
                addedAt: addedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                required double sortKey,
                required DateTime addedAt,
              }) => QueueRowsCompanion.insert(
                episodeId: episodeId,
                sortKey: sortKey,
                addedAt: addedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$QueueRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({episodeId = false}) {
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
                    if (episodeId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.episodeId,
                                referencedTable: $$QueueRowsTableReferences
                                    ._episodeIdTable(db),
                                referencedColumn: $$QueueRowsTableReferences
                                    ._episodeIdTable(db)
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

typedef $$QueueRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueRowsTable,
      QueueRecord,
      $$QueueRowsTableFilterComposer,
      $$QueueRowsTableOrderingComposer,
      $$QueueRowsTableAnnotationComposer,
      $$QueueRowsTableCreateCompanionBuilder,
      $$QueueRowsTableUpdateCompanionBuilder,
      (QueueRecord, $$QueueRowsTableReferences),
      QueueRecord,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$SyncMutationsTableCreateCompanionBuilder =
    SyncMutationsCompanion Function({
      required String id,
      required String type,
      Value<int?> episodeId,
      Value<String> payload,
      required DateTime createdAt,
      Value<int> attempts,
      Value<int> rowid,
    });
typedef $$SyncMutationsTableUpdateCompanionBuilder =
    SyncMutationsCompanion Function({
      Value<String> id,
      Value<String> type,
      Value<int?> episodeId,
      Value<String> payload,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<int> rowid,
    });

class $$SyncMutationsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncMutationsTable> {
  $$SyncMutationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncMutationsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncMutationsTable> {
  $$SyncMutationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get type => $composableBuilder(
    column: $table.type,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeId => $composableBuilder(
    column: $table.episodeId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncMutationsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncMutationsTable> {
  $$SyncMutationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get type =>
      $composableBuilder(column: $table.type, builder: (column) => column);

  GeneratedColumn<int> get episodeId =>
      $composableBuilder(column: $table.episodeId, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);
}

class $$SyncMutationsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncMutationsTable,
          PendingMutation,
          $$SyncMutationsTableFilterComposer,
          $$SyncMutationsTableOrderingComposer,
          $$SyncMutationsTableAnnotationComposer,
          $$SyncMutationsTableCreateCompanionBuilder,
          $$SyncMutationsTableUpdateCompanionBuilder,
          (
            PendingMutation,
            BaseReferences<_$AppDatabase, $SyncMutationsTable, PendingMutation>,
          ),
          PendingMutation,
          PrefetchHooks Function()
        > {
  $$SyncMutationsTableTableManager(_$AppDatabase db, $SyncMutationsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncMutationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncMutationsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncMutationsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> type = const Value.absent(),
                Value<int?> episodeId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMutationsCompanion(
                id: id,
                type: type,
                episodeId: episodeId,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String type,
                Value<int?> episodeId = const Value.absent(),
                Value<String> payload = const Value.absent(),
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMutationsCompanion.insert(
                id: id,
                type: type,
                episodeId: episodeId,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncMutationsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncMutationsTable,
      PendingMutation,
      $$SyncMutationsTableFilterComposer,
      $$SyncMutationsTableOrderingComposer,
      $$SyncMutationsTableAnnotationComposer,
      $$SyncMutationsTableCreateCompanionBuilder,
      $$SyncMutationsTableUpdateCompanionBuilder,
      (
        PendingMutation,
        BaseReferences<_$AppDatabase, $SyncMutationsTable, PendingMutation>,
      ),
      PendingMutation,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PodcastRowsTableTableManager get podcastRows =>
      $$PodcastRowsTableTableManager(_db, _db.podcastRows);
  $$EpisodeRowsTableTableManager get episodeRows =>
      $$EpisodeRowsTableTableManager(_db, _db.episodeRows);
  $$QueueRowsTableTableManager get queueRows =>
      $$QueueRowsTableTableManager(_db, _db.queueRows);
  $$SyncMutationsTableTableManager get syncMutations =>
      $$SyncMutationsTableTableManager(_db, _db.syncMutations);
}
