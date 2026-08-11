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
  static const VerificationMeta _websiteUrlMeta = const VerificationMeta(
    'websiteUrl',
  );
  @override
  late final GeneratedColumn<String> websiteUrl = GeneratedColumn<String>(
    'website_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _categoriesJsonMeta = const VerificationMeta(
    'categoriesJson',
  );
  @override
  late final GeneratedColumn<String> categoriesJson = GeneratedColumn<String>(
    'categories_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _explicitMeta = const VerificationMeta(
    'explicit',
  );
  @override
  late final GeneratedColumn<bool> explicit = GeneratedColumn<bool>(
    'explicit',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("explicit" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _podcastIndexIdMeta = const VerificationMeta(
    'podcastIndexId',
  );
  @override
  late final GeneratedColumn<int> podcastIndexId = GeneratedColumn<int>(
    'podcast_index_id',
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
    websiteUrl,
    categoriesJson,
    explicit,
    podcastIndexId,
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
    if (data.containsKey('website_url')) {
      context.handle(
        _websiteUrlMeta,
        websiteUrl.isAcceptableOrUnknown(data['website_url']!, _websiteUrlMeta),
      );
    }
    if (data.containsKey('categories_json')) {
      context.handle(
        _categoriesJsonMeta,
        categoriesJson.isAcceptableOrUnknown(
          data['categories_json']!,
          _categoriesJsonMeta,
        ),
      );
    }
    if (data.containsKey('explicit')) {
      context.handle(
        _explicitMeta,
        explicit.isAcceptableOrUnknown(data['explicit']!, _explicitMeta),
      );
    }
    if (data.containsKey('podcast_index_id')) {
      context.handle(
        _podcastIndexIdMeta,
        podcastIndexId.isAcceptableOrUnknown(
          data['podcast_index_id']!,
          _podcastIndexIdMeta,
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
      websiteUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}website_url'],
      )!,
      categoriesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}categories_json'],
      )!,
      explicit: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}explicit'],
      )!,
      podcastIndexId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}podcast_index_id'],
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
  final String websiteUrl;
  final String categoriesJson;
  final bool explicit;
  final int podcastIndexId;
  const PodcastRecord({
    required this.id,
    required this.title,
    required this.author,
    required this.artworkUrl,
    required this.description,
    required this.feedUrl,
    required this.episodeCount,
    required this.websiteUrl,
    required this.categoriesJson,
    required this.explicit,
    required this.podcastIndexId,
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
    map['website_url'] = Variable<String>(websiteUrl);
    map['categories_json'] = Variable<String>(categoriesJson);
    map['explicit'] = Variable<bool>(explicit);
    map['podcast_index_id'] = Variable<int>(podcastIndexId);
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
      websiteUrl: Value(websiteUrl),
      categoriesJson: Value(categoriesJson),
      explicit: Value(explicit),
      podcastIndexId: Value(podcastIndexId),
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
      websiteUrl: serializer.fromJson<String>(json['websiteUrl']),
      categoriesJson: serializer.fromJson<String>(json['categoriesJson']),
      explicit: serializer.fromJson<bool>(json['explicit']),
      podcastIndexId: serializer.fromJson<int>(json['podcastIndexId']),
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
      'websiteUrl': serializer.toJson<String>(websiteUrl),
      'categoriesJson': serializer.toJson<String>(categoriesJson),
      'explicit': serializer.toJson<bool>(explicit),
      'podcastIndexId': serializer.toJson<int>(podcastIndexId),
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
    String? websiteUrl,
    String? categoriesJson,
    bool? explicit,
    int? podcastIndexId,
  }) => PodcastRecord(
    id: id ?? this.id,
    title: title ?? this.title,
    author: author ?? this.author,
    artworkUrl: artworkUrl ?? this.artworkUrl,
    description: description ?? this.description,
    feedUrl: feedUrl ?? this.feedUrl,
    episodeCount: episodeCount ?? this.episodeCount,
    websiteUrl: websiteUrl ?? this.websiteUrl,
    categoriesJson: categoriesJson ?? this.categoriesJson,
    explicit: explicit ?? this.explicit,
    podcastIndexId: podcastIndexId ?? this.podcastIndexId,
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
      websiteUrl: data.websiteUrl.present
          ? data.websiteUrl.value
          : this.websiteUrl,
      categoriesJson: data.categoriesJson.present
          ? data.categoriesJson.value
          : this.categoriesJson,
      explicit: data.explicit.present ? data.explicit.value : this.explicit,
      podcastIndexId: data.podcastIndexId.present
          ? data.podcastIndexId.value
          : this.podcastIndexId,
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
          ..write('episodeCount: $episodeCount, ')
          ..write('websiteUrl: $websiteUrl, ')
          ..write('categoriesJson: $categoriesJson, ')
          ..write('explicit: $explicit, ')
          ..write('podcastIndexId: $podcastIndexId')
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
    websiteUrl,
    categoriesJson,
    explicit,
    podcastIndexId,
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
          other.episodeCount == this.episodeCount &&
          other.websiteUrl == this.websiteUrl &&
          other.categoriesJson == this.categoriesJson &&
          other.explicit == this.explicit &&
          other.podcastIndexId == this.podcastIndexId);
}

class PodcastRowsCompanion extends UpdateCompanion<PodcastRecord> {
  final Value<int> id;
  final Value<String> title;
  final Value<String> author;
  final Value<String> artworkUrl;
  final Value<String> description;
  final Value<String> feedUrl;
  final Value<int> episodeCount;
  final Value<String> websiteUrl;
  final Value<String> categoriesJson;
  final Value<bool> explicit;
  final Value<int> podcastIndexId;
  const PodcastRowsCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.author = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.episodeCount = const Value.absent(),
    this.websiteUrl = const Value.absent(),
    this.categoriesJson = const Value.absent(),
    this.explicit = const Value.absent(),
    this.podcastIndexId = const Value.absent(),
  });
  PodcastRowsCompanion.insert({
    this.id = const Value.absent(),
    required String title,
    this.author = const Value.absent(),
    this.artworkUrl = const Value.absent(),
    this.description = const Value.absent(),
    this.feedUrl = const Value.absent(),
    this.episodeCount = const Value.absent(),
    this.websiteUrl = const Value.absent(),
    this.categoriesJson = const Value.absent(),
    this.explicit = const Value.absent(),
    this.podcastIndexId = const Value.absent(),
  }) : title = Value(title);
  static Insertable<PodcastRecord> custom({
    Expression<int>? id,
    Expression<String>? title,
    Expression<String>? author,
    Expression<String>? artworkUrl,
    Expression<String>? description,
    Expression<String>? feedUrl,
    Expression<int>? episodeCount,
    Expression<String>? websiteUrl,
    Expression<String>? categoriesJson,
    Expression<bool>? explicit,
    Expression<int>? podcastIndexId,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (author != null) 'author': author,
      if (artworkUrl != null) 'artwork_url': artworkUrl,
      if (description != null) 'description': description,
      if (feedUrl != null) 'feed_url': feedUrl,
      if (episodeCount != null) 'episode_count': episodeCount,
      if (websiteUrl != null) 'website_url': websiteUrl,
      if (categoriesJson != null) 'categories_json': categoriesJson,
      if (explicit != null) 'explicit': explicit,
      if (podcastIndexId != null) 'podcast_index_id': podcastIndexId,
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
    Value<String>? websiteUrl,
    Value<String>? categoriesJson,
    Value<bool>? explicit,
    Value<int>? podcastIndexId,
  }) {
    return PodcastRowsCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      author: author ?? this.author,
      artworkUrl: artworkUrl ?? this.artworkUrl,
      description: description ?? this.description,
      feedUrl: feedUrl ?? this.feedUrl,
      episodeCount: episodeCount ?? this.episodeCount,
      websiteUrl: websiteUrl ?? this.websiteUrl,
      categoriesJson: categoriesJson ?? this.categoriesJson,
      explicit: explicit ?? this.explicit,
      podcastIndexId: podcastIndexId ?? this.podcastIndexId,
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
    if (websiteUrl.present) {
      map['website_url'] = Variable<String>(websiteUrl.value);
    }
    if (categoriesJson.present) {
      map['categories_json'] = Variable<String>(categoriesJson.value);
    }
    if (explicit.present) {
      map['explicit'] = Variable<bool>(explicit.value);
    }
    if (podcastIndexId.present) {
      map['podcast_index_id'] = Variable<int>(podcastIndexId.value);
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
          ..write('episodeCount: $episodeCount, ')
          ..write('websiteUrl: $websiteUrl, ')
          ..write('categoriesJson: $categoriesJson, ')
          ..write('explicit: $explicit, ')
          ..write('podcastIndexId: $podcastIndexId')
          ..write(')'))
        .toString();
  }
}

class $DiscoveryCacheRowsTable extends DiscoveryCacheRows
    with TableInfo<$DiscoveryCacheRowsTable, DiscoveryCacheRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DiscoveryCacheRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _feedUrlMeta = const VerificationMeta(
    'feedUrl',
  );
  @override
  late final GeneratedColumn<String> feedUrl = GeneratedColumn<String>(
    'feed_url',
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
  static const VerificationMeta _podcastJsonMeta = const VerificationMeta(
    'podcastJson',
  );
  @override
  late final GeneratedColumn<String> podcastJson = GeneratedColumn<String>(
    'podcast_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _episodesJsonMeta = const VerificationMeta(
    'episodesJson',
  );
  @override
  late final GeneratedColumn<String> episodesJson = GeneratedColumn<String>(
    'episodes_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _cachedAtMeta = const VerificationMeta(
    'cachedAt',
  );
  @override
  late final GeneratedColumn<DateTime> cachedAt = GeneratedColumn<DateTime>(
    'cached_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    feedUrl,
    title,
    podcastJson,
    episodesJson,
    cachedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'discovery_cache_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<DiscoveryCacheRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('feed_url')) {
      context.handle(
        _feedUrlMeta,
        feedUrl.isAcceptableOrUnknown(data['feed_url']!, _feedUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_feedUrlMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('podcast_json')) {
      context.handle(
        _podcastJsonMeta,
        podcastJson.isAcceptableOrUnknown(
          data['podcast_json']!,
          _podcastJsonMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_podcastJsonMeta);
    }
    if (data.containsKey('episodes_json')) {
      context.handle(
        _episodesJsonMeta,
        episodesJson.isAcceptableOrUnknown(
          data['episodes_json']!,
          _episodesJsonMeta,
        ),
      );
    }
    if (data.containsKey('cached_at')) {
      context.handle(
        _cachedAtMeta,
        cachedAt.isAcceptableOrUnknown(data['cached_at']!, _cachedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_cachedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {feedUrl};
  @override
  DiscoveryCacheRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DiscoveryCacheRecord(
      feedUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}feed_url'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      podcastJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}podcast_json'],
      )!,
      episodesJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}episodes_json'],
      )!,
      cachedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}cached_at'],
      )!,
    );
  }

  @override
  $DiscoveryCacheRowsTable createAlias(String alias) {
    return $DiscoveryCacheRowsTable(attachedDatabase, alias);
  }
}

class DiscoveryCacheRecord extends DataClass
    implements Insertable<DiscoveryCacheRecord> {
  final String feedUrl;
  final String title;
  final String podcastJson;
  final String episodesJson;
  final DateTime cachedAt;
  const DiscoveryCacheRecord({
    required this.feedUrl,
    required this.title,
    required this.podcastJson,
    required this.episodesJson,
    required this.cachedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['feed_url'] = Variable<String>(feedUrl);
    map['title'] = Variable<String>(title);
    map['podcast_json'] = Variable<String>(podcastJson);
    map['episodes_json'] = Variable<String>(episodesJson);
    map['cached_at'] = Variable<DateTime>(cachedAt);
    return map;
  }

  DiscoveryCacheRowsCompanion toCompanion(bool nullToAbsent) {
    return DiscoveryCacheRowsCompanion(
      feedUrl: Value(feedUrl),
      title: Value(title),
      podcastJson: Value(podcastJson),
      episodesJson: Value(episodesJson),
      cachedAt: Value(cachedAt),
    );
  }

  factory DiscoveryCacheRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DiscoveryCacheRecord(
      feedUrl: serializer.fromJson<String>(json['feedUrl']),
      title: serializer.fromJson<String>(json['title']),
      podcastJson: serializer.fromJson<String>(json['podcastJson']),
      episodesJson: serializer.fromJson<String>(json['episodesJson']),
      cachedAt: serializer.fromJson<DateTime>(json['cachedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'feedUrl': serializer.toJson<String>(feedUrl),
      'title': serializer.toJson<String>(title),
      'podcastJson': serializer.toJson<String>(podcastJson),
      'episodesJson': serializer.toJson<String>(episodesJson),
      'cachedAt': serializer.toJson<DateTime>(cachedAt),
    };
  }

  DiscoveryCacheRecord copyWith({
    String? feedUrl,
    String? title,
    String? podcastJson,
    String? episodesJson,
    DateTime? cachedAt,
  }) => DiscoveryCacheRecord(
    feedUrl: feedUrl ?? this.feedUrl,
    title: title ?? this.title,
    podcastJson: podcastJson ?? this.podcastJson,
    episodesJson: episodesJson ?? this.episodesJson,
    cachedAt: cachedAt ?? this.cachedAt,
  );
  DiscoveryCacheRecord copyWithCompanion(DiscoveryCacheRowsCompanion data) {
    return DiscoveryCacheRecord(
      feedUrl: data.feedUrl.present ? data.feedUrl.value : this.feedUrl,
      title: data.title.present ? data.title.value : this.title,
      podcastJson: data.podcastJson.present
          ? data.podcastJson.value
          : this.podcastJson,
      episodesJson: data.episodesJson.present
          ? data.episodesJson.value
          : this.episodesJson,
      cachedAt: data.cachedAt.present ? data.cachedAt.value : this.cachedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveryCacheRecord(')
          ..write('feedUrl: $feedUrl, ')
          ..write('title: $title, ')
          ..write('podcastJson: $podcastJson, ')
          ..write('episodesJson: $episodesJson, ')
          ..write('cachedAt: $cachedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(feedUrl, title, podcastJson, episodesJson, cachedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DiscoveryCacheRecord &&
          other.feedUrl == this.feedUrl &&
          other.title == this.title &&
          other.podcastJson == this.podcastJson &&
          other.episodesJson == this.episodesJson &&
          other.cachedAt == this.cachedAt);
}

class DiscoveryCacheRowsCompanion
    extends UpdateCompanion<DiscoveryCacheRecord> {
  final Value<String> feedUrl;
  final Value<String> title;
  final Value<String> podcastJson;
  final Value<String> episodesJson;
  final Value<DateTime> cachedAt;
  final Value<int> rowid;
  const DiscoveryCacheRowsCompanion({
    this.feedUrl = const Value.absent(),
    this.title = const Value.absent(),
    this.podcastJson = const Value.absent(),
    this.episodesJson = const Value.absent(),
    this.cachedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DiscoveryCacheRowsCompanion.insert({
    required String feedUrl,
    required String title,
    required String podcastJson,
    this.episodesJson = const Value.absent(),
    required DateTime cachedAt,
    this.rowid = const Value.absent(),
  }) : feedUrl = Value(feedUrl),
       title = Value(title),
       podcastJson = Value(podcastJson),
       cachedAt = Value(cachedAt);
  static Insertable<DiscoveryCacheRecord> custom({
    Expression<String>? feedUrl,
    Expression<String>? title,
    Expression<String>? podcastJson,
    Expression<String>? episodesJson,
    Expression<DateTime>? cachedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (feedUrl != null) 'feed_url': feedUrl,
      if (title != null) 'title': title,
      if (podcastJson != null) 'podcast_json': podcastJson,
      if (episodesJson != null) 'episodes_json': episodesJson,
      if (cachedAt != null) 'cached_at': cachedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DiscoveryCacheRowsCompanion copyWith({
    Value<String>? feedUrl,
    Value<String>? title,
    Value<String>? podcastJson,
    Value<String>? episodesJson,
    Value<DateTime>? cachedAt,
    Value<int>? rowid,
  }) {
    return DiscoveryCacheRowsCompanion(
      feedUrl: feedUrl ?? this.feedUrl,
      title: title ?? this.title,
      podcastJson: podcastJson ?? this.podcastJson,
      episodesJson: episodesJson ?? this.episodesJson,
      cachedAt: cachedAt ?? this.cachedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (feedUrl.present) {
      map['feed_url'] = Variable<String>(feedUrl.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (podcastJson.present) {
      map['podcast_json'] = Variable<String>(podcastJson.value);
    }
    if (episodesJson.present) {
      map['episodes_json'] = Variable<String>(episodesJson.value);
    }
    if (cachedAt.present) {
      map['cached_at'] = Variable<DateTime>(cachedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DiscoveryCacheRowsCompanion(')
          ..write('feedUrl: $feedUrl, ')
          ..write('title: $title, ')
          ..write('podcastJson: $podcastJson, ')
          ..write('episodesJson: $episodesJson, ')
          ..write('cachedAt: $cachedAt, ')
          ..write('rowid: $rowid')
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
  static const VerificationMeta _chaptersJsonMeta = const VerificationMeta(
    'chaptersJson',
  );
  @override
  late final GeneratedColumn<String> chaptersJson = GeneratedColumn<String>(
    'chapters_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _playbackUpdatedAtMeta = const VerificationMeta(
    'playbackUpdatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playbackUpdatedAt =
      GeneratedColumn<DateTime>(
        'playback_updated_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _playbackDeviceIdMeta = const VerificationMeta(
    'playbackDeviceId',
  );
  @override
  late final GeneratedColumn<String> playbackDeviceId = GeneratedColumn<String>(
    'playback_device_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _playbackIntentMeta = const VerificationMeta(
    'playbackIntent',
  );
  @override
  late final GeneratedColumn<String> playbackIntent = GeneratedColumn<String>(
    'playback_intent',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('progress'),
  );
  static const VerificationMeta _playbackMediaIdentityMeta =
      const VerificationMeta('playbackMediaIdentity');
  @override
  late final GeneratedColumn<String> playbackMediaIdentity =
      GeneratedColumn<String>(
        'playback_media_identity',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultValue: const Constant(''),
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
    chaptersJson,
    playbackUpdatedAt,
    playbackDeviceId,
    playbackIntent,
    playbackMediaIdentity,
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
    if (data.containsKey('chapters_json')) {
      context.handle(
        _chaptersJsonMeta,
        chaptersJson.isAcceptableOrUnknown(
          data['chapters_json']!,
          _chaptersJsonMeta,
        ),
      );
    }
    if (data.containsKey('playback_updated_at')) {
      context.handle(
        _playbackUpdatedAtMeta,
        playbackUpdatedAt.isAcceptableOrUnknown(
          data['playback_updated_at']!,
          _playbackUpdatedAtMeta,
        ),
      );
    }
    if (data.containsKey('playback_device_id')) {
      context.handle(
        _playbackDeviceIdMeta,
        playbackDeviceId.isAcceptableOrUnknown(
          data['playback_device_id']!,
          _playbackDeviceIdMeta,
        ),
      );
    }
    if (data.containsKey('playback_intent')) {
      context.handle(
        _playbackIntentMeta,
        playbackIntent.isAcceptableOrUnknown(
          data['playback_intent']!,
          _playbackIntentMeta,
        ),
      );
    }
    if (data.containsKey('playback_media_identity')) {
      context.handle(
        _playbackMediaIdentityMeta,
        playbackMediaIdentity.isAcceptableOrUnknown(
          data['playback_media_identity']!,
          _playbackMediaIdentityMeta,
        ),
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
      chaptersJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapters_json'],
      )!,
      playbackUpdatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}playback_updated_at'],
      ),
      playbackDeviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playback_device_id'],
      ),
      playbackIntent: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playback_intent'],
      )!,
      playbackMediaIdentity: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}playback_media_identity'],
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
  final String chaptersJson;
  final DateTime? playbackUpdatedAt;
  final String? playbackDeviceId;
  final String playbackIntent;
  final String playbackMediaIdentity;
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
    required this.chaptersJson,
    this.playbackUpdatedAt,
    this.playbackDeviceId,
    required this.playbackIntent,
    required this.playbackMediaIdentity,
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
    map['chapters_json'] = Variable<String>(chaptersJson);
    if (!nullToAbsent || playbackUpdatedAt != null) {
      map['playback_updated_at'] = Variable<DateTime>(playbackUpdatedAt);
    }
    if (!nullToAbsent || playbackDeviceId != null) {
      map['playback_device_id'] = Variable<String>(playbackDeviceId);
    }
    map['playback_intent'] = Variable<String>(playbackIntent);
    map['playback_media_identity'] = Variable<String>(playbackMediaIdentity);
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
      chaptersJson: Value(chaptersJson),
      playbackUpdatedAt: playbackUpdatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(playbackUpdatedAt),
      playbackDeviceId: playbackDeviceId == null && nullToAbsent
          ? const Value.absent()
          : Value(playbackDeviceId),
      playbackIntent: Value(playbackIntent),
      playbackMediaIdentity: Value(playbackMediaIdentity),
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
      chaptersJson: serializer.fromJson<String>(json['chaptersJson']),
      playbackUpdatedAt: serializer.fromJson<DateTime?>(
        json['playbackUpdatedAt'],
      ),
      playbackDeviceId: serializer.fromJson<String?>(json['playbackDeviceId']),
      playbackIntent: serializer.fromJson<String>(json['playbackIntent']),
      playbackMediaIdentity: serializer.fromJson<String>(
        json['playbackMediaIdentity'],
      ),
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
      'chaptersJson': serializer.toJson<String>(chaptersJson),
      'playbackUpdatedAt': serializer.toJson<DateTime?>(playbackUpdatedAt),
      'playbackDeviceId': serializer.toJson<String?>(playbackDeviceId),
      'playbackIntent': serializer.toJson<String>(playbackIntent),
      'playbackMediaIdentity': serializer.toJson<String>(playbackMediaIdentity),
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
    String? chaptersJson,
    Value<DateTime?> playbackUpdatedAt = const Value.absent(),
    Value<String?> playbackDeviceId = const Value.absent(),
    String? playbackIntent,
    String? playbackMediaIdentity,
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
    chaptersJson: chaptersJson ?? this.chaptersJson,
    playbackUpdatedAt: playbackUpdatedAt.present
        ? playbackUpdatedAt.value
        : this.playbackUpdatedAt,
    playbackDeviceId: playbackDeviceId.present
        ? playbackDeviceId.value
        : this.playbackDeviceId,
    playbackIntent: playbackIntent ?? this.playbackIntent,
    playbackMediaIdentity: playbackMediaIdentity ?? this.playbackMediaIdentity,
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
      chaptersJson: data.chaptersJson.present
          ? data.chaptersJson.value
          : this.chaptersJson,
      playbackUpdatedAt: data.playbackUpdatedAt.present
          ? data.playbackUpdatedAt.value
          : this.playbackUpdatedAt,
      playbackDeviceId: data.playbackDeviceId.present
          ? data.playbackDeviceId.value
          : this.playbackDeviceId,
      playbackIntent: data.playbackIntent.present
          ? data.playbackIntent.value
          : this.playbackIntent,
      playbackMediaIdentity: data.playbackMediaIdentity.present
          ? data.playbackMediaIdentity.value
          : this.playbackMediaIdentity,
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
          ..write('chaptersJson: $chaptersJson, ')
          ..write('playbackUpdatedAt: $playbackUpdatedAt, ')
          ..write('playbackDeviceId: $playbackDeviceId, ')
          ..write('playbackIntent: $playbackIntent, ')
          ..write('playbackMediaIdentity: $playbackMediaIdentity, ')
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
    chaptersJson,
    playbackUpdatedAt,
    playbackDeviceId,
    playbackIntent,
    playbackMediaIdentity,
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
          other.chaptersJson == this.chaptersJson &&
          other.playbackUpdatedAt == this.playbackUpdatedAt &&
          other.playbackDeviceId == this.playbackDeviceId &&
          other.playbackIntent == this.playbackIntent &&
          other.playbackMediaIdentity == this.playbackMediaIdentity &&
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
  final Value<String> chaptersJson;
  final Value<DateTime?> playbackUpdatedAt;
  final Value<String?> playbackDeviceId;
  final Value<String> playbackIntent;
  final Value<String> playbackMediaIdentity;
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
    this.chaptersJson = const Value.absent(),
    this.playbackUpdatedAt = const Value.absent(),
    this.playbackDeviceId = const Value.absent(),
    this.playbackIntent = const Value.absent(),
    this.playbackMediaIdentity = const Value.absent(),
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
    this.chaptersJson = const Value.absent(),
    this.playbackUpdatedAt = const Value.absent(),
    this.playbackDeviceId = const Value.absent(),
    this.playbackIntent = const Value.absent(),
    this.playbackMediaIdentity = const Value.absent(),
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
    Expression<String>? chaptersJson,
    Expression<DateTime>? playbackUpdatedAt,
    Expression<String>? playbackDeviceId,
    Expression<String>? playbackIntent,
    Expression<String>? playbackMediaIdentity,
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
      if (chaptersJson != null) 'chapters_json': chaptersJson,
      if (playbackUpdatedAt != null) 'playback_updated_at': playbackUpdatedAt,
      if (playbackDeviceId != null) 'playback_device_id': playbackDeviceId,
      if (playbackIntent != null) 'playback_intent': playbackIntent,
      if (playbackMediaIdentity != null)
        'playback_media_identity': playbackMediaIdentity,
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
    Value<String>? chaptersJson,
    Value<DateTime?>? playbackUpdatedAt,
    Value<String?>? playbackDeviceId,
    Value<String>? playbackIntent,
    Value<String>? playbackMediaIdentity,
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
      chaptersJson: chaptersJson ?? this.chaptersJson,
      playbackUpdatedAt: playbackUpdatedAt ?? this.playbackUpdatedAt,
      playbackDeviceId: playbackDeviceId ?? this.playbackDeviceId,
      playbackIntent: playbackIntent ?? this.playbackIntent,
      playbackMediaIdentity:
          playbackMediaIdentity ?? this.playbackMediaIdentity,
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
    if (chaptersJson.present) {
      map['chapters_json'] = Variable<String>(chaptersJson.value);
    }
    if (playbackUpdatedAt.present) {
      map['playback_updated_at'] = Variable<DateTime>(playbackUpdatedAt.value);
    }
    if (playbackDeviceId.present) {
      map['playback_device_id'] = Variable<String>(playbackDeviceId.value);
    }
    if (playbackIntent.present) {
      map['playback_intent'] = Variable<String>(playbackIntent.value);
    }
    if (playbackMediaIdentity.present) {
      map['playback_media_identity'] = Variable<String>(
        playbackMediaIdentity.value,
      );
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
          ..write('chaptersJson: $chaptersJson, ')
          ..write('playbackUpdatedAt: $playbackUpdatedAt, ')
          ..write('playbackDeviceId: $playbackDeviceId, ')
          ..write('playbackIntent: $playbackIntent, ')
          ..write('playbackMediaIdentity: $playbackMediaIdentity, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadJobRowsTable extends DownloadJobRows
    with TableInfo<$DownloadJobRowsTable, DownloadJobRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadJobRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _sourceUrlMeta = const VerificationMeta(
    'sourceUrl',
  );
  @override
  late final GeneratedColumn<String> sourceUrl = GeneratedColumn<String>(
    'source_url',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _filePathMeta = const VerificationMeta(
    'filePath',
  );
  @override
  late final GeneratedColumn<String> filePath = GeneratedColumn<String>(
    'file_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _partialPathMeta = const VerificationMeta(
    'partialPath',
  );
  @override
  late final GeneratedColumn<String> partialPath = GeneratedColumn<String>(
    'partial_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bytesDownloadedMeta = const VerificationMeta(
    'bytesDownloaded',
  );
  @override
  late final GeneratedColumn<int> bytesDownloaded = GeneratedColumn<int>(
    'bytes_downloaded',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _totalBytesMeta = const VerificationMeta(
    'totalBytes',
  );
  @override
  late final GeneratedColumn<int> totalBytes = GeneratedColumn<int>(
    'total_bytes',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _etagMeta = const VerificationMeta('etag');
  @override
  late final GeneratedColumn<String> etag = GeneratedColumn<String>(
    'etag',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastModifiedMeta = const VerificationMeta(
    'lastModified',
  );
  @override
  late final GeneratedColumn<String> lastModified = GeneratedColumn<String>(
    'last_modified',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _errorMeta = const VerificationMeta('error');
  @override
  late final GeneratedColumn<String> error = GeneratedColumn<String>(
    'error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _automaticMeta = const VerificationMeta(
    'automatic',
  );
  @override
  late final GeneratedColumn<bool> automatic = GeneratedColumn<bool>(
    'automatic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("automatic" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
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
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
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
    episodeId,
    sourceUrl,
    filePath,
    partialPath,
    state,
    bytesDownloaded,
    totalBytes,
    etag,
    lastModified,
    error,
    automatic,
    attempts,
    nextAttemptAt,
    playedAt,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_job_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadJobRecord> instance, {
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
    if (data.containsKey('source_url')) {
      context.handle(
        _sourceUrlMeta,
        sourceUrl.isAcceptableOrUnknown(data['source_url']!, _sourceUrlMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceUrlMeta);
    }
    if (data.containsKey('file_path')) {
      context.handle(
        _filePathMeta,
        filePath.isAcceptableOrUnknown(data['file_path']!, _filePathMeta),
      );
    } else if (isInserting) {
      context.missing(_filePathMeta);
    }
    if (data.containsKey('partial_path')) {
      context.handle(
        _partialPathMeta,
        partialPath.isAcceptableOrUnknown(
          data['partial_path']!,
          _partialPathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_partialPathMeta);
    }
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    } else if (isInserting) {
      context.missing(_stateMeta);
    }
    if (data.containsKey('bytes_downloaded')) {
      context.handle(
        _bytesDownloadedMeta,
        bytesDownloaded.isAcceptableOrUnknown(
          data['bytes_downloaded']!,
          _bytesDownloadedMeta,
        ),
      );
    }
    if (data.containsKey('total_bytes')) {
      context.handle(
        _totalBytesMeta,
        totalBytes.isAcceptableOrUnknown(data['total_bytes']!, _totalBytesMeta),
      );
    }
    if (data.containsKey('etag')) {
      context.handle(
        _etagMeta,
        etag.isAcceptableOrUnknown(data['etag']!, _etagMeta),
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
    if (data.containsKey('error')) {
      context.handle(
        _errorMeta,
        error.isAcceptableOrUnknown(data['error']!, _errorMeta),
      );
    }
    if (data.containsKey('automatic')) {
      context.handle(
        _automaticMeta,
        automatic.isAcceptableOrUnknown(data['automatic']!, _automaticMeta),
      );
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
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
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  DownloadJobRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadJobRecord(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      sourceUrl: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source_url'],
      )!,
      filePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}file_path'],
      )!,
      partialPath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}partial_path'],
      )!,
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      bytesDownloaded: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}bytes_downloaded'],
      )!,
      totalBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}total_bytes'],
      ),
      etag: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}etag'],
      ),
      lastModified: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_modified'],
      ),
      error: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}error'],
      ),
      automatic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}automatic'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DownloadJobRowsTable createAlias(String alias) {
    return $DownloadJobRowsTable(attachedDatabase, alias);
  }
}

class DownloadJobRecord extends DataClass
    implements Insertable<DownloadJobRecord> {
  final int episodeId;
  final String sourceUrl;
  final String filePath;
  final String partialPath;
  final String state;
  final int bytesDownloaded;
  final int? totalBytes;
  final String? etag;
  final String? lastModified;
  final String? error;
  final bool automatic;
  final int attempts;
  final DateTime? nextAttemptAt;
  final DateTime? playedAt;
  final DateTime createdAt;
  final DateTime updatedAt;
  const DownloadJobRecord({
    required this.episodeId,
    required this.sourceUrl,
    required this.filePath,
    required this.partialPath,
    required this.state,
    required this.bytesDownloaded,
    this.totalBytes,
    this.etag,
    this.lastModified,
    this.error,
    required this.automatic,
    required this.attempts,
    this.nextAttemptAt,
    this.playedAt,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<int>(episodeId);
    map['source_url'] = Variable<String>(sourceUrl);
    map['file_path'] = Variable<String>(filePath);
    map['partial_path'] = Variable<String>(partialPath);
    map['state'] = Variable<String>(state);
    map['bytes_downloaded'] = Variable<int>(bytesDownloaded);
    if (!nullToAbsent || totalBytes != null) {
      map['total_bytes'] = Variable<int>(totalBytes);
    }
    if (!nullToAbsent || etag != null) {
      map['etag'] = Variable<String>(etag);
    }
    if (!nullToAbsent || lastModified != null) {
      map['last_modified'] = Variable<String>(lastModified);
    }
    if (!nullToAbsent || error != null) {
      map['error'] = Variable<String>(error);
    }
    map['automatic'] = Variable<bool>(automatic);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || playedAt != null) {
      map['played_at'] = Variable<DateTime>(playedAt);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DownloadJobRowsCompanion toCompanion(bool nullToAbsent) {
    return DownloadJobRowsCompanion(
      episodeId: Value(episodeId),
      sourceUrl: Value(sourceUrl),
      filePath: Value(filePath),
      partialPath: Value(partialPath),
      state: Value(state),
      bytesDownloaded: Value(bytesDownloaded),
      totalBytes: totalBytes == null && nullToAbsent
          ? const Value.absent()
          : Value(totalBytes),
      etag: etag == null && nullToAbsent ? const Value.absent() : Value(etag),
      lastModified: lastModified == null && nullToAbsent
          ? const Value.absent()
          : Value(lastModified),
      error: error == null && nullToAbsent
          ? const Value.absent()
          : Value(error),
      automatic: Value(automatic),
      attempts: Value(attempts),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      playedAt: playedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(playedAt),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory DownloadJobRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadJobRecord(
      episodeId: serializer.fromJson<int>(json['episodeId']),
      sourceUrl: serializer.fromJson<String>(json['sourceUrl']),
      filePath: serializer.fromJson<String>(json['filePath']),
      partialPath: serializer.fromJson<String>(json['partialPath']),
      state: serializer.fromJson<String>(json['state']),
      bytesDownloaded: serializer.fromJson<int>(json['bytesDownloaded']),
      totalBytes: serializer.fromJson<int?>(json['totalBytes']),
      etag: serializer.fromJson<String?>(json['etag']),
      lastModified: serializer.fromJson<String?>(json['lastModified']),
      error: serializer.fromJson<String?>(json['error']),
      automatic: serializer.fromJson<bool>(json['automatic']),
      attempts: serializer.fromJson<int>(json['attempts']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      playedAt: serializer.fromJson<DateTime?>(json['playedAt']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<int>(episodeId),
      'sourceUrl': serializer.toJson<String>(sourceUrl),
      'filePath': serializer.toJson<String>(filePath),
      'partialPath': serializer.toJson<String>(partialPath),
      'state': serializer.toJson<String>(state),
      'bytesDownloaded': serializer.toJson<int>(bytesDownloaded),
      'totalBytes': serializer.toJson<int?>(totalBytes),
      'etag': serializer.toJson<String?>(etag),
      'lastModified': serializer.toJson<String?>(lastModified),
      'error': serializer.toJson<String?>(error),
      'automatic': serializer.toJson<bool>(automatic),
      'attempts': serializer.toJson<int>(attempts),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'playedAt': serializer.toJson<DateTime?>(playedAt),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  DownloadJobRecord copyWith({
    int? episodeId,
    String? sourceUrl,
    String? filePath,
    String? partialPath,
    String? state,
    int? bytesDownloaded,
    Value<int?> totalBytes = const Value.absent(),
    Value<String?> etag = const Value.absent(),
    Value<String?> lastModified = const Value.absent(),
    Value<String?> error = const Value.absent(),
    bool? automatic,
    int? attempts,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<DateTime?> playedAt = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => DownloadJobRecord(
    episodeId: episodeId ?? this.episodeId,
    sourceUrl: sourceUrl ?? this.sourceUrl,
    filePath: filePath ?? this.filePath,
    partialPath: partialPath ?? this.partialPath,
    state: state ?? this.state,
    bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
    totalBytes: totalBytes.present ? totalBytes.value : this.totalBytes,
    etag: etag.present ? etag.value : this.etag,
    lastModified: lastModified.present ? lastModified.value : this.lastModified,
    error: error.present ? error.value : this.error,
    automatic: automatic ?? this.automatic,
    attempts: attempts ?? this.attempts,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    playedAt: playedAt.present ? playedAt.value : this.playedAt,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  DownloadJobRecord copyWithCompanion(DownloadJobRowsCompanion data) {
    return DownloadJobRecord(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      sourceUrl: data.sourceUrl.present ? data.sourceUrl.value : this.sourceUrl,
      filePath: data.filePath.present ? data.filePath.value : this.filePath,
      partialPath: data.partialPath.present
          ? data.partialPath.value
          : this.partialPath,
      state: data.state.present ? data.state.value : this.state,
      bytesDownloaded: data.bytesDownloaded.present
          ? data.bytesDownloaded.value
          : this.bytesDownloaded,
      totalBytes: data.totalBytes.present
          ? data.totalBytes.value
          : this.totalBytes,
      etag: data.etag.present ? data.etag.value : this.etag,
      lastModified: data.lastModified.present
          ? data.lastModified.value
          : this.lastModified,
      error: data.error.present ? data.error.value : this.error,
      automatic: data.automatic.present ? data.automatic.value : this.automatic,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadJobRecord(')
          ..write('episodeId: $episodeId, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('filePath: $filePath, ')
          ..write('partialPath: $partialPath, ')
          ..write('state: $state, ')
          ..write('bytesDownloaded: $bytesDownloaded, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('etag: $etag, ')
          ..write('lastModified: $lastModified, ')
          ..write('error: $error, ')
          ..write('automatic: $automatic, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('playedAt: $playedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    episodeId,
    sourceUrl,
    filePath,
    partialPath,
    state,
    bytesDownloaded,
    totalBytes,
    etag,
    lastModified,
    error,
    automatic,
    attempts,
    nextAttemptAt,
    playedAt,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadJobRecord &&
          other.episodeId == this.episodeId &&
          other.sourceUrl == this.sourceUrl &&
          other.filePath == this.filePath &&
          other.partialPath == this.partialPath &&
          other.state == this.state &&
          other.bytesDownloaded == this.bytesDownloaded &&
          other.totalBytes == this.totalBytes &&
          other.etag == this.etag &&
          other.lastModified == this.lastModified &&
          other.error == this.error &&
          other.automatic == this.automatic &&
          other.attempts == this.attempts &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.playedAt == this.playedAt &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DownloadJobRowsCompanion extends UpdateCompanion<DownloadJobRecord> {
  final Value<int> episodeId;
  final Value<String> sourceUrl;
  final Value<String> filePath;
  final Value<String> partialPath;
  final Value<String> state;
  final Value<int> bytesDownloaded;
  final Value<int?> totalBytes;
  final Value<String?> etag;
  final Value<String?> lastModified;
  final Value<String?> error;
  final Value<bool> automatic;
  final Value<int> attempts;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime?> playedAt;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  const DownloadJobRowsCompanion({
    this.episodeId = const Value.absent(),
    this.sourceUrl = const Value.absent(),
    this.filePath = const Value.absent(),
    this.partialPath = const Value.absent(),
    this.state = const Value.absent(),
    this.bytesDownloaded = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.error = const Value.absent(),
    this.automatic = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  DownloadJobRowsCompanion.insert({
    this.episodeId = const Value.absent(),
    required String sourceUrl,
    required String filePath,
    required String partialPath,
    required String state,
    this.bytesDownloaded = const Value.absent(),
    this.totalBytes = const Value.absent(),
    this.etag = const Value.absent(),
    this.lastModified = const Value.absent(),
    this.error = const Value.absent(),
    this.automatic = const Value.absent(),
    this.attempts = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.playedAt = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : sourceUrl = Value(sourceUrl),
       filePath = Value(filePath),
       partialPath = Value(partialPath),
       state = Value(state),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<DownloadJobRecord> custom({
    Expression<int>? episodeId,
    Expression<String>? sourceUrl,
    Expression<String>? filePath,
    Expression<String>? partialPath,
    Expression<String>? state,
    Expression<int>? bytesDownloaded,
    Expression<int>? totalBytes,
    Expression<String>? etag,
    Expression<String>? lastModified,
    Expression<String>? error,
    Expression<bool>? automatic,
    Expression<int>? attempts,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? playedAt,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (sourceUrl != null) 'source_url': sourceUrl,
      if (filePath != null) 'file_path': filePath,
      if (partialPath != null) 'partial_path': partialPath,
      if (state != null) 'state': state,
      if (bytesDownloaded != null) 'bytes_downloaded': bytesDownloaded,
      if (totalBytes != null) 'total_bytes': totalBytes,
      if (etag != null) 'etag': etag,
      if (lastModified != null) 'last_modified': lastModified,
      if (error != null) 'error': error,
      if (automatic != null) 'automatic': automatic,
      if (attempts != null) 'attempts': attempts,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (playedAt != null) 'played_at': playedAt,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  DownloadJobRowsCompanion copyWith({
    Value<int>? episodeId,
    Value<String>? sourceUrl,
    Value<String>? filePath,
    Value<String>? partialPath,
    Value<String>? state,
    Value<int>? bytesDownloaded,
    Value<int?>? totalBytes,
    Value<String?>? etag,
    Value<String?>? lastModified,
    Value<String?>? error,
    Value<bool>? automatic,
    Value<int>? attempts,
    Value<DateTime?>? nextAttemptAt,
    Value<DateTime?>? playedAt,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
  }) {
    return DownloadJobRowsCompanion(
      episodeId: episodeId ?? this.episodeId,
      sourceUrl: sourceUrl ?? this.sourceUrl,
      filePath: filePath ?? this.filePath,
      partialPath: partialPath ?? this.partialPath,
      state: state ?? this.state,
      bytesDownloaded: bytesDownloaded ?? this.bytesDownloaded,
      totalBytes: totalBytes ?? this.totalBytes,
      etag: etag ?? this.etag,
      lastModified: lastModified ?? this.lastModified,
      error: error ?? this.error,
      automatic: automatic ?? this.automatic,
      attempts: attempts ?? this.attempts,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      playedAt: playedAt ?? this.playedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (sourceUrl.present) {
      map['source_url'] = Variable<String>(sourceUrl.value);
    }
    if (filePath.present) {
      map['file_path'] = Variable<String>(filePath.value);
    }
    if (partialPath.present) {
      map['partial_path'] = Variable<String>(partialPath.value);
    }
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (bytesDownloaded.present) {
      map['bytes_downloaded'] = Variable<int>(bytesDownloaded.value);
    }
    if (totalBytes.present) {
      map['total_bytes'] = Variable<int>(totalBytes.value);
    }
    if (etag.present) {
      map['etag'] = Variable<String>(etag.value);
    }
    if (lastModified.present) {
      map['last_modified'] = Variable<String>(lastModified.value);
    }
    if (error.present) {
      map['error'] = Variable<String>(error.value);
    }
    if (automatic.present) {
      map['automatic'] = Variable<bool>(automatic.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadJobRowsCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('sourceUrl: $sourceUrl, ')
          ..write('filePath: $filePath, ')
          ..write('partialPath: $partialPath, ')
          ..write('state: $state, ')
          ..write('bytesDownloaded: $bytesDownloaded, ')
          ..write('totalBytes: $totalBytes, ')
          ..write('etag: $etag, ')
          ..write('lastModified: $lastModified, ')
          ..write('error: $error, ')
          ..write('automatic: $automatic, ')
          ..write('attempts: $attempts, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('playedAt: $playedAt, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $DownloadPreferenceRowsTable extends DownloadPreferenceRows
    with TableInfo<$DownloadPreferenceRowsTable, DownloadPreferenceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DownloadPreferenceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _automaticMeta = const VerificationMeta(
    'automatic',
  );
  @override
  late final GeneratedColumn<bool> automatic = GeneratedColumn<bool>(
    'automatic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("automatic" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _episodeLimitMeta = const VerificationMeta(
    'episodeLimit',
  );
  @override
  late final GeneratedColumn<int> episodeLimit = GeneratedColumn<int>(
    'episode_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(3),
  );
  static const VerificationMeta _wifiOnlyMeta = const VerificationMeta(
    'wifiOnly',
  );
  @override
  late final GeneratedColumn<bool> wifiOnly = GeneratedColumn<bool>(
    'wifi_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("wifi_only" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _chargingOnlyMeta = const VerificationMeta(
    'chargingOnly',
  );
  @override
  late final GeneratedColumn<bool> chargingOnly = GeneratedColumn<bool>(
    'charging_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("charging_only" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _storageFloorBytesMeta = const VerificationMeta(
    'storageFloorBytes',
  );
  @override
  late final GeneratedColumn<int> storageFloorBytes = GeneratedColumn<int>(
    'storage_floor_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(500 * 1024 * 1024),
  );
  static const VerificationMeta _retentionMeta = const VerificationMeta(
    'retention',
  );
  @override
  late final GeneratedColumn<String> retention = GeneratedColumn<String>(
    'retention',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('never'),
  );
  static const VerificationMeta _retentionDelayHoursMeta =
      const VerificationMeta('retentionDelayHours');
  @override
  late final GeneratedColumn<int> retentionDelayHours = GeneratedColumn<int>(
    'retention_delay_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(24),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    automatic,
    episodeLimit,
    wifiOnly,
    chargingOnly,
    storageFloorBytes,
    retention,
    retentionDelayHours,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'download_preference_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<DownloadPreferenceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('automatic')) {
      context.handle(
        _automaticMeta,
        automatic.isAcceptableOrUnknown(data['automatic']!, _automaticMeta),
      );
    }
    if (data.containsKey('episode_limit')) {
      context.handle(
        _episodeLimitMeta,
        episodeLimit.isAcceptableOrUnknown(
          data['episode_limit']!,
          _episodeLimitMeta,
        ),
      );
    }
    if (data.containsKey('wifi_only')) {
      context.handle(
        _wifiOnlyMeta,
        wifiOnly.isAcceptableOrUnknown(data['wifi_only']!, _wifiOnlyMeta),
      );
    }
    if (data.containsKey('charging_only')) {
      context.handle(
        _chargingOnlyMeta,
        chargingOnly.isAcceptableOrUnknown(
          data['charging_only']!,
          _chargingOnlyMeta,
        ),
      );
    }
    if (data.containsKey('storage_floor_bytes')) {
      context.handle(
        _storageFloorBytesMeta,
        storageFloorBytes.isAcceptableOrUnknown(
          data['storage_floor_bytes']!,
          _storageFloorBytesMeta,
        ),
      );
    }
    if (data.containsKey('retention')) {
      context.handle(
        _retentionMeta,
        retention.isAcceptableOrUnknown(data['retention']!, _retentionMeta),
      );
    }
    if (data.containsKey('retention_delay_hours')) {
      context.handle(
        _retentionDelayHoursMeta,
        retentionDelayHours.isAcceptableOrUnknown(
          data['retention_delay_hours']!,
          _retentionDelayHoursMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DownloadPreferenceRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DownloadPreferenceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      automatic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}automatic'],
      )!,
      episodeLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_limit'],
      )!,
      wifiOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wifi_only'],
      )!,
      chargingOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}charging_only'],
      )!,
      storageFloorBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}storage_floor_bytes'],
      )!,
      retention: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retention'],
      )!,
      retentionDelayHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retention_delay_hours'],
      )!,
    );
  }

  @override
  $DownloadPreferenceRowsTable createAlias(String alias) {
    return $DownloadPreferenceRowsTable(attachedDatabase, alias);
  }
}

class DownloadPreferenceRecord extends DataClass
    implements Insertable<DownloadPreferenceRecord> {
  final int id;
  final bool automatic;
  final int episodeLimit;
  final bool wifiOnly;
  final bool chargingOnly;
  final int storageFloorBytes;
  final String retention;
  final int retentionDelayHours;
  const DownloadPreferenceRecord({
    required this.id,
    required this.automatic,
    required this.episodeLimit,
    required this.wifiOnly,
    required this.chargingOnly,
    required this.storageFloorBytes,
    required this.retention,
    required this.retentionDelayHours,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['automatic'] = Variable<bool>(automatic);
    map['episode_limit'] = Variable<int>(episodeLimit);
    map['wifi_only'] = Variable<bool>(wifiOnly);
    map['charging_only'] = Variable<bool>(chargingOnly);
    map['storage_floor_bytes'] = Variable<int>(storageFloorBytes);
    map['retention'] = Variable<String>(retention);
    map['retention_delay_hours'] = Variable<int>(retentionDelayHours);
    return map;
  }

  DownloadPreferenceRowsCompanion toCompanion(bool nullToAbsent) {
    return DownloadPreferenceRowsCompanion(
      id: Value(id),
      automatic: Value(automatic),
      episodeLimit: Value(episodeLimit),
      wifiOnly: Value(wifiOnly),
      chargingOnly: Value(chargingOnly),
      storageFloorBytes: Value(storageFloorBytes),
      retention: Value(retention),
      retentionDelayHours: Value(retentionDelayHours),
    );
  }

  factory DownloadPreferenceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DownloadPreferenceRecord(
      id: serializer.fromJson<int>(json['id']),
      automatic: serializer.fromJson<bool>(json['automatic']),
      episodeLimit: serializer.fromJson<int>(json['episodeLimit']),
      wifiOnly: serializer.fromJson<bool>(json['wifiOnly']),
      chargingOnly: serializer.fromJson<bool>(json['chargingOnly']),
      storageFloorBytes: serializer.fromJson<int>(json['storageFloorBytes']),
      retention: serializer.fromJson<String>(json['retention']),
      retentionDelayHours: serializer.fromJson<int>(
        json['retentionDelayHours'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'automatic': serializer.toJson<bool>(automatic),
      'episodeLimit': serializer.toJson<int>(episodeLimit),
      'wifiOnly': serializer.toJson<bool>(wifiOnly),
      'chargingOnly': serializer.toJson<bool>(chargingOnly),
      'storageFloorBytes': serializer.toJson<int>(storageFloorBytes),
      'retention': serializer.toJson<String>(retention),
      'retentionDelayHours': serializer.toJson<int>(retentionDelayHours),
    };
  }

  DownloadPreferenceRecord copyWith({
    int? id,
    bool? automatic,
    int? episodeLimit,
    bool? wifiOnly,
    bool? chargingOnly,
    int? storageFloorBytes,
    String? retention,
    int? retentionDelayHours,
  }) => DownloadPreferenceRecord(
    id: id ?? this.id,
    automatic: automatic ?? this.automatic,
    episodeLimit: episodeLimit ?? this.episodeLimit,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    chargingOnly: chargingOnly ?? this.chargingOnly,
    storageFloorBytes: storageFloorBytes ?? this.storageFloorBytes,
    retention: retention ?? this.retention,
    retentionDelayHours: retentionDelayHours ?? this.retentionDelayHours,
  );
  DownloadPreferenceRecord copyWithCompanion(
    DownloadPreferenceRowsCompanion data,
  ) {
    return DownloadPreferenceRecord(
      id: data.id.present ? data.id.value : this.id,
      automatic: data.automatic.present ? data.automatic.value : this.automatic,
      episodeLimit: data.episodeLimit.present
          ? data.episodeLimit.value
          : this.episodeLimit,
      wifiOnly: data.wifiOnly.present ? data.wifiOnly.value : this.wifiOnly,
      chargingOnly: data.chargingOnly.present
          ? data.chargingOnly.value
          : this.chargingOnly,
      storageFloorBytes: data.storageFloorBytes.present
          ? data.storageFloorBytes.value
          : this.storageFloorBytes,
      retention: data.retention.present ? data.retention.value : this.retention,
      retentionDelayHours: data.retentionDelayHours.present
          ? data.retentionDelayHours.value
          : this.retentionDelayHours,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DownloadPreferenceRecord(')
          ..write('id: $id, ')
          ..write('automatic: $automatic, ')
          ..write('episodeLimit: $episodeLimit, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('chargingOnly: $chargingOnly, ')
          ..write('storageFloorBytes: $storageFloorBytes, ')
          ..write('retention: $retention, ')
          ..write('retentionDelayHours: $retentionDelayHours')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    automatic,
    episodeLimit,
    wifiOnly,
    chargingOnly,
    storageFloorBytes,
    retention,
    retentionDelayHours,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DownloadPreferenceRecord &&
          other.id == this.id &&
          other.automatic == this.automatic &&
          other.episodeLimit == this.episodeLimit &&
          other.wifiOnly == this.wifiOnly &&
          other.chargingOnly == this.chargingOnly &&
          other.storageFloorBytes == this.storageFloorBytes &&
          other.retention == this.retention &&
          other.retentionDelayHours == this.retentionDelayHours);
}

class DownloadPreferenceRowsCompanion
    extends UpdateCompanion<DownloadPreferenceRecord> {
  final Value<int> id;
  final Value<bool> automatic;
  final Value<int> episodeLimit;
  final Value<bool> wifiOnly;
  final Value<bool> chargingOnly;
  final Value<int> storageFloorBytes;
  final Value<String> retention;
  final Value<int> retentionDelayHours;
  const DownloadPreferenceRowsCompanion({
    this.id = const Value.absent(),
    this.automatic = const Value.absent(),
    this.episodeLimit = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.chargingOnly = const Value.absent(),
    this.storageFloorBytes = const Value.absent(),
    this.retention = const Value.absent(),
    this.retentionDelayHours = const Value.absent(),
  });
  DownloadPreferenceRowsCompanion.insert({
    this.id = const Value.absent(),
    this.automatic = const Value.absent(),
    this.episodeLimit = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.chargingOnly = const Value.absent(),
    this.storageFloorBytes = const Value.absent(),
    this.retention = const Value.absent(),
    this.retentionDelayHours = const Value.absent(),
  });
  static Insertable<DownloadPreferenceRecord> custom({
    Expression<int>? id,
    Expression<bool>? automatic,
    Expression<int>? episodeLimit,
    Expression<bool>? wifiOnly,
    Expression<bool>? chargingOnly,
    Expression<int>? storageFloorBytes,
    Expression<String>? retention,
    Expression<int>? retentionDelayHours,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (automatic != null) 'automatic': automatic,
      if (episodeLimit != null) 'episode_limit': episodeLimit,
      if (wifiOnly != null) 'wifi_only': wifiOnly,
      if (chargingOnly != null) 'charging_only': chargingOnly,
      if (storageFloorBytes != null) 'storage_floor_bytes': storageFloorBytes,
      if (retention != null) 'retention': retention,
      if (retentionDelayHours != null)
        'retention_delay_hours': retentionDelayHours,
    });
  }

  DownloadPreferenceRowsCompanion copyWith({
    Value<int>? id,
    Value<bool>? automatic,
    Value<int>? episodeLimit,
    Value<bool>? wifiOnly,
    Value<bool>? chargingOnly,
    Value<int>? storageFloorBytes,
    Value<String>? retention,
    Value<int>? retentionDelayHours,
  }) {
    return DownloadPreferenceRowsCompanion(
      id: id ?? this.id,
      automatic: automatic ?? this.automatic,
      episodeLimit: episodeLimit ?? this.episodeLimit,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      chargingOnly: chargingOnly ?? this.chargingOnly,
      storageFloorBytes: storageFloorBytes ?? this.storageFloorBytes,
      retention: retention ?? this.retention,
      retentionDelayHours: retentionDelayHours ?? this.retentionDelayHours,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (automatic.present) {
      map['automatic'] = Variable<bool>(automatic.value);
    }
    if (episodeLimit.present) {
      map['episode_limit'] = Variable<int>(episodeLimit.value);
    }
    if (wifiOnly.present) {
      map['wifi_only'] = Variable<bool>(wifiOnly.value);
    }
    if (chargingOnly.present) {
      map['charging_only'] = Variable<bool>(chargingOnly.value);
    }
    if (storageFloorBytes.present) {
      map['storage_floor_bytes'] = Variable<int>(storageFloorBytes.value);
    }
    if (retention.present) {
      map['retention'] = Variable<String>(retention.value);
    }
    if (retentionDelayHours.present) {
      map['retention_delay_hours'] = Variable<int>(retentionDelayHours.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DownloadPreferenceRowsCompanion(')
          ..write('id: $id, ')
          ..write('automatic: $automatic, ')
          ..write('episodeLimit: $episodeLimit, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('chargingOnly: $chargingOnly, ')
          ..write('storageFloorBytes: $storageFloorBytes, ')
          ..write('retention: $retention, ')
          ..write('retentionDelayHours: $retentionDelayHours')
          ..write(')'))
        .toString();
  }
}

class $PodcastDownloadOverrideRowsTable extends PodcastDownloadOverrideRows
    with
        TableInfo<
          $PodcastDownloadOverrideRowsTable,
          PodcastDownloadOverrideRecord
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastDownloadOverrideRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _podcastIdMeta = const VerificationMeta(
    'podcastId',
  );
  @override
  late final GeneratedColumn<int> podcastId = GeneratedColumn<int>(
    'podcast_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES podcast_rows (id)',
    ),
  );
  static const VerificationMeta _automaticMeta = const VerificationMeta(
    'automatic',
  );
  @override
  late final GeneratedColumn<bool> automatic = GeneratedColumn<bool>(
    'automatic',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("automatic" IN (0, 1))',
    ),
  );
  static const VerificationMeta _episodeLimitMeta = const VerificationMeta(
    'episodeLimit',
  );
  @override
  late final GeneratedColumn<int> episodeLimit = GeneratedColumn<int>(
    'episode_limit',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _wifiOnlyMeta = const VerificationMeta(
    'wifiOnly',
  );
  @override
  late final GeneratedColumn<bool> wifiOnly = GeneratedColumn<bool>(
    'wifi_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("wifi_only" IN (0, 1))',
    ),
  );
  static const VerificationMeta _chargingOnlyMeta = const VerificationMeta(
    'chargingOnly',
  );
  @override
  late final GeneratedColumn<bool> chargingOnly = GeneratedColumn<bool>(
    'charging_only',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("charging_only" IN (0, 1))',
    ),
  );
  static const VerificationMeta _storageFloorBytesMeta = const VerificationMeta(
    'storageFloorBytes',
  );
  @override
  late final GeneratedColumn<int> storageFloorBytes = GeneratedColumn<int>(
    'storage_floor_bytes',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retentionMeta = const VerificationMeta(
    'retention',
  );
  @override
  late final GeneratedColumn<String> retention = GeneratedColumn<String>(
    'retention',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _retentionDelayHoursMeta =
      const VerificationMeta('retentionDelayHours');
  @override
  late final GeneratedColumn<int> retentionDelayHours = GeneratedColumn<int>(
    'retention_delay_hours',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    podcastId,
    automatic,
    episodeLimit,
    wifiOnly,
    chargingOnly,
    storageFloorBytes,
    retention,
    retentionDelayHours,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_download_override_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PodcastDownloadOverrideRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('podcast_id')) {
      context.handle(
        _podcastIdMeta,
        podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta),
      );
    }
    if (data.containsKey('automatic')) {
      context.handle(
        _automaticMeta,
        automatic.isAcceptableOrUnknown(data['automatic']!, _automaticMeta),
      );
    } else if (isInserting) {
      context.missing(_automaticMeta);
    }
    if (data.containsKey('episode_limit')) {
      context.handle(
        _episodeLimitMeta,
        episodeLimit.isAcceptableOrUnknown(
          data['episode_limit']!,
          _episodeLimitMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_episodeLimitMeta);
    }
    if (data.containsKey('wifi_only')) {
      context.handle(
        _wifiOnlyMeta,
        wifiOnly.isAcceptableOrUnknown(data['wifi_only']!, _wifiOnlyMeta),
      );
    } else if (isInserting) {
      context.missing(_wifiOnlyMeta);
    }
    if (data.containsKey('charging_only')) {
      context.handle(
        _chargingOnlyMeta,
        chargingOnly.isAcceptableOrUnknown(
          data['charging_only']!,
          _chargingOnlyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_chargingOnlyMeta);
    }
    if (data.containsKey('storage_floor_bytes')) {
      context.handle(
        _storageFloorBytesMeta,
        storageFloorBytes.isAcceptableOrUnknown(
          data['storage_floor_bytes']!,
          _storageFloorBytesMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storageFloorBytesMeta);
    }
    if (data.containsKey('retention')) {
      context.handle(
        _retentionMeta,
        retention.isAcceptableOrUnknown(data['retention']!, _retentionMeta),
      );
    } else if (isInserting) {
      context.missing(_retentionMeta);
    }
    if (data.containsKey('retention_delay_hours')) {
      context.handle(
        _retentionDelayHoursMeta,
        retentionDelayHours.isAcceptableOrUnknown(
          data['retention_delay_hours']!,
          _retentionDelayHoursMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_retentionDelayHoursMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {podcastId};
  @override
  PodcastDownloadOverrideRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastDownloadOverrideRecord(
      podcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}podcast_id'],
      )!,
      automatic: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}automatic'],
      )!,
      episodeLimit: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_limit'],
      )!,
      wifiOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}wifi_only'],
      )!,
      chargingOnly: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}charging_only'],
      )!,
      storageFloorBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}storage_floor_bytes'],
      )!,
      retention: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}retention'],
      )!,
      retentionDelayHours: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}retention_delay_hours'],
      )!,
    );
  }

  @override
  $PodcastDownloadOverrideRowsTable createAlias(String alias) {
    return $PodcastDownloadOverrideRowsTable(attachedDatabase, alias);
  }
}

class PodcastDownloadOverrideRecord extends DataClass
    implements Insertable<PodcastDownloadOverrideRecord> {
  final int podcastId;
  final bool automatic;
  final int episodeLimit;
  final bool wifiOnly;
  final bool chargingOnly;
  final int storageFloorBytes;
  final String retention;
  final int retentionDelayHours;
  const PodcastDownloadOverrideRecord({
    required this.podcastId,
    required this.automatic,
    required this.episodeLimit,
    required this.wifiOnly,
    required this.chargingOnly,
    required this.storageFloorBytes,
    required this.retention,
    required this.retentionDelayHours,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['podcast_id'] = Variable<int>(podcastId);
    map['automatic'] = Variable<bool>(automatic);
    map['episode_limit'] = Variable<int>(episodeLimit);
    map['wifi_only'] = Variable<bool>(wifiOnly);
    map['charging_only'] = Variable<bool>(chargingOnly);
    map['storage_floor_bytes'] = Variable<int>(storageFloorBytes);
    map['retention'] = Variable<String>(retention);
    map['retention_delay_hours'] = Variable<int>(retentionDelayHours);
    return map;
  }

  PodcastDownloadOverrideRowsCompanion toCompanion(bool nullToAbsent) {
    return PodcastDownloadOverrideRowsCompanion(
      podcastId: Value(podcastId),
      automatic: Value(automatic),
      episodeLimit: Value(episodeLimit),
      wifiOnly: Value(wifiOnly),
      chargingOnly: Value(chargingOnly),
      storageFloorBytes: Value(storageFloorBytes),
      retention: Value(retention),
      retentionDelayHours: Value(retentionDelayHours),
    );
  }

  factory PodcastDownloadOverrideRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastDownloadOverrideRecord(
      podcastId: serializer.fromJson<int>(json['podcastId']),
      automatic: serializer.fromJson<bool>(json['automatic']),
      episodeLimit: serializer.fromJson<int>(json['episodeLimit']),
      wifiOnly: serializer.fromJson<bool>(json['wifiOnly']),
      chargingOnly: serializer.fromJson<bool>(json['chargingOnly']),
      storageFloorBytes: serializer.fromJson<int>(json['storageFloorBytes']),
      retention: serializer.fromJson<String>(json['retention']),
      retentionDelayHours: serializer.fromJson<int>(
        json['retentionDelayHours'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'podcastId': serializer.toJson<int>(podcastId),
      'automatic': serializer.toJson<bool>(automatic),
      'episodeLimit': serializer.toJson<int>(episodeLimit),
      'wifiOnly': serializer.toJson<bool>(wifiOnly),
      'chargingOnly': serializer.toJson<bool>(chargingOnly),
      'storageFloorBytes': serializer.toJson<int>(storageFloorBytes),
      'retention': serializer.toJson<String>(retention),
      'retentionDelayHours': serializer.toJson<int>(retentionDelayHours),
    };
  }

  PodcastDownloadOverrideRecord copyWith({
    int? podcastId,
    bool? automatic,
    int? episodeLimit,
    bool? wifiOnly,
    bool? chargingOnly,
    int? storageFloorBytes,
    String? retention,
    int? retentionDelayHours,
  }) => PodcastDownloadOverrideRecord(
    podcastId: podcastId ?? this.podcastId,
    automatic: automatic ?? this.automatic,
    episodeLimit: episodeLimit ?? this.episodeLimit,
    wifiOnly: wifiOnly ?? this.wifiOnly,
    chargingOnly: chargingOnly ?? this.chargingOnly,
    storageFloorBytes: storageFloorBytes ?? this.storageFloorBytes,
    retention: retention ?? this.retention,
    retentionDelayHours: retentionDelayHours ?? this.retentionDelayHours,
  );
  PodcastDownloadOverrideRecord copyWithCompanion(
    PodcastDownloadOverrideRowsCompanion data,
  ) {
    return PodcastDownloadOverrideRecord(
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      automatic: data.automatic.present ? data.automatic.value : this.automatic,
      episodeLimit: data.episodeLimit.present
          ? data.episodeLimit.value
          : this.episodeLimit,
      wifiOnly: data.wifiOnly.present ? data.wifiOnly.value : this.wifiOnly,
      chargingOnly: data.chargingOnly.present
          ? data.chargingOnly.value
          : this.chargingOnly,
      storageFloorBytes: data.storageFloorBytes.present
          ? data.storageFloorBytes.value
          : this.storageFloorBytes,
      retention: data.retention.present ? data.retention.value : this.retention,
      retentionDelayHours: data.retentionDelayHours.present
          ? data.retentionDelayHours.value
          : this.retentionDelayHours,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastDownloadOverrideRecord(')
          ..write('podcastId: $podcastId, ')
          ..write('automatic: $automatic, ')
          ..write('episodeLimit: $episodeLimit, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('chargingOnly: $chargingOnly, ')
          ..write('storageFloorBytes: $storageFloorBytes, ')
          ..write('retention: $retention, ')
          ..write('retentionDelayHours: $retentionDelayHours')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    podcastId,
    automatic,
    episodeLimit,
    wifiOnly,
    chargingOnly,
    storageFloorBytes,
    retention,
    retentionDelayHours,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastDownloadOverrideRecord &&
          other.podcastId == this.podcastId &&
          other.automatic == this.automatic &&
          other.episodeLimit == this.episodeLimit &&
          other.wifiOnly == this.wifiOnly &&
          other.chargingOnly == this.chargingOnly &&
          other.storageFloorBytes == this.storageFloorBytes &&
          other.retention == this.retention &&
          other.retentionDelayHours == this.retentionDelayHours);
}

class PodcastDownloadOverrideRowsCompanion
    extends UpdateCompanion<PodcastDownloadOverrideRecord> {
  final Value<int> podcastId;
  final Value<bool> automatic;
  final Value<int> episodeLimit;
  final Value<bool> wifiOnly;
  final Value<bool> chargingOnly;
  final Value<int> storageFloorBytes;
  final Value<String> retention;
  final Value<int> retentionDelayHours;
  const PodcastDownloadOverrideRowsCompanion({
    this.podcastId = const Value.absent(),
    this.automatic = const Value.absent(),
    this.episodeLimit = const Value.absent(),
    this.wifiOnly = const Value.absent(),
    this.chargingOnly = const Value.absent(),
    this.storageFloorBytes = const Value.absent(),
    this.retention = const Value.absent(),
    this.retentionDelayHours = const Value.absent(),
  });
  PodcastDownloadOverrideRowsCompanion.insert({
    this.podcastId = const Value.absent(),
    required bool automatic,
    required int episodeLimit,
    required bool wifiOnly,
    required bool chargingOnly,
    required int storageFloorBytes,
    required String retention,
    required int retentionDelayHours,
  }) : automatic = Value(automatic),
       episodeLimit = Value(episodeLimit),
       wifiOnly = Value(wifiOnly),
       chargingOnly = Value(chargingOnly),
       storageFloorBytes = Value(storageFloorBytes),
       retention = Value(retention),
       retentionDelayHours = Value(retentionDelayHours);
  static Insertable<PodcastDownloadOverrideRecord> custom({
    Expression<int>? podcastId,
    Expression<bool>? automatic,
    Expression<int>? episodeLimit,
    Expression<bool>? wifiOnly,
    Expression<bool>? chargingOnly,
    Expression<int>? storageFloorBytes,
    Expression<String>? retention,
    Expression<int>? retentionDelayHours,
  }) {
    return RawValuesInsertable({
      if (podcastId != null) 'podcast_id': podcastId,
      if (automatic != null) 'automatic': automatic,
      if (episodeLimit != null) 'episode_limit': episodeLimit,
      if (wifiOnly != null) 'wifi_only': wifiOnly,
      if (chargingOnly != null) 'charging_only': chargingOnly,
      if (storageFloorBytes != null) 'storage_floor_bytes': storageFloorBytes,
      if (retention != null) 'retention': retention,
      if (retentionDelayHours != null)
        'retention_delay_hours': retentionDelayHours,
    });
  }

  PodcastDownloadOverrideRowsCompanion copyWith({
    Value<int>? podcastId,
    Value<bool>? automatic,
    Value<int>? episodeLimit,
    Value<bool>? wifiOnly,
    Value<bool>? chargingOnly,
    Value<int>? storageFloorBytes,
    Value<String>? retention,
    Value<int>? retentionDelayHours,
  }) {
    return PodcastDownloadOverrideRowsCompanion(
      podcastId: podcastId ?? this.podcastId,
      automatic: automatic ?? this.automatic,
      episodeLimit: episodeLimit ?? this.episodeLimit,
      wifiOnly: wifiOnly ?? this.wifiOnly,
      chargingOnly: chargingOnly ?? this.chargingOnly,
      storageFloorBytes: storageFloorBytes ?? this.storageFloorBytes,
      retention: retention ?? this.retention,
      retentionDelayHours: retentionDelayHours ?? this.retentionDelayHours,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (podcastId.present) {
      map['podcast_id'] = Variable<int>(podcastId.value);
    }
    if (automatic.present) {
      map['automatic'] = Variable<bool>(automatic.value);
    }
    if (episodeLimit.present) {
      map['episode_limit'] = Variable<int>(episodeLimit.value);
    }
    if (wifiOnly.present) {
      map['wifi_only'] = Variable<bool>(wifiOnly.value);
    }
    if (chargingOnly.present) {
      map['charging_only'] = Variable<bool>(chargingOnly.value);
    }
    if (storageFloorBytes.present) {
      map['storage_floor_bytes'] = Variable<int>(storageFloorBytes.value);
    }
    if (retention.present) {
      map['retention'] = Variable<String>(retention.value);
    }
    if (retentionDelayHours.present) {
      map['retention_delay_hours'] = Variable<int>(retentionDelayHours.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastDownloadOverrideRowsCompanion(')
          ..write('podcastId: $podcastId, ')
          ..write('automatic: $automatic, ')
          ..write('episodeLimit: $episodeLimit, ')
          ..write('wifiOnly: $wifiOnly, ')
          ..write('chargingOnly: $chargingOnly, ')
          ..write('storageFloorBytes: $storageFloorBytes, ')
          ..write('retention: $retention, ')
          ..write('retentionDelayHours: $retentionDelayHours')
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

class $InboxRowsTable extends InboxRows
    with TableInfo<$InboxRowsTable, InboxRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxRowsTable(this.attachedDatabase, [this._alias]);
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
  static const VerificationMeta _discoveredAtMeta = const VerificationMeta(
    'discoveredAt',
  );
  @override
  late final GeneratedColumn<DateTime> discoveredAt = GeneratedColumn<DateTime>(
    'discovered_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _removedAtMeta = const VerificationMeta(
    'removedAt',
  );
  @override
  late final GeneratedColumn<DateTime> removedAt = GeneratedColumn<DateTime>(
    'removed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [episodeId, discoveredAt, removedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxRecord> instance, {
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
    if (data.containsKey('discovered_at')) {
      context.handle(
        _discoveredAtMeta,
        discoveredAt.isAcceptableOrUnknown(
          data['discovered_at']!,
          _discoveredAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_discoveredAtMeta);
    }
    if (data.containsKey('removed_at')) {
      context.handle(
        _removedAtMeta,
        removedAt.isAcceptableOrUnknown(data['removed_at']!, _removedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {episodeId};
  @override
  InboxRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxRecord(
      episodeId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}episode_id'],
      )!,
      discoveredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}discovered_at'],
      )!,
      removedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}removed_at'],
      ),
    );
  }

  @override
  $InboxRowsTable createAlias(String alias) {
    return $InboxRowsTable(attachedDatabase, alias);
  }
}

class InboxRecord extends DataClass implements Insertable<InboxRecord> {
  final int episodeId;
  final DateTime discoveredAt;
  final DateTime? removedAt;
  const InboxRecord({
    required this.episodeId,
    required this.discoveredAt,
    this.removedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['episode_id'] = Variable<int>(episodeId);
    map['discovered_at'] = Variable<DateTime>(discoveredAt);
    if (!nullToAbsent || removedAt != null) {
      map['removed_at'] = Variable<DateTime>(removedAt);
    }
    return map;
  }

  InboxRowsCompanion toCompanion(bool nullToAbsent) {
    return InboxRowsCompanion(
      episodeId: Value(episodeId),
      discoveredAt: Value(discoveredAt),
      removedAt: removedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(removedAt),
    );
  }

  factory InboxRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxRecord(
      episodeId: serializer.fromJson<int>(json['episodeId']),
      discoveredAt: serializer.fromJson<DateTime>(json['discoveredAt']),
      removedAt: serializer.fromJson<DateTime?>(json['removedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'episodeId': serializer.toJson<int>(episodeId),
      'discoveredAt': serializer.toJson<DateTime>(discoveredAt),
      'removedAt': serializer.toJson<DateTime?>(removedAt),
    };
  }

  InboxRecord copyWith({
    int? episodeId,
    DateTime? discoveredAt,
    Value<DateTime?> removedAt = const Value.absent(),
  }) => InboxRecord(
    episodeId: episodeId ?? this.episodeId,
    discoveredAt: discoveredAt ?? this.discoveredAt,
    removedAt: removedAt.present ? removedAt.value : this.removedAt,
  );
  InboxRecord copyWithCompanion(InboxRowsCompanion data) {
    return InboxRecord(
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      discoveredAt: data.discoveredAt.present
          ? data.discoveredAt.value
          : this.discoveredAt,
      removedAt: data.removedAt.present ? data.removedAt.value : this.removedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxRecord(')
          ..write('episodeId: $episodeId, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('removedAt: $removedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(episodeId, discoveredAt, removedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxRecord &&
          other.episodeId == this.episodeId &&
          other.discoveredAt == this.discoveredAt &&
          other.removedAt == this.removedAt);
}

class InboxRowsCompanion extends UpdateCompanion<InboxRecord> {
  final Value<int> episodeId;
  final Value<DateTime> discoveredAt;
  final Value<DateTime?> removedAt;
  const InboxRowsCompanion({
    this.episodeId = const Value.absent(),
    this.discoveredAt = const Value.absent(),
    this.removedAt = const Value.absent(),
  });
  InboxRowsCompanion.insert({
    this.episodeId = const Value.absent(),
    required DateTime discoveredAt,
    this.removedAt = const Value.absent(),
  }) : discoveredAt = Value(discoveredAt);
  static Insertable<InboxRecord> custom({
    Expression<int>? episodeId,
    Expression<DateTime>? discoveredAt,
    Expression<DateTime>? removedAt,
  }) {
    return RawValuesInsertable({
      if (episodeId != null) 'episode_id': episodeId,
      if (discoveredAt != null) 'discovered_at': discoveredAt,
      if (removedAt != null) 'removed_at': removedAt,
    });
  }

  InboxRowsCompanion copyWith({
    Value<int>? episodeId,
    Value<DateTime>? discoveredAt,
    Value<DateTime?>? removedAt,
  }) {
    return InboxRowsCompanion(
      episodeId: episodeId ?? this.episodeId,
      discoveredAt: discoveredAt ?? this.discoveredAt,
      removedAt: removedAt ?? this.removedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (episodeId.present) {
      map['episode_id'] = Variable<int>(episodeId.value);
    }
    if (discoveredAt.present) {
      map['discovered_at'] = Variable<DateTime>(discoveredAt.value);
    }
    if (removedAt.present) {
      map['removed_at'] = Variable<DateTime>(removedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxRowsCompanion(')
          ..write('episodeId: $episodeId, ')
          ..write('discoveredAt: $discoveredAt, ')
          ..write('removedAt: $removedAt')
          ..write(')'))
        .toString();
  }
}

class $InboxPreferenceRowsTable extends InboxPreferenceRows
    with TableInfo<$InboxPreferenceRowsTable, InboxPreferencesRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $InboxPreferenceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _leftActionMeta = const VerificationMeta(
    'leftAction',
  );
  @override
  late final GeneratedColumn<String> leftAction = GeneratedColumn<String>(
    'left_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('remove'),
  );
  static const VerificationMeta _rightActionMeta = const VerificationMeta(
    'rightAction',
  );
  @override
  late final GeneratedColumn<String> rightAction = GeneratedColumn<String>(
    'right_action',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('queue'),
  );
  static const VerificationMeta _markRemovedAsPlayedMeta =
      const VerificationMeta('markRemovedAsPlayed');
  @override
  late final GeneratedColumn<bool> markRemovedAsPlayed = GeneratedColumn<bool>(
    'mark_removed_as_played',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("mark_removed_as_played" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    leftAction,
    rightAction,
    markRemovedAsPlayed,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'inbox_preference_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<InboxPreferencesRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('left_action')) {
      context.handle(
        _leftActionMeta,
        leftAction.isAcceptableOrUnknown(data['left_action']!, _leftActionMeta),
      );
    }
    if (data.containsKey('right_action')) {
      context.handle(
        _rightActionMeta,
        rightAction.isAcceptableOrUnknown(
          data['right_action']!,
          _rightActionMeta,
        ),
      );
    }
    if (data.containsKey('mark_removed_as_played')) {
      context.handle(
        _markRemovedAsPlayedMeta,
        markRemovedAsPlayed.isAcceptableOrUnknown(
          data['mark_removed_as_played']!,
          _markRemovedAsPlayedMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  InboxPreferencesRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return InboxPreferencesRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      leftAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}left_action'],
      )!,
      rightAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}right_action'],
      )!,
      markRemovedAsPlayed: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}mark_removed_as_played'],
      )!,
    );
  }

  @override
  $InboxPreferenceRowsTable createAlias(String alias) {
    return $InboxPreferenceRowsTable(attachedDatabase, alias);
  }
}

class InboxPreferencesRecord extends DataClass
    implements Insertable<InboxPreferencesRecord> {
  final int id;
  final String leftAction;
  final String rightAction;
  final bool markRemovedAsPlayed;
  const InboxPreferencesRecord({
    required this.id,
    required this.leftAction,
    required this.rightAction,
    required this.markRemovedAsPlayed,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['left_action'] = Variable<String>(leftAction);
    map['right_action'] = Variable<String>(rightAction);
    map['mark_removed_as_played'] = Variable<bool>(markRemovedAsPlayed);
    return map;
  }

  InboxPreferenceRowsCompanion toCompanion(bool nullToAbsent) {
    return InboxPreferenceRowsCompanion(
      id: Value(id),
      leftAction: Value(leftAction),
      rightAction: Value(rightAction),
      markRemovedAsPlayed: Value(markRemovedAsPlayed),
    );
  }

  factory InboxPreferencesRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return InboxPreferencesRecord(
      id: serializer.fromJson<int>(json['id']),
      leftAction: serializer.fromJson<String>(json['leftAction']),
      rightAction: serializer.fromJson<String>(json['rightAction']),
      markRemovedAsPlayed: serializer.fromJson<bool>(
        json['markRemovedAsPlayed'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'leftAction': serializer.toJson<String>(leftAction),
      'rightAction': serializer.toJson<String>(rightAction),
      'markRemovedAsPlayed': serializer.toJson<bool>(markRemovedAsPlayed),
    };
  }

  InboxPreferencesRecord copyWith({
    int? id,
    String? leftAction,
    String? rightAction,
    bool? markRemovedAsPlayed,
  }) => InboxPreferencesRecord(
    id: id ?? this.id,
    leftAction: leftAction ?? this.leftAction,
    rightAction: rightAction ?? this.rightAction,
    markRemovedAsPlayed: markRemovedAsPlayed ?? this.markRemovedAsPlayed,
  );
  InboxPreferencesRecord copyWithCompanion(InboxPreferenceRowsCompanion data) {
    return InboxPreferencesRecord(
      id: data.id.present ? data.id.value : this.id,
      leftAction: data.leftAction.present
          ? data.leftAction.value
          : this.leftAction,
      rightAction: data.rightAction.present
          ? data.rightAction.value
          : this.rightAction,
      markRemovedAsPlayed: data.markRemovedAsPlayed.present
          ? data.markRemovedAsPlayed.value
          : this.markRemovedAsPlayed,
    );
  }

  @override
  String toString() {
    return (StringBuffer('InboxPreferencesRecord(')
          ..write('id: $id, ')
          ..write('leftAction: $leftAction, ')
          ..write('rightAction: $rightAction, ')
          ..write('markRemovedAsPlayed: $markRemovedAsPlayed')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, leftAction, rightAction, markRemovedAsPlayed);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is InboxPreferencesRecord &&
          other.id == this.id &&
          other.leftAction == this.leftAction &&
          other.rightAction == this.rightAction &&
          other.markRemovedAsPlayed == this.markRemovedAsPlayed);
}

class InboxPreferenceRowsCompanion
    extends UpdateCompanion<InboxPreferencesRecord> {
  final Value<int> id;
  final Value<String> leftAction;
  final Value<String> rightAction;
  final Value<bool> markRemovedAsPlayed;
  const InboxPreferenceRowsCompanion({
    this.id = const Value.absent(),
    this.leftAction = const Value.absent(),
    this.rightAction = const Value.absent(),
    this.markRemovedAsPlayed = const Value.absent(),
  });
  InboxPreferenceRowsCompanion.insert({
    this.id = const Value.absent(),
    this.leftAction = const Value.absent(),
    this.rightAction = const Value.absent(),
    this.markRemovedAsPlayed = const Value.absent(),
  });
  static Insertable<InboxPreferencesRecord> custom({
    Expression<int>? id,
    Expression<String>? leftAction,
    Expression<String>? rightAction,
    Expression<bool>? markRemovedAsPlayed,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (leftAction != null) 'left_action': leftAction,
      if (rightAction != null) 'right_action': rightAction,
      if (markRemovedAsPlayed != null)
        'mark_removed_as_played': markRemovedAsPlayed,
    });
  }

  InboxPreferenceRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? leftAction,
    Value<String>? rightAction,
    Value<bool>? markRemovedAsPlayed,
  }) {
    return InboxPreferenceRowsCompanion(
      id: id ?? this.id,
      leftAction: leftAction ?? this.leftAction,
      rightAction: rightAction ?? this.rightAction,
      markRemovedAsPlayed: markRemovedAsPlayed ?? this.markRemovedAsPlayed,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (leftAction.present) {
      map['left_action'] = Variable<String>(leftAction.value);
    }
    if (rightAction.present) {
      map['right_action'] = Variable<String>(rightAction.value);
    }
    if (markRemovedAsPlayed.present) {
      map['mark_removed_as_played'] = Variable<bool>(markRemovedAsPlayed.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('InboxPreferenceRowsCompanion(')
          ..write('id: $id, ')
          ..write('leftAction: $leftAction, ')
          ..write('rightAction: $rightAction, ')
          ..write('markRemovedAsPlayed: $markRemovedAsPlayed')
          ..write(')'))
        .toString();
  }
}

class $PodcastInboxOverrideRowsTable extends PodcastInboxOverrideRows
    with TableInfo<$PodcastInboxOverrideRowsTable, PodcastInboxOverrideRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastInboxOverrideRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _podcastIdMeta = const VerificationMeta(
    'podcastId',
  );
  @override
  late final GeneratedColumn<int> podcastId = GeneratedColumn<int>(
    'podcast_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES podcast_rows (id)',
    ),
  );
  static const VerificationMeta _leftActionMeta = const VerificationMeta(
    'leftAction',
  );
  @override
  late final GeneratedColumn<String> leftAction = GeneratedColumn<String>(
    'left_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rightActionMeta = const VerificationMeta(
    'rightAction',
  );
  @override
  late final GeneratedColumn<String> rightAction = GeneratedColumn<String>(
    'right_action',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [podcastId, leftAction, rightAction];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_inbox_override_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PodcastInboxOverrideRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('podcast_id')) {
      context.handle(
        _podcastIdMeta,
        podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta),
      );
    }
    if (data.containsKey('left_action')) {
      context.handle(
        _leftActionMeta,
        leftAction.isAcceptableOrUnknown(data['left_action']!, _leftActionMeta),
      );
    }
    if (data.containsKey('right_action')) {
      context.handle(
        _rightActionMeta,
        rightAction.isAcceptableOrUnknown(
          data['right_action']!,
          _rightActionMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {podcastId};
  @override
  PodcastInboxOverrideRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastInboxOverrideRecord(
      podcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}podcast_id'],
      )!,
      leftAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}left_action'],
      ),
      rightAction: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}right_action'],
      ),
    );
  }

  @override
  $PodcastInboxOverrideRowsTable createAlias(String alias) {
    return $PodcastInboxOverrideRowsTable(attachedDatabase, alias);
  }
}

class PodcastInboxOverrideRecord extends DataClass
    implements Insertable<PodcastInboxOverrideRecord> {
  final int podcastId;
  final String? leftAction;
  final String? rightAction;
  const PodcastInboxOverrideRecord({
    required this.podcastId,
    this.leftAction,
    this.rightAction,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['podcast_id'] = Variable<int>(podcastId);
    if (!nullToAbsent || leftAction != null) {
      map['left_action'] = Variable<String>(leftAction);
    }
    if (!nullToAbsent || rightAction != null) {
      map['right_action'] = Variable<String>(rightAction);
    }
    return map;
  }

  PodcastInboxOverrideRowsCompanion toCompanion(bool nullToAbsent) {
    return PodcastInboxOverrideRowsCompanion(
      podcastId: Value(podcastId),
      leftAction: leftAction == null && nullToAbsent
          ? const Value.absent()
          : Value(leftAction),
      rightAction: rightAction == null && nullToAbsent
          ? const Value.absent()
          : Value(rightAction),
    );
  }

  factory PodcastInboxOverrideRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastInboxOverrideRecord(
      podcastId: serializer.fromJson<int>(json['podcastId']),
      leftAction: serializer.fromJson<String?>(json['leftAction']),
      rightAction: serializer.fromJson<String?>(json['rightAction']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'podcastId': serializer.toJson<int>(podcastId),
      'leftAction': serializer.toJson<String?>(leftAction),
      'rightAction': serializer.toJson<String?>(rightAction),
    };
  }

  PodcastInboxOverrideRecord copyWith({
    int? podcastId,
    Value<String?> leftAction = const Value.absent(),
    Value<String?> rightAction = const Value.absent(),
  }) => PodcastInboxOverrideRecord(
    podcastId: podcastId ?? this.podcastId,
    leftAction: leftAction.present ? leftAction.value : this.leftAction,
    rightAction: rightAction.present ? rightAction.value : this.rightAction,
  );
  PodcastInboxOverrideRecord copyWithCompanion(
    PodcastInboxOverrideRowsCompanion data,
  ) {
    return PodcastInboxOverrideRecord(
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      leftAction: data.leftAction.present
          ? data.leftAction.value
          : this.leftAction,
      rightAction: data.rightAction.present
          ? data.rightAction.value
          : this.rightAction,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastInboxOverrideRecord(')
          ..write('podcastId: $podcastId, ')
          ..write('leftAction: $leftAction, ')
          ..write('rightAction: $rightAction')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(podcastId, leftAction, rightAction);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastInboxOverrideRecord &&
          other.podcastId == this.podcastId &&
          other.leftAction == this.leftAction &&
          other.rightAction == this.rightAction);
}

class PodcastInboxOverrideRowsCompanion
    extends UpdateCompanion<PodcastInboxOverrideRecord> {
  final Value<int> podcastId;
  final Value<String?> leftAction;
  final Value<String?> rightAction;
  const PodcastInboxOverrideRowsCompanion({
    this.podcastId = const Value.absent(),
    this.leftAction = const Value.absent(),
    this.rightAction = const Value.absent(),
  });
  PodcastInboxOverrideRowsCompanion.insert({
    this.podcastId = const Value.absent(),
    this.leftAction = const Value.absent(),
    this.rightAction = const Value.absent(),
  });
  static Insertable<PodcastInboxOverrideRecord> custom({
    Expression<int>? podcastId,
    Expression<String>? leftAction,
    Expression<String>? rightAction,
  }) {
    return RawValuesInsertable({
      if (podcastId != null) 'podcast_id': podcastId,
      if (leftAction != null) 'left_action': leftAction,
      if (rightAction != null) 'right_action': rightAction,
    });
  }

  PodcastInboxOverrideRowsCompanion copyWith({
    Value<int>? podcastId,
    Value<String?>? leftAction,
    Value<String?>? rightAction,
  }) {
    return PodcastInboxOverrideRowsCompanion(
      podcastId: podcastId ?? this.podcastId,
      leftAction: leftAction ?? this.leftAction,
      rightAction: rightAction ?? this.rightAction,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (podcastId.present) {
      map['podcast_id'] = Variable<int>(podcastId.value);
    }
    if (leftAction.present) {
      map['left_action'] = Variable<String>(leftAction.value);
    }
    if (rightAction.present) {
      map['right_action'] = Variable<String>(rightAction.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastInboxOverrideRowsCompanion(')
          ..write('podcastId: $podcastId, ')
          ..write('leftAction: $leftAction, ')
          ..write('rightAction: $rightAction')
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
  static const VerificationMeta _stateMeta = const VerificationMeta('state');
  @override
  late final GeneratedColumn<String> state = GeneratedColumn<String>(
    'state',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _nextAttemptAtMeta = const VerificationMeta(
    'nextAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> nextAttemptAt =
      GeneratedColumn<DateTime>(
        'next_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastAttemptAtMeta = const VerificationMeta(
    'lastAttemptAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastAttemptAt =
      GeneratedColumn<DateTime>(
        'last_attempt_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _failedAtMeta = const VerificationMeta(
    'failedAt',
  );
  @override
  late final GeneratedColumn<DateTime> failedAt = GeneratedColumn<DateTime>(
    'failed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    type,
    episodeId,
    payload,
    createdAt,
    attempts,
    state,
    nextAttemptAt,
    lastAttemptAt,
    lastError,
    failedAt,
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
    if (data.containsKey('state')) {
      context.handle(
        _stateMeta,
        state.isAcceptableOrUnknown(data['state']!, _stateMeta),
      );
    }
    if (data.containsKey('next_attempt_at')) {
      context.handle(
        _nextAttemptAtMeta,
        nextAttemptAt.isAcceptableOrUnknown(
          data['next_attempt_at']!,
          _nextAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_attempt_at')) {
      context.handle(
        _lastAttemptAtMeta,
        lastAttemptAt.isAcceptableOrUnknown(
          data['last_attempt_at']!,
          _lastAttemptAtMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    if (data.containsKey('failed_at')) {
      context.handle(
        _failedAtMeta,
        failedAt.isAcceptableOrUnknown(data['failed_at']!, _failedAtMeta),
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
      state: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}state'],
      )!,
      nextAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}next_attempt_at'],
      ),
      lastAttemptAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_attempt_at'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
      failedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}failed_at'],
      ),
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
  final String state;
  final DateTime? nextAttemptAt;
  final DateTime? lastAttemptAt;
  final String? lastError;
  final DateTime? failedAt;
  const PendingMutation({
    required this.id,
    required this.type,
    this.episodeId,
    required this.payload,
    required this.createdAt,
    required this.attempts,
    required this.state,
    this.nextAttemptAt,
    this.lastAttemptAt,
    this.lastError,
    this.failedAt,
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
    map['state'] = Variable<String>(state);
    if (!nullToAbsent || nextAttemptAt != null) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt);
    }
    if (!nullToAbsent || lastAttemptAt != null) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    if (!nullToAbsent || failedAt != null) {
      map['failed_at'] = Variable<DateTime>(failedAt);
    }
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
      state: Value(state),
      nextAttemptAt: nextAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(nextAttemptAt),
      lastAttemptAt: lastAttemptAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastAttemptAt),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
      failedAt: failedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(failedAt),
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
      state: serializer.fromJson<String>(json['state']),
      nextAttemptAt: serializer.fromJson<DateTime?>(json['nextAttemptAt']),
      lastAttemptAt: serializer.fromJson<DateTime?>(json['lastAttemptAt']),
      lastError: serializer.fromJson<String?>(json['lastError']),
      failedAt: serializer.fromJson<DateTime?>(json['failedAt']),
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
      'state': serializer.toJson<String>(state),
      'nextAttemptAt': serializer.toJson<DateTime?>(nextAttemptAt),
      'lastAttemptAt': serializer.toJson<DateTime?>(lastAttemptAt),
      'lastError': serializer.toJson<String?>(lastError),
      'failedAt': serializer.toJson<DateTime?>(failedAt),
    };
  }

  PendingMutation copyWith({
    String? id,
    String? type,
    Value<int?> episodeId = const Value.absent(),
    String? payload,
    DateTime? createdAt,
    int? attempts,
    String? state,
    Value<DateTime?> nextAttemptAt = const Value.absent(),
    Value<DateTime?> lastAttemptAt = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
    Value<DateTime?> failedAt = const Value.absent(),
  }) => PendingMutation(
    id: id ?? this.id,
    type: type ?? this.type,
    episodeId: episodeId.present ? episodeId.value : this.episodeId,
    payload: payload ?? this.payload,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    state: state ?? this.state,
    nextAttemptAt: nextAttemptAt.present
        ? nextAttemptAt.value
        : this.nextAttemptAt,
    lastAttemptAt: lastAttemptAt.present
        ? lastAttemptAt.value
        : this.lastAttemptAt,
    lastError: lastError.present ? lastError.value : this.lastError,
    failedAt: failedAt.present ? failedAt.value : this.failedAt,
  );
  PendingMutation copyWithCompanion(SyncMutationsCompanion data) {
    return PendingMutation(
      id: data.id.present ? data.id.value : this.id,
      type: data.type.present ? data.type.value : this.type,
      episodeId: data.episodeId.present ? data.episodeId.value : this.episodeId,
      payload: data.payload.present ? data.payload.value : this.payload,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      state: data.state.present ? data.state.value : this.state,
      nextAttemptAt: data.nextAttemptAt.present
          ? data.nextAttemptAt.value
          : this.nextAttemptAt,
      lastAttemptAt: data.lastAttemptAt.present
          ? data.lastAttemptAt.value
          : this.lastAttemptAt,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
      failedAt: data.failedAt.present ? data.failedAt.value : this.failedAt,
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
          ..write('attempts: $attempts, ')
          ..write('state: $state, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('failedAt: $failedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    type,
    episodeId,
    payload,
    createdAt,
    attempts,
    state,
    nextAttemptAt,
    lastAttemptAt,
    lastError,
    failedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingMutation &&
          other.id == this.id &&
          other.type == this.type &&
          other.episodeId == this.episodeId &&
          other.payload == this.payload &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.state == this.state &&
          other.nextAttemptAt == this.nextAttemptAt &&
          other.lastAttemptAt == this.lastAttemptAt &&
          other.lastError == this.lastError &&
          other.failedAt == this.failedAt);
}

class SyncMutationsCompanion extends UpdateCompanion<PendingMutation> {
  final Value<String> id;
  final Value<String> type;
  final Value<int?> episodeId;
  final Value<String> payload;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String> state;
  final Value<DateTime?> nextAttemptAt;
  final Value<DateTime?> lastAttemptAt;
  final Value<String?> lastError;
  final Value<DateTime?> failedAt;
  final Value<int> rowid;
  const SyncMutationsCompanion({
    this.id = const Value.absent(),
    this.type = const Value.absent(),
    this.episodeId = const Value.absent(),
    this.payload = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.state = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.failedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncMutationsCompanion.insert({
    required String id,
    required String type,
    this.episodeId = const Value.absent(),
    this.payload = const Value.absent(),
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.state = const Value.absent(),
    this.nextAttemptAt = const Value.absent(),
    this.lastAttemptAt = const Value.absent(),
    this.lastError = const Value.absent(),
    this.failedAt = const Value.absent(),
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
    Expression<String>? state,
    Expression<DateTime>? nextAttemptAt,
    Expression<DateTime>? lastAttemptAt,
    Expression<String>? lastError,
    Expression<DateTime>? failedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (type != null) 'type': type,
      if (episodeId != null) 'episode_id': episodeId,
      if (payload != null) 'payload': payload,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (state != null) 'state': state,
      if (nextAttemptAt != null) 'next_attempt_at': nextAttemptAt,
      if (lastAttemptAt != null) 'last_attempt_at': lastAttemptAt,
      if (lastError != null) 'last_error': lastError,
      if (failedAt != null) 'failed_at': failedAt,
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
    Value<String>? state,
    Value<DateTime?>? nextAttemptAt,
    Value<DateTime?>? lastAttemptAt,
    Value<String?>? lastError,
    Value<DateTime?>? failedAt,
    Value<int>? rowid,
  }) {
    return SyncMutationsCompanion(
      id: id ?? this.id,
      type: type ?? this.type,
      episodeId: episodeId ?? this.episodeId,
      payload: payload ?? this.payload,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      state: state ?? this.state,
      nextAttemptAt: nextAttemptAt ?? this.nextAttemptAt,
      lastAttemptAt: lastAttemptAt ?? this.lastAttemptAt,
      lastError: lastError ?? this.lastError,
      failedAt: failedAt ?? this.failedAt,
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
    if (state.present) {
      map['state'] = Variable<String>(state.value);
    }
    if (nextAttemptAt.present) {
      map['next_attempt_at'] = Variable<DateTime>(nextAttemptAt.value);
    }
    if (lastAttemptAt.present) {
      map['last_attempt_at'] = Variable<DateTime>(lastAttemptAt.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (failedAt.present) {
      map['failed_at'] = Variable<DateTime>(failedAt.value);
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
          ..write('state: $state, ')
          ..write('nextAttemptAt: $nextAttemptAt, ')
          ..write('lastAttemptAt: $lastAttemptAt, ')
          ..write('lastError: $lastError, ')
          ..write('failedAt: $failedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QueueSyncStateRowsTable extends QueueSyncStateRows
    with TableInfo<$QueueSyncStateRowsTable, QueueSyncStateRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QueueSyncStateRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _revisionMeta = const VerificationMeta(
    'revision',
  );
  @override
  late final GeneratedColumn<String> revision = GeneratedColumn<String>(
    'revision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _orderJsonMeta = const VerificationMeta(
    'orderJson',
  );
  @override
  late final GeneratedColumn<String> orderJson = GeneratedColumn<String>(
    'order_json',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
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
  List<GeneratedColumn> get $columns => [id, revision, orderJson, updatedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'queue_sync_state_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<QueueSyncStateRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('revision')) {
      context.handle(
        _revisionMeta,
        revision.isAcceptableOrUnknown(data['revision']!, _revisionMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionMeta);
    }
    if (data.containsKey('order_json')) {
      context.handle(
        _orderJsonMeta,
        orderJson.isAcceptableOrUnknown(data['order_json']!, _orderJsonMeta),
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
  QueueSyncStateRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return QueueSyncStateRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      revision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}revision'],
      )!,
      orderJson: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}order_json'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $QueueSyncStateRowsTable createAlias(String alias) {
    return $QueueSyncStateRowsTable(attachedDatabase, alias);
  }
}

class QueueSyncStateRecord extends DataClass
    implements Insertable<QueueSyncStateRecord> {
  final int id;
  final String revision;
  final String orderJson;
  final DateTime updatedAt;
  const QueueSyncStateRecord({
    required this.id,
    required this.revision,
    required this.orderJson,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['revision'] = Variable<String>(revision);
    map['order_json'] = Variable<String>(orderJson);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  QueueSyncStateRowsCompanion toCompanion(bool nullToAbsent) {
    return QueueSyncStateRowsCompanion(
      id: Value(id),
      revision: Value(revision),
      orderJson: Value(orderJson),
      updatedAt: Value(updatedAt),
    );
  }

  factory QueueSyncStateRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return QueueSyncStateRecord(
      id: serializer.fromJson<int>(json['id']),
      revision: serializer.fromJson<String>(json['revision']),
      orderJson: serializer.fromJson<String>(json['orderJson']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'revision': serializer.toJson<String>(revision),
      'orderJson': serializer.toJson<String>(orderJson),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  QueueSyncStateRecord copyWith({
    int? id,
    String? revision,
    String? orderJson,
    DateTime? updatedAt,
  }) => QueueSyncStateRecord(
    id: id ?? this.id,
    revision: revision ?? this.revision,
    orderJson: orderJson ?? this.orderJson,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  QueueSyncStateRecord copyWithCompanion(QueueSyncStateRowsCompanion data) {
    return QueueSyncStateRecord(
      id: data.id.present ? data.id.value : this.id,
      revision: data.revision.present ? data.revision.value : this.revision,
      orderJson: data.orderJson.present ? data.orderJson.value : this.orderJson,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('QueueSyncStateRecord(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('orderJson: $orderJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, revision, orderJson, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is QueueSyncStateRecord &&
          other.id == this.id &&
          other.revision == this.revision &&
          other.orderJson == this.orderJson &&
          other.updatedAt == this.updatedAt);
}

class QueueSyncStateRowsCompanion
    extends UpdateCompanion<QueueSyncStateRecord> {
  final Value<int> id;
  final Value<String> revision;
  final Value<String> orderJson;
  final Value<DateTime> updatedAt;
  const QueueSyncStateRowsCompanion({
    this.id = const Value.absent(),
    this.revision = const Value.absent(),
    this.orderJson = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  QueueSyncStateRowsCompanion.insert({
    this.id = const Value.absent(),
    required String revision,
    this.orderJson = const Value.absent(),
    required DateTime updatedAt,
  }) : revision = Value(revision),
       updatedAt = Value(updatedAt);
  static Insertable<QueueSyncStateRecord> custom({
    Expression<int>? id,
    Expression<String>? revision,
    Expression<String>? orderJson,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (revision != null) 'revision': revision,
      if (orderJson != null) 'order_json': orderJson,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  QueueSyncStateRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? revision,
    Value<String>? orderJson,
    Value<DateTime>? updatedAt,
  }) {
    return QueueSyncStateRowsCompanion(
      id: id ?? this.id,
      revision: revision ?? this.revision,
      orderJson: orderJson ?? this.orderJson,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (revision.present) {
      map['revision'] = Variable<String>(revision.value);
    }
    if (orderJson.present) {
      map['order_json'] = Variable<String>(orderJson.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QueueSyncStateRowsCompanion(')
          ..write('id: $id, ')
          ..write('revision: $revision, ')
          ..write('orderJson: $orderJson, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

class $SyncDeviceRowsTable extends SyncDeviceRows
    with TableInfo<$SyncDeviceRowsTable, SyncDeviceRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncDeviceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _deviceIdMeta = const VerificationMeta(
    'deviceId',
  );
  @override
  late final GeneratedColumn<String> deviceId = GeneratedColumn<String>(
    'device_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
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
  @override
  List<GeneratedColumn> get $columns => [id, deviceId, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_device_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncDeviceRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('device_id')) {
      context.handle(
        _deviceIdMeta,
        deviceId.isAcceptableOrUnknown(data['device_id']!, _deviceIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deviceIdMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SyncDeviceRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncDeviceRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      deviceId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}device_id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $SyncDeviceRowsTable createAlias(String alias) {
    return $SyncDeviceRowsTable(attachedDatabase, alias);
  }
}

class SyncDeviceRecord extends DataClass
    implements Insertable<SyncDeviceRecord> {
  final int id;
  final String deviceId;
  final DateTime createdAt;
  const SyncDeviceRecord({
    required this.id,
    required this.deviceId,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['device_id'] = Variable<String>(deviceId);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  SyncDeviceRowsCompanion toCompanion(bool nullToAbsent) {
    return SyncDeviceRowsCompanion(
      id: Value(id),
      deviceId: Value(deviceId),
      createdAt: Value(createdAt),
    );
  }

  factory SyncDeviceRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncDeviceRecord(
      id: serializer.fromJson<int>(json['id']),
      deviceId: serializer.fromJson<String>(json['deviceId']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'deviceId': serializer.toJson<String>(deviceId),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  SyncDeviceRecord copyWith({int? id, String? deviceId, DateTime? createdAt}) =>
      SyncDeviceRecord(
        id: id ?? this.id,
        deviceId: deviceId ?? this.deviceId,
        createdAt: createdAt ?? this.createdAt,
      );
  SyncDeviceRecord copyWithCompanion(SyncDeviceRowsCompanion data) {
    return SyncDeviceRecord(
      id: data.id.present ? data.id.value : this.id,
      deviceId: data.deviceId.present ? data.deviceId.value : this.deviceId,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncDeviceRecord(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, deviceId, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncDeviceRecord &&
          other.id == this.id &&
          other.deviceId == this.deviceId &&
          other.createdAt == this.createdAt);
}

class SyncDeviceRowsCompanion extends UpdateCompanion<SyncDeviceRecord> {
  final Value<int> id;
  final Value<String> deviceId;
  final Value<DateTime> createdAt;
  const SyncDeviceRowsCompanion({
    this.id = const Value.absent(),
    this.deviceId = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SyncDeviceRowsCompanion.insert({
    this.id = const Value.absent(),
    required String deviceId,
    required DateTime createdAt,
  }) : deviceId = Value(deviceId),
       createdAt = Value(createdAt);
  static Insertable<SyncDeviceRecord> custom({
    Expression<int>? id,
    Expression<String>? deviceId,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deviceId != null) 'device_id': deviceId,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SyncDeviceRowsCompanion copyWith({
    Value<int>? id,
    Value<String>? deviceId,
    Value<DateTime>? createdAt,
  }) {
    return SyncDeviceRowsCompanion(
      id: id ?? this.id,
      deviceId: deviceId ?? this.deviceId,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (deviceId.present) {
      map['device_id'] = Variable<String>(deviceId.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncDeviceRowsCompanion(')
          ..write('id: $id, ')
          ..write('deviceId: $deviceId, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PlaybackPreferenceRowsTable extends PlaybackPreferenceRows
    with TableInfo<$PlaybackPreferenceRowsTable, PlaybackPreferencesRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlaybackPreferenceRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _skipSilenceMeta = const VerificationMeta(
    'skipSilence',
  );
  @override
  late final GeneratedColumn<String> skipSilence = GeneratedColumn<String>(
    'skip_silence',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('off'),
  );
  @override
  List<GeneratedColumn> get $columns => [id, speed, skipSilence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'playback_preference_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlaybackPreferencesRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('skip_silence')) {
      context.handle(
        _skipSilenceMeta,
        skipSilence.isAcceptableOrUnknown(
          data['skip_silence']!,
          _skipSilenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlaybackPreferencesRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlaybackPreferencesRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      )!,
      skipSilence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skip_silence'],
      )!,
    );
  }

  @override
  $PlaybackPreferenceRowsTable createAlias(String alias) {
    return $PlaybackPreferenceRowsTable(attachedDatabase, alias);
  }
}

class PlaybackPreferencesRecord extends DataClass
    implements Insertable<PlaybackPreferencesRecord> {
  final int id;
  final double speed;
  final String skipSilence;
  const PlaybackPreferencesRecord({
    required this.id,
    required this.speed,
    required this.skipSilence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['speed'] = Variable<double>(speed);
    map['skip_silence'] = Variable<String>(skipSilence);
    return map;
  }

  PlaybackPreferenceRowsCompanion toCompanion(bool nullToAbsent) {
    return PlaybackPreferenceRowsCompanion(
      id: Value(id),
      speed: Value(speed),
      skipSilence: Value(skipSilence),
    );
  }

  factory PlaybackPreferencesRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlaybackPreferencesRecord(
      id: serializer.fromJson<int>(json['id']),
      speed: serializer.fromJson<double>(json['speed']),
      skipSilence: serializer.fromJson<String>(json['skipSilence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'speed': serializer.toJson<double>(speed),
      'skipSilence': serializer.toJson<String>(skipSilence),
    };
  }

  PlaybackPreferencesRecord copyWith({
    int? id,
    double? speed,
    String? skipSilence,
  }) => PlaybackPreferencesRecord(
    id: id ?? this.id,
    speed: speed ?? this.speed,
    skipSilence: skipSilence ?? this.skipSilence,
  );
  PlaybackPreferencesRecord copyWithCompanion(
    PlaybackPreferenceRowsCompanion data,
  ) {
    return PlaybackPreferencesRecord(
      id: data.id.present ? data.id.value : this.id,
      speed: data.speed.present ? data.speed.value : this.speed,
      skipSilence: data.skipSilence.present
          ? data.skipSilence.value
          : this.skipSilence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackPreferencesRecord(')
          ..write('id: $id, ')
          ..write('speed: $speed, ')
          ..write('skipSilence: $skipSilence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, speed, skipSilence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlaybackPreferencesRecord &&
          other.id == this.id &&
          other.speed == this.speed &&
          other.skipSilence == this.skipSilence);
}

class PlaybackPreferenceRowsCompanion
    extends UpdateCompanion<PlaybackPreferencesRecord> {
  final Value<int> id;
  final Value<double> speed;
  final Value<String> skipSilence;
  const PlaybackPreferenceRowsCompanion({
    this.id = const Value.absent(),
    this.speed = const Value.absent(),
    this.skipSilence = const Value.absent(),
  });
  PlaybackPreferenceRowsCompanion.insert({
    this.id = const Value.absent(),
    this.speed = const Value.absent(),
    this.skipSilence = const Value.absent(),
  });
  static Insertable<PlaybackPreferencesRecord> custom({
    Expression<int>? id,
    Expression<double>? speed,
    Expression<String>? skipSilence,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (speed != null) 'speed': speed,
      if (skipSilence != null) 'skip_silence': skipSilence,
    });
  }

  PlaybackPreferenceRowsCompanion copyWith({
    Value<int>? id,
    Value<double>? speed,
    Value<String>? skipSilence,
  }) {
    return PlaybackPreferenceRowsCompanion(
      id: id ?? this.id,
      speed: speed ?? this.speed,
      skipSilence: skipSilence ?? this.skipSilence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (skipSilence.present) {
      map['skip_silence'] = Variable<String>(skipSilence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlaybackPreferenceRowsCompanion(')
          ..write('id: $id, ')
          ..write('speed: $speed, ')
          ..write('skipSilence: $skipSilence')
          ..write(')'))
        .toString();
  }
}

class $PodcastPlaybackOverrideRowsTable extends PodcastPlaybackOverrideRows
    with
        TableInfo<
          $PodcastPlaybackOverrideRowsTable,
          PodcastPlaybackOverrideRecord
        > {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PodcastPlaybackOverrideRowsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _podcastIdMeta = const VerificationMeta(
    'podcastId',
  );
  @override
  late final GeneratedColumn<int> podcastId = GeneratedColumn<int>(
    'podcast_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES podcast_rows (id)',
    ),
  );
  static const VerificationMeta _speedMeta = const VerificationMeta('speed');
  @override
  late final GeneratedColumn<double> speed = GeneratedColumn<double>(
    'speed',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _skipSilenceMeta = const VerificationMeta(
    'skipSilence',
  );
  @override
  late final GeneratedColumn<String> skipSilence = GeneratedColumn<String>(
    'skip_silence',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [podcastId, speed, skipSilence];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'podcast_playback_override_rows';
  @override
  VerificationContext validateIntegrity(
    Insertable<PodcastPlaybackOverrideRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('podcast_id')) {
      context.handle(
        _podcastIdMeta,
        podcastId.isAcceptableOrUnknown(data['podcast_id']!, _podcastIdMeta),
      );
    }
    if (data.containsKey('speed')) {
      context.handle(
        _speedMeta,
        speed.isAcceptableOrUnknown(data['speed']!, _speedMeta),
      );
    }
    if (data.containsKey('skip_silence')) {
      context.handle(
        _skipSilenceMeta,
        skipSilence.isAcceptableOrUnknown(
          data['skip_silence']!,
          _skipSilenceMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {podcastId};
  @override
  PodcastPlaybackOverrideRecord map(
    Map<String, dynamic> data, {
    String? tablePrefix,
  }) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PodcastPlaybackOverrideRecord(
      podcastId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}podcast_id'],
      )!,
      speed: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}speed'],
      ),
      skipSilence: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}skip_silence'],
      ),
    );
  }

  @override
  $PodcastPlaybackOverrideRowsTable createAlias(String alias) {
    return $PodcastPlaybackOverrideRowsTable(attachedDatabase, alias);
  }
}

class PodcastPlaybackOverrideRecord extends DataClass
    implements Insertable<PodcastPlaybackOverrideRecord> {
  final int podcastId;
  final double? speed;
  final String? skipSilence;
  const PodcastPlaybackOverrideRecord({
    required this.podcastId,
    this.speed,
    this.skipSilence,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['podcast_id'] = Variable<int>(podcastId);
    if (!nullToAbsent || speed != null) {
      map['speed'] = Variable<double>(speed);
    }
    if (!nullToAbsent || skipSilence != null) {
      map['skip_silence'] = Variable<String>(skipSilence);
    }
    return map;
  }

  PodcastPlaybackOverrideRowsCompanion toCompanion(bool nullToAbsent) {
    return PodcastPlaybackOverrideRowsCompanion(
      podcastId: Value(podcastId),
      speed: speed == null && nullToAbsent
          ? const Value.absent()
          : Value(speed),
      skipSilence: skipSilence == null && nullToAbsent
          ? const Value.absent()
          : Value(skipSilence),
    );
  }

  factory PodcastPlaybackOverrideRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PodcastPlaybackOverrideRecord(
      podcastId: serializer.fromJson<int>(json['podcastId']),
      speed: serializer.fromJson<double?>(json['speed']),
      skipSilence: serializer.fromJson<String?>(json['skipSilence']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'podcastId': serializer.toJson<int>(podcastId),
      'speed': serializer.toJson<double?>(speed),
      'skipSilence': serializer.toJson<String?>(skipSilence),
    };
  }

  PodcastPlaybackOverrideRecord copyWith({
    int? podcastId,
    Value<double?> speed = const Value.absent(),
    Value<String?> skipSilence = const Value.absent(),
  }) => PodcastPlaybackOverrideRecord(
    podcastId: podcastId ?? this.podcastId,
    speed: speed.present ? speed.value : this.speed,
    skipSilence: skipSilence.present ? skipSilence.value : this.skipSilence,
  );
  PodcastPlaybackOverrideRecord copyWithCompanion(
    PodcastPlaybackOverrideRowsCompanion data,
  ) {
    return PodcastPlaybackOverrideRecord(
      podcastId: data.podcastId.present ? data.podcastId.value : this.podcastId,
      speed: data.speed.present ? data.speed.value : this.speed,
      skipSilence: data.skipSilence.present
          ? data.skipSilence.value
          : this.skipSilence,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PodcastPlaybackOverrideRecord(')
          ..write('podcastId: $podcastId, ')
          ..write('speed: $speed, ')
          ..write('skipSilence: $skipSilence')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(podcastId, speed, skipSilence);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PodcastPlaybackOverrideRecord &&
          other.podcastId == this.podcastId &&
          other.speed == this.speed &&
          other.skipSilence == this.skipSilence);
}

class PodcastPlaybackOverrideRowsCompanion
    extends UpdateCompanion<PodcastPlaybackOverrideRecord> {
  final Value<int> podcastId;
  final Value<double?> speed;
  final Value<String?> skipSilence;
  const PodcastPlaybackOverrideRowsCompanion({
    this.podcastId = const Value.absent(),
    this.speed = const Value.absent(),
    this.skipSilence = const Value.absent(),
  });
  PodcastPlaybackOverrideRowsCompanion.insert({
    this.podcastId = const Value.absent(),
    this.speed = const Value.absent(),
    this.skipSilence = const Value.absent(),
  });
  static Insertable<PodcastPlaybackOverrideRecord> custom({
    Expression<int>? podcastId,
    Expression<double>? speed,
    Expression<String>? skipSilence,
  }) {
    return RawValuesInsertable({
      if (podcastId != null) 'podcast_id': podcastId,
      if (speed != null) 'speed': speed,
      if (skipSilence != null) 'skip_silence': skipSilence,
    });
  }

  PodcastPlaybackOverrideRowsCompanion copyWith({
    Value<int>? podcastId,
    Value<double?>? speed,
    Value<String?>? skipSilence,
  }) {
    return PodcastPlaybackOverrideRowsCompanion(
      podcastId: podcastId ?? this.podcastId,
      speed: speed ?? this.speed,
      skipSilence: skipSilence ?? this.skipSilence,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (podcastId.present) {
      map['podcast_id'] = Variable<int>(podcastId.value);
    }
    if (speed.present) {
      map['speed'] = Variable<double>(speed.value);
    }
    if (skipSilence.present) {
      map['skip_silence'] = Variable<String>(skipSilence.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PodcastPlaybackOverrideRowsCompanion(')
          ..write('podcastId: $podcastId, ')
          ..write('speed: $speed, ')
          ..write('skipSilence: $skipSilence')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $PodcastRowsTable podcastRows = $PodcastRowsTable(this);
  late final $DiscoveryCacheRowsTable discoveryCacheRows =
      $DiscoveryCacheRowsTable(this);
  late final $EpisodeRowsTable episodeRows = $EpisodeRowsTable(this);
  late final $DownloadJobRowsTable downloadJobRows = $DownloadJobRowsTable(
    this,
  );
  late final $DownloadPreferenceRowsTable downloadPreferenceRows =
      $DownloadPreferenceRowsTable(this);
  late final $PodcastDownloadOverrideRowsTable podcastDownloadOverrideRows =
      $PodcastDownloadOverrideRowsTable(this);
  late final $QueueRowsTable queueRows = $QueueRowsTable(this);
  late final $InboxRowsTable inboxRows = $InboxRowsTable(this);
  late final $InboxPreferenceRowsTable inboxPreferenceRows =
      $InboxPreferenceRowsTable(this);
  late final $PodcastInboxOverrideRowsTable podcastInboxOverrideRows =
      $PodcastInboxOverrideRowsTable(this);
  late final $SyncMutationsTable syncMutations = $SyncMutationsTable(this);
  late final $QueueSyncStateRowsTable queueSyncStateRows =
      $QueueSyncStateRowsTable(this);
  late final $SyncDeviceRowsTable syncDeviceRows = $SyncDeviceRowsTable(this);
  late final $PlaybackPreferenceRowsTable playbackPreferenceRows =
      $PlaybackPreferenceRowsTable(this);
  late final $PodcastPlaybackOverrideRowsTable podcastPlaybackOverrideRows =
      $PodcastPlaybackOverrideRowsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    podcastRows,
    discoveryCacheRows,
    episodeRows,
    downloadJobRows,
    downloadPreferenceRows,
    podcastDownloadOverrideRows,
    queueRows,
    inboxRows,
    inboxPreferenceRows,
    podcastInboxOverrideRows,
    syncMutations,
    queueSyncStateRows,
    syncDeviceRows,
    playbackPreferenceRows,
    podcastPlaybackOverrideRows,
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
      Value<String> websiteUrl,
      Value<String> categoriesJson,
      Value<bool> explicit,
      Value<int> podcastIndexId,
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
      Value<String> websiteUrl,
      Value<String> categoriesJson,
      Value<bool> explicit,
      Value<int> podcastIndexId,
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

  static MultiTypedResultKey<
    $PodcastDownloadOverrideRowsTable,
    List<PodcastDownloadOverrideRecord>
  >
  _podcastDownloadOverrideRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.podcastDownloadOverrideRows,
        aliasName:
            'podcast_rows__id__podcast_download_override_rows__podcast_id',
      );

  $$PodcastDownloadOverrideRowsTableProcessedTableManager
  get podcastDownloadOverrideRowsRefs {
    final manager = $$PodcastDownloadOverrideRowsTableTableManager(
      $_db,
      $_db.podcastDownloadOverrideRows,
    ).filter((f) => f.podcastId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _podcastDownloadOverrideRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PodcastInboxOverrideRowsTable,
    List<PodcastInboxOverrideRecord>
  >
  _podcastInboxOverrideRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.podcastInboxOverrideRows,
        aliasName: 'podcast_rows__id__podcast_inbox_override_rows__podcast_id',
      );

  $$PodcastInboxOverrideRowsTableProcessedTableManager
  get podcastInboxOverrideRowsRefs {
    final manager = $$PodcastInboxOverrideRowsTableTableManager(
      $_db,
      $_db.podcastInboxOverrideRows,
    ).filter((f) => f.podcastId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _podcastInboxOverrideRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<
    $PodcastPlaybackOverrideRowsTable,
    List<PodcastPlaybackOverrideRecord>
  >
  _podcastPlaybackOverrideRowsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.podcastPlaybackOverrideRows,
        aliasName:
            'podcast_rows__id__podcast_playback_override_rows__podcast_id',
      );

  $$PodcastPlaybackOverrideRowsTableProcessedTableManager
  get podcastPlaybackOverrideRowsRefs {
    final manager = $$PodcastPlaybackOverrideRowsTableTableManager(
      $_db,
      $_db.podcastPlaybackOverrideRows,
    ).filter((f) => f.podcastId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _podcastPlaybackOverrideRowsRefsTable($_db),
    );
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

  ColumnFilters<String> get websiteUrl => $composableBuilder(
    column: $table.websiteUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get categoriesJson => $composableBuilder(
    column: $table.categoriesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get podcastIndexId => $composableBuilder(
    column: $table.podcastIndexId,
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

  Expression<bool> podcastDownloadOverrideRowsRefs(
    Expression<bool> Function(
      $$PodcastDownloadOverrideRowsTableFilterComposer f,
    )
    f,
  ) {
    final $$PodcastDownloadOverrideRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.podcastDownloadOverrideRows,
          getReferencedColumn: (t) => t.podcastId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastDownloadOverrideRowsTableFilterComposer(
                $db: $db,
                $table: $db.podcastDownloadOverrideRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> podcastInboxOverrideRowsRefs(
    Expression<bool> Function($$PodcastInboxOverrideRowsTableFilterComposer f)
    f,
  ) {
    final $$PodcastInboxOverrideRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.podcastInboxOverrideRows,
          getReferencedColumn: (t) => t.podcastId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastInboxOverrideRowsTableFilterComposer(
                $db: $db,
                $table: $db.podcastInboxOverrideRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<bool> podcastPlaybackOverrideRowsRefs(
    Expression<bool> Function(
      $$PodcastPlaybackOverrideRowsTableFilterComposer f,
    )
    f,
  ) {
    final $$PodcastPlaybackOverrideRowsTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.podcastPlaybackOverrideRows,
          getReferencedColumn: (t) => t.podcastId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastPlaybackOverrideRowsTableFilterComposer(
                $db: $db,
                $table: $db.podcastPlaybackOverrideRows,
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

  ColumnOrderings<String> get websiteUrl => $composableBuilder(
    column: $table.websiteUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get categoriesJson => $composableBuilder(
    column: $table.categoriesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get explicit => $composableBuilder(
    column: $table.explicit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get podcastIndexId => $composableBuilder(
    column: $table.podcastIndexId,
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

  GeneratedColumn<String> get websiteUrl => $composableBuilder(
    column: $table.websiteUrl,
    builder: (column) => column,
  );

  GeneratedColumn<String> get categoriesJson => $composableBuilder(
    column: $table.categoriesJson,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get explicit =>
      $composableBuilder(column: $table.explicit, builder: (column) => column);

  GeneratedColumn<int> get podcastIndexId => $composableBuilder(
    column: $table.podcastIndexId,
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

  Expression<T> podcastDownloadOverrideRowsRefs<T extends Object>(
    Expression<T> Function(
      $$PodcastDownloadOverrideRowsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$PodcastDownloadOverrideRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.podcastDownloadOverrideRows,
          getReferencedColumn: (t) => t.podcastId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastDownloadOverrideRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.podcastDownloadOverrideRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> podcastInboxOverrideRowsRefs<T extends Object>(
    Expression<T> Function($$PodcastInboxOverrideRowsTableAnnotationComposer a)
    f,
  ) {
    final $$PodcastInboxOverrideRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.podcastInboxOverrideRows,
          getReferencedColumn: (t) => t.podcastId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastInboxOverrideRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.podcastInboxOverrideRows,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> podcastPlaybackOverrideRowsRefs<T extends Object>(
    Expression<T> Function(
      $$PodcastPlaybackOverrideRowsTableAnnotationComposer a,
    )
    f,
  ) {
    final $$PodcastPlaybackOverrideRowsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.podcastPlaybackOverrideRows,
          getReferencedColumn: (t) => t.podcastId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PodcastPlaybackOverrideRowsTableAnnotationComposer(
                $db: $db,
                $table: $db.podcastPlaybackOverrideRows,
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
          PrefetchHooks Function({
            bool episodeRowsRefs,
            bool podcastDownloadOverrideRowsRefs,
            bool podcastInboxOverrideRowsRefs,
            bool podcastPlaybackOverrideRowsRefs,
          })
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
                Value<String> websiteUrl = const Value.absent(),
                Value<String> categoriesJson = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<int> podcastIndexId = const Value.absent(),
              }) => PodcastRowsCompanion(
                id: id,
                title: title,
                author: author,
                artworkUrl: artworkUrl,
                description: description,
                feedUrl: feedUrl,
                episodeCount: episodeCount,
                websiteUrl: websiteUrl,
                categoriesJson: categoriesJson,
                explicit: explicit,
                podcastIndexId: podcastIndexId,
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
                Value<String> websiteUrl = const Value.absent(),
                Value<String> categoriesJson = const Value.absent(),
                Value<bool> explicit = const Value.absent(),
                Value<int> podcastIndexId = const Value.absent(),
              }) => PodcastRowsCompanion.insert(
                id: id,
                title: title,
                author: author,
                artworkUrl: artworkUrl,
                description: description,
                feedUrl: feedUrl,
                episodeCount: episodeCount,
                websiteUrl: websiteUrl,
                categoriesJson: categoriesJson,
                explicit: explicit,
                podcastIndexId: podcastIndexId,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PodcastRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                episodeRowsRefs = false,
                podcastDownloadOverrideRowsRefs = false,
                podcastInboxOverrideRowsRefs = false,
                podcastPlaybackOverrideRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (episodeRowsRefs) db.episodeRows,
                    if (podcastDownloadOverrideRowsRefs)
                      db.podcastDownloadOverrideRows,
                    if (podcastInboxOverrideRowsRefs)
                      db.podcastInboxOverrideRows,
                    if (podcastPlaybackOverrideRowsRefs)
                      db.podcastPlaybackOverrideRows,
                  ],
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.podcastId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (podcastDownloadOverrideRowsRefs)
                        await $_getPrefetchedData<
                          PodcastRecord,
                          $PodcastRowsTable,
                          PodcastDownloadOverrideRecord
                        >(
                          currentTable: table,
                          referencedTable: $$PodcastRowsTableReferences
                              ._podcastDownloadOverrideRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PodcastRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).podcastDownloadOverrideRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.podcastId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (podcastInboxOverrideRowsRefs)
                        await $_getPrefetchedData<
                          PodcastRecord,
                          $PodcastRowsTable,
                          PodcastInboxOverrideRecord
                        >(
                          currentTable: table,
                          referencedTable: $$PodcastRowsTableReferences
                              ._podcastInboxOverrideRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PodcastRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).podcastInboxOverrideRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.podcastId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (podcastPlaybackOverrideRowsRefs)
                        await $_getPrefetchedData<
                          PodcastRecord,
                          $PodcastRowsTable,
                          PodcastPlaybackOverrideRecord
                        >(
                          currentTable: table,
                          referencedTable: $$PodcastRowsTableReferences
                              ._podcastPlaybackOverrideRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PodcastRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).podcastPlaybackOverrideRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.podcastId == item.id,
                              ),
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
      PrefetchHooks Function({
        bool episodeRowsRefs,
        bool podcastDownloadOverrideRowsRefs,
        bool podcastInboxOverrideRowsRefs,
        bool podcastPlaybackOverrideRowsRefs,
      })
    >;
typedef $$DiscoveryCacheRowsTableCreateCompanionBuilder =
    DiscoveryCacheRowsCompanion Function({
      required String feedUrl,
      required String title,
      required String podcastJson,
      Value<String> episodesJson,
      required DateTime cachedAt,
      Value<int> rowid,
    });
typedef $$DiscoveryCacheRowsTableUpdateCompanionBuilder =
    DiscoveryCacheRowsCompanion Function({
      Value<String> feedUrl,
      Value<String> title,
      Value<String> podcastJson,
      Value<String> episodesJson,
      Value<DateTime> cachedAt,
      Value<int> rowid,
    });

class $$DiscoveryCacheRowsTableFilterComposer
    extends Composer<_$AppDatabase, $DiscoveryCacheRowsTable> {
  $$DiscoveryCacheRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get podcastJson => $composableBuilder(
    column: $table.podcastJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get episodesJson => $composableBuilder(
    column: $table.episodesJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DiscoveryCacheRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $DiscoveryCacheRowsTable> {
  $$DiscoveryCacheRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get feedUrl => $composableBuilder(
    column: $table.feedUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get podcastJson => $composableBuilder(
    column: $table.podcastJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get episodesJson => $composableBuilder(
    column: $table.episodesJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get cachedAt => $composableBuilder(
    column: $table.cachedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DiscoveryCacheRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DiscoveryCacheRowsTable> {
  $$DiscoveryCacheRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get feedUrl =>
      $composableBuilder(column: $table.feedUrl, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get podcastJson => $composableBuilder(
    column: $table.podcastJson,
    builder: (column) => column,
  );

  GeneratedColumn<String> get episodesJson => $composableBuilder(
    column: $table.episodesJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get cachedAt =>
      $composableBuilder(column: $table.cachedAt, builder: (column) => column);
}

class $$DiscoveryCacheRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DiscoveryCacheRowsTable,
          DiscoveryCacheRecord,
          $$DiscoveryCacheRowsTableFilterComposer,
          $$DiscoveryCacheRowsTableOrderingComposer,
          $$DiscoveryCacheRowsTableAnnotationComposer,
          $$DiscoveryCacheRowsTableCreateCompanionBuilder,
          $$DiscoveryCacheRowsTableUpdateCompanionBuilder,
          (
            DiscoveryCacheRecord,
            BaseReferences<
              _$AppDatabase,
              $DiscoveryCacheRowsTable,
              DiscoveryCacheRecord
            >,
          ),
          DiscoveryCacheRecord,
          PrefetchHooks Function()
        > {
  $$DiscoveryCacheRowsTableTableManager(
    _$AppDatabase db,
    $DiscoveryCacheRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DiscoveryCacheRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DiscoveryCacheRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DiscoveryCacheRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> feedUrl = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<String> podcastJson = const Value.absent(),
                Value<String> episodesJson = const Value.absent(),
                Value<DateTime> cachedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DiscoveryCacheRowsCompanion(
                feedUrl: feedUrl,
                title: title,
                podcastJson: podcastJson,
                episodesJson: episodesJson,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String feedUrl,
                required String title,
                required String podcastJson,
                Value<String> episodesJson = const Value.absent(),
                required DateTime cachedAt,
                Value<int> rowid = const Value.absent(),
              }) => DiscoveryCacheRowsCompanion.insert(
                feedUrl: feedUrl,
                title: title,
                podcastJson: podcastJson,
                episodesJson: episodesJson,
                cachedAt: cachedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DiscoveryCacheRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DiscoveryCacheRowsTable,
      DiscoveryCacheRecord,
      $$DiscoveryCacheRowsTableFilterComposer,
      $$DiscoveryCacheRowsTableOrderingComposer,
      $$DiscoveryCacheRowsTableAnnotationComposer,
      $$DiscoveryCacheRowsTableCreateCompanionBuilder,
      $$DiscoveryCacheRowsTableUpdateCompanionBuilder,
      (
        DiscoveryCacheRecord,
        BaseReferences<
          _$AppDatabase,
          $DiscoveryCacheRowsTable,
          DiscoveryCacheRecord
        >,
      ),
      DiscoveryCacheRecord,
      PrefetchHooks Function()
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
      Value<String> chaptersJson,
      Value<DateTime?> playbackUpdatedAt,
      Value<String?> playbackDeviceId,
      Value<String> playbackIntent,
      Value<String> playbackMediaIdentity,
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
      Value<String> chaptersJson,
      Value<DateTime?> playbackUpdatedAt,
      Value<String?> playbackDeviceId,
      Value<String> playbackIntent,
      Value<String> playbackMediaIdentity,
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

  static MultiTypedResultKey<$DownloadJobRowsTable, List<DownloadJobRecord>>
  _downloadJobRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.downloadJobRows,
    aliasName: 'episode_rows__id__download_job_rows__episode_id',
  );

  $$DownloadJobRowsTableProcessedTableManager get downloadJobRowsRefs {
    final manager = $$DownloadJobRowsTableTableManager(
      $_db,
      $_db.downloadJobRows,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _downloadJobRowsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
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

  static MultiTypedResultKey<$InboxRowsTable, List<InboxRecord>>
  _inboxRowsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.inboxRows,
    aliasName: 'episode_rows__id__inbox_rows__episode_id',
  );

  $$InboxRowsTableProcessedTableManager get inboxRowsRefs {
    final manager = $$InboxRowsTableTableManager(
      $_db,
      $_db.inboxRows,
    ).filter((f) => f.episodeId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_inboxRowsRefsTable($_db));
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

  ColumnFilters<String> get chaptersJson => $composableBuilder(
    column: $table.chaptersJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playbackUpdatedAt => $composableBuilder(
    column: $table.playbackUpdatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playbackDeviceId => $composableBuilder(
    column: $table.playbackDeviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playbackIntent => $composableBuilder(
    column: $table.playbackIntent,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get playbackMediaIdentity => $composableBuilder(
    column: $table.playbackMediaIdentity,
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

  Expression<bool> downloadJobRowsRefs(
    Expression<bool> Function($$DownloadJobRowsTableFilterComposer f) f,
  ) {
    final $$DownloadJobRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadJobRows,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadJobRowsTableFilterComposer(
            $db: $db,
            $table: $db.downloadJobRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  Expression<bool> inboxRowsRefs(
    Expression<bool> Function($$InboxRowsTableFilterComposer f) f,
  ) {
    final $$InboxRowsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inboxRows,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InboxRowsTableFilterComposer(
            $db: $db,
            $table: $db.inboxRows,
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

  ColumnOrderings<String> get chaptersJson => $composableBuilder(
    column: $table.chaptersJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playbackUpdatedAt => $composableBuilder(
    column: $table.playbackUpdatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playbackDeviceId => $composableBuilder(
    column: $table.playbackDeviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playbackIntent => $composableBuilder(
    column: $table.playbackIntent,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get playbackMediaIdentity => $composableBuilder(
    column: $table.playbackMediaIdentity,
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

  GeneratedColumn<String> get chaptersJson => $composableBuilder(
    column: $table.chaptersJson,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get playbackUpdatedAt => $composableBuilder(
    column: $table.playbackUpdatedAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playbackDeviceId => $composableBuilder(
    column: $table.playbackDeviceId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playbackIntent => $composableBuilder(
    column: $table.playbackIntent,
    builder: (column) => column,
  );

  GeneratedColumn<String> get playbackMediaIdentity => $composableBuilder(
    column: $table.playbackMediaIdentity,
    builder: (column) => column,
  );

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

  Expression<T> downloadJobRowsRefs<T extends Object>(
    Expression<T> Function($$DownloadJobRowsTableAnnotationComposer a) f,
  ) {
    final $$DownloadJobRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.downloadJobRows,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DownloadJobRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.downloadJobRows,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
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

  Expression<T> inboxRowsRefs<T extends Object>(
    Expression<T> Function($$InboxRowsTableAnnotationComposer a) f,
  ) {
    final $$InboxRowsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.inboxRows,
      getReferencedColumn: (t) => t.episodeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$InboxRowsTableAnnotationComposer(
            $db: $db,
            $table: $db.inboxRows,
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
          PrefetchHooks Function({
            bool podcastId,
            bool downloadJobRowsRefs,
            bool queueRowsRefs,
            bool inboxRowsRefs,
          })
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
                Value<String> chaptersJson = const Value.absent(),
                Value<DateTime?> playbackUpdatedAt = const Value.absent(),
                Value<String?> playbackDeviceId = const Value.absent(),
                Value<String> playbackIntent = const Value.absent(),
                Value<String> playbackMediaIdentity = const Value.absent(),
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
                chaptersJson: chaptersJson,
                playbackUpdatedAt: playbackUpdatedAt,
                playbackDeviceId: playbackDeviceId,
                playbackIntent: playbackIntent,
                playbackMediaIdentity: playbackMediaIdentity,
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
                Value<String> chaptersJson = const Value.absent(),
                Value<DateTime?> playbackUpdatedAt = const Value.absent(),
                Value<String?> playbackDeviceId = const Value.absent(),
                Value<String> playbackIntent = const Value.absent(),
                Value<String> playbackMediaIdentity = const Value.absent(),
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
                chaptersJson: chaptersJson,
                playbackUpdatedAt: playbackUpdatedAt,
                playbackDeviceId: playbackDeviceId,
                playbackIntent: playbackIntent,
                playbackMediaIdentity: playbackMediaIdentity,
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
          prefetchHooksCallback:
              ({
                podcastId = false,
                downloadJobRowsRefs = false,
                queueRowsRefs = false,
                inboxRowsRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (downloadJobRowsRefs) db.downloadJobRows,
                    if (queueRowsRefs) db.queueRows,
                    if (inboxRowsRefs) db.inboxRows,
                  ],
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
                                    referencedTable:
                                        $$EpisodeRowsTableReferences
                                            ._podcastIdTable(db),
                                    referencedColumn:
                                        $$EpisodeRowsTableReferences
                                            ._podcastIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (downloadJobRowsRefs)
                        await $_getPrefetchedData<
                          EpisodeRecord,
                          $EpisodeRowsTable,
                          DownloadJobRecord
                        >(
                          currentTable: table,
                          referencedTable: $$EpisodeRowsTableReferences
                              ._downloadJobRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EpisodeRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).downloadJobRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
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
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (inboxRowsRefs)
                        await $_getPrefetchedData<
                          EpisodeRecord,
                          $EpisodeRowsTable,
                          InboxRecord
                        >(
                          currentTable: table,
                          referencedTable: $$EpisodeRowsTableReferences
                              ._inboxRowsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$EpisodeRowsTableReferences(
                                db,
                                table,
                                p0,
                              ).inboxRowsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.episodeId == item.id,
                              ),
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
      PrefetchHooks Function({
        bool podcastId,
        bool downloadJobRowsRefs,
        bool queueRowsRefs,
        bool inboxRowsRefs,
      })
    >;
typedef $$DownloadJobRowsTableCreateCompanionBuilder =
    DownloadJobRowsCompanion Function({
      Value<int> episodeId,
      required String sourceUrl,
      required String filePath,
      required String partialPath,
      required String state,
      Value<int> bytesDownloaded,
      Value<int?> totalBytes,
      Value<String?> etag,
      Value<String?> lastModified,
      Value<String?> error,
      Value<bool> automatic,
      Value<int> attempts,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime?> playedAt,
      required DateTime createdAt,
      required DateTime updatedAt,
    });
typedef $$DownloadJobRowsTableUpdateCompanionBuilder =
    DownloadJobRowsCompanion Function({
      Value<int> episodeId,
      Value<String> sourceUrl,
      Value<String> filePath,
      Value<String> partialPath,
      Value<String> state,
      Value<int> bytesDownloaded,
      Value<int?> totalBytes,
      Value<String?> etag,
      Value<String?> lastModified,
      Value<String?> error,
      Value<bool> automatic,
      Value<int> attempts,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime?> playedAt,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
    });

final class $$DownloadJobRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $DownloadJobRowsTable,
          DownloadJobRecord
        > {
  $$DownloadJobRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $EpisodeRowsTable _episodeIdTable(_$AppDatabase db) => db.episodeRows
      .createAlias('download_job_rows__episode_id__episode_rows__id');

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

class $$DownloadJobRowsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadJobRowsTable> {
  $$DownloadJobRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get partialPath => $composableBuilder(
    column: $table.partialPath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get bytesDownloaded => $composableBuilder(
    column: $table.bytesDownloaded,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get automatic => $composableBuilder(
    column: $table.automatic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
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

class $$DownloadJobRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadJobRowsTable> {
  $$DownloadJobRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get sourceUrl => $composableBuilder(
    column: $table.sourceUrl,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get filePath => $composableBuilder(
    column: $table.filePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get partialPath => $composableBuilder(
    column: $table.partialPath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get bytesDownloaded => $composableBuilder(
    column: $table.bytesDownloaded,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get etag => $composableBuilder(
    column: $table.etag,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get error => $composableBuilder(
    column: $table.error,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get automatic => $composableBuilder(
    column: $table.automatic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
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

class $$DownloadJobRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadJobRowsTable> {
  $$DownloadJobRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get sourceUrl =>
      $composableBuilder(column: $table.sourceUrl, builder: (column) => column);

  GeneratedColumn<String> get filePath =>
      $composableBuilder(column: $table.filePath, builder: (column) => column);

  GeneratedColumn<String> get partialPath => $composableBuilder(
    column: $table.partialPath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<int> get bytesDownloaded => $composableBuilder(
    column: $table.bytesDownloaded,
    builder: (column) => column,
  );

  GeneratedColumn<int> get totalBytes => $composableBuilder(
    column: $table.totalBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get etag =>
      $composableBuilder(column: $table.etag, builder: (column) => column);

  GeneratedColumn<String> get lastModified => $composableBuilder(
    column: $table.lastModified,
    builder: (column) => column,
  );

  GeneratedColumn<String> get error =>
      $composableBuilder(column: $table.error, builder: (column) => column);

  GeneratedColumn<bool> get automatic =>
      $composableBuilder(column: $table.automatic, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

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

class $$DownloadJobRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadJobRowsTable,
          DownloadJobRecord,
          $$DownloadJobRowsTableFilterComposer,
          $$DownloadJobRowsTableOrderingComposer,
          $$DownloadJobRowsTableAnnotationComposer,
          $$DownloadJobRowsTableCreateCompanionBuilder,
          $$DownloadJobRowsTableUpdateCompanionBuilder,
          (DownloadJobRecord, $$DownloadJobRowsTableReferences),
          DownloadJobRecord,
          PrefetchHooks Function({bool episodeId})
        > {
  $$DownloadJobRowsTableTableManager(
    _$AppDatabase db,
    $DownloadJobRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadJobRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DownloadJobRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DownloadJobRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                Value<String> sourceUrl = const Value.absent(),
                Value<String> filePath = const Value.absent(),
                Value<String> partialPath = const Value.absent(),
                Value<String> state = const Value.absent(),
                Value<int> bytesDownloaded = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<bool> automatic = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime?> playedAt = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => DownloadJobRowsCompanion(
                episodeId: episodeId,
                sourceUrl: sourceUrl,
                filePath: filePath,
                partialPath: partialPath,
                state: state,
                bytesDownloaded: bytesDownloaded,
                totalBytes: totalBytes,
                etag: etag,
                lastModified: lastModified,
                error: error,
                automatic: automatic,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                playedAt: playedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                required String sourceUrl,
                required String filePath,
                required String partialPath,
                required String state,
                Value<int> bytesDownloaded = const Value.absent(),
                Value<int?> totalBytes = const Value.absent(),
                Value<String?> etag = const Value.absent(),
                Value<String?> lastModified = const Value.absent(),
                Value<String?> error = const Value.absent(),
                Value<bool> automatic = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime?> playedAt = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
              }) => DownloadJobRowsCompanion.insert(
                episodeId: episodeId,
                sourceUrl: sourceUrl,
                filePath: filePath,
                partialPath: partialPath,
                state: state,
                bytesDownloaded: bytesDownloaded,
                totalBytes: totalBytes,
                etag: etag,
                lastModified: lastModified,
                error: error,
                automatic: automatic,
                attempts: attempts,
                nextAttemptAt: nextAttemptAt,
                playedAt: playedAt,
                createdAt: createdAt,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DownloadJobRowsTableReferences(db, table, e),
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
                                referencedTable:
                                    $$DownloadJobRowsTableReferences
                                        ._episodeIdTable(db),
                                referencedColumn:
                                    $$DownloadJobRowsTableReferences
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

typedef $$DownloadJobRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadJobRowsTable,
      DownloadJobRecord,
      $$DownloadJobRowsTableFilterComposer,
      $$DownloadJobRowsTableOrderingComposer,
      $$DownloadJobRowsTableAnnotationComposer,
      $$DownloadJobRowsTableCreateCompanionBuilder,
      $$DownloadJobRowsTableUpdateCompanionBuilder,
      (DownloadJobRecord, $$DownloadJobRowsTableReferences),
      DownloadJobRecord,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$DownloadPreferenceRowsTableCreateCompanionBuilder =
    DownloadPreferenceRowsCompanion Function({
      Value<int> id,
      Value<bool> automatic,
      Value<int> episodeLimit,
      Value<bool> wifiOnly,
      Value<bool> chargingOnly,
      Value<int> storageFloorBytes,
      Value<String> retention,
      Value<int> retentionDelayHours,
    });
typedef $$DownloadPreferenceRowsTableUpdateCompanionBuilder =
    DownloadPreferenceRowsCompanion Function({
      Value<int> id,
      Value<bool> automatic,
      Value<int> episodeLimit,
      Value<bool> wifiOnly,
      Value<bool> chargingOnly,
      Value<int> storageFloorBytes,
      Value<String> retention,
      Value<int> retentionDelayHours,
    });

class $$DownloadPreferenceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $DownloadPreferenceRowsTable> {
  $$DownloadPreferenceRowsTableFilterComposer({
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

  ColumnFilters<bool> get automatic => $composableBuilder(
    column: $table.automatic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeLimit => $composableBuilder(
    column: $table.episodeLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get chargingOnly => $composableBuilder(
    column: $table.chargingOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get storageFloorBytes => $composableBuilder(
    column: $table.storageFloorBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retention => $composableBuilder(
    column: $table.retention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retentionDelayHours => $composableBuilder(
    column: $table.retentionDelayHours,
    builder: (column) => ColumnFilters(column),
  );
}

class $$DownloadPreferenceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $DownloadPreferenceRowsTable> {
  $$DownloadPreferenceRowsTableOrderingComposer({
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

  ColumnOrderings<bool> get automatic => $composableBuilder(
    column: $table.automatic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeLimit => $composableBuilder(
    column: $table.episodeLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get chargingOnly => $composableBuilder(
    column: $table.chargingOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storageFloorBytes => $composableBuilder(
    column: $table.storageFloorBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retention => $composableBuilder(
    column: $table.retention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retentionDelayHours => $composableBuilder(
    column: $table.retentionDelayHours,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$DownloadPreferenceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DownloadPreferenceRowsTable> {
  $$DownloadPreferenceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<bool> get automatic =>
      $composableBuilder(column: $table.automatic, builder: (column) => column);

  GeneratedColumn<int> get episodeLimit => $composableBuilder(
    column: $table.episodeLimit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wifiOnly =>
      $composableBuilder(column: $table.wifiOnly, builder: (column) => column);

  GeneratedColumn<bool> get chargingOnly => $composableBuilder(
    column: $table.chargingOnly,
    builder: (column) => column,
  );

  GeneratedColumn<int> get storageFloorBytes => $composableBuilder(
    column: $table.storageFloorBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retention =>
      $composableBuilder(column: $table.retention, builder: (column) => column);

  GeneratedColumn<int> get retentionDelayHours => $composableBuilder(
    column: $table.retentionDelayHours,
    builder: (column) => column,
  );
}

class $$DownloadPreferenceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DownloadPreferenceRowsTable,
          DownloadPreferenceRecord,
          $$DownloadPreferenceRowsTableFilterComposer,
          $$DownloadPreferenceRowsTableOrderingComposer,
          $$DownloadPreferenceRowsTableAnnotationComposer,
          $$DownloadPreferenceRowsTableCreateCompanionBuilder,
          $$DownloadPreferenceRowsTableUpdateCompanionBuilder,
          (
            DownloadPreferenceRecord,
            BaseReferences<
              _$AppDatabase,
              $DownloadPreferenceRowsTable,
              DownloadPreferenceRecord
            >,
          ),
          DownloadPreferenceRecord,
          PrefetchHooks Function()
        > {
  $$DownloadPreferenceRowsTableTableManager(
    _$AppDatabase db,
    $DownloadPreferenceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DownloadPreferenceRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$DownloadPreferenceRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$DownloadPreferenceRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> automatic = const Value.absent(),
                Value<int> episodeLimit = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<bool> chargingOnly = const Value.absent(),
                Value<int> storageFloorBytes = const Value.absent(),
                Value<String> retention = const Value.absent(),
                Value<int> retentionDelayHours = const Value.absent(),
              }) => DownloadPreferenceRowsCompanion(
                id: id,
                automatic: automatic,
                episodeLimit: episodeLimit,
                wifiOnly: wifiOnly,
                chargingOnly: chargingOnly,
                storageFloorBytes: storageFloorBytes,
                retention: retention,
                retentionDelayHours: retentionDelayHours,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<bool> automatic = const Value.absent(),
                Value<int> episodeLimit = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<bool> chargingOnly = const Value.absent(),
                Value<int> storageFloorBytes = const Value.absent(),
                Value<String> retention = const Value.absent(),
                Value<int> retentionDelayHours = const Value.absent(),
              }) => DownloadPreferenceRowsCompanion.insert(
                id: id,
                automatic: automatic,
                episodeLimit: episodeLimit,
                wifiOnly: wifiOnly,
                chargingOnly: chargingOnly,
                storageFloorBytes: storageFloorBytes,
                retention: retention,
                retentionDelayHours: retentionDelayHours,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$DownloadPreferenceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DownloadPreferenceRowsTable,
      DownloadPreferenceRecord,
      $$DownloadPreferenceRowsTableFilterComposer,
      $$DownloadPreferenceRowsTableOrderingComposer,
      $$DownloadPreferenceRowsTableAnnotationComposer,
      $$DownloadPreferenceRowsTableCreateCompanionBuilder,
      $$DownloadPreferenceRowsTableUpdateCompanionBuilder,
      (
        DownloadPreferenceRecord,
        BaseReferences<
          _$AppDatabase,
          $DownloadPreferenceRowsTable,
          DownloadPreferenceRecord
        >,
      ),
      DownloadPreferenceRecord,
      PrefetchHooks Function()
    >;
typedef $$PodcastDownloadOverrideRowsTableCreateCompanionBuilder =
    PodcastDownloadOverrideRowsCompanion Function({
      Value<int> podcastId,
      required bool automatic,
      required int episodeLimit,
      required bool wifiOnly,
      required bool chargingOnly,
      required int storageFloorBytes,
      required String retention,
      required int retentionDelayHours,
    });
typedef $$PodcastDownloadOverrideRowsTableUpdateCompanionBuilder =
    PodcastDownloadOverrideRowsCompanion Function({
      Value<int> podcastId,
      Value<bool> automatic,
      Value<int> episodeLimit,
      Value<bool> wifiOnly,
      Value<bool> chargingOnly,
      Value<int> storageFloorBytes,
      Value<String> retention,
      Value<int> retentionDelayHours,
    });

final class $$PodcastDownloadOverrideRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PodcastDownloadOverrideRowsTable,
          PodcastDownloadOverrideRecord
        > {
  $$PodcastDownloadOverrideRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PodcastRowsTable _podcastIdTable(_$AppDatabase db) =>
      db.podcastRows.createAlias(
        'podcast_download_override_rows__podcast_id__podcast_rows__id',
      );

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
}

class $$PodcastDownloadOverrideRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PodcastDownloadOverrideRowsTable> {
  $$PodcastDownloadOverrideRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get automatic => $composableBuilder(
    column: $table.automatic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get episodeLimit => $composableBuilder(
    column: $table.episodeLimit,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get chargingOnly => $composableBuilder(
    column: $table.chargingOnly,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get storageFloorBytes => $composableBuilder(
    column: $table.storageFloorBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get retention => $composableBuilder(
    column: $table.retention,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get retentionDelayHours => $composableBuilder(
    column: $table.retentionDelayHours,
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
}

class $$PodcastDownloadOverrideRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PodcastDownloadOverrideRowsTable> {
  $$PodcastDownloadOverrideRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get automatic => $composableBuilder(
    column: $table.automatic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get episodeLimit => $composableBuilder(
    column: $table.episodeLimit,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get wifiOnly => $composableBuilder(
    column: $table.wifiOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get chargingOnly => $composableBuilder(
    column: $table.chargingOnly,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get storageFloorBytes => $composableBuilder(
    column: $table.storageFloorBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get retention => $composableBuilder(
    column: $table.retention,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get retentionDelayHours => $composableBuilder(
    column: $table.retentionDelayHours,
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

class $$PodcastDownloadOverrideRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PodcastDownloadOverrideRowsTable> {
  $$PodcastDownloadOverrideRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get automatic =>
      $composableBuilder(column: $table.automatic, builder: (column) => column);

  GeneratedColumn<int> get episodeLimit => $composableBuilder(
    column: $table.episodeLimit,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get wifiOnly =>
      $composableBuilder(column: $table.wifiOnly, builder: (column) => column);

  GeneratedColumn<bool> get chargingOnly => $composableBuilder(
    column: $table.chargingOnly,
    builder: (column) => column,
  );

  GeneratedColumn<int> get storageFloorBytes => $composableBuilder(
    column: $table.storageFloorBytes,
    builder: (column) => column,
  );

  GeneratedColumn<String> get retention =>
      $composableBuilder(column: $table.retention, builder: (column) => column);

  GeneratedColumn<int> get retentionDelayHours => $composableBuilder(
    column: $table.retentionDelayHours,
    builder: (column) => column,
  );

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
}

class $$PodcastDownloadOverrideRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PodcastDownloadOverrideRowsTable,
          PodcastDownloadOverrideRecord,
          $$PodcastDownloadOverrideRowsTableFilterComposer,
          $$PodcastDownloadOverrideRowsTableOrderingComposer,
          $$PodcastDownloadOverrideRowsTableAnnotationComposer,
          $$PodcastDownloadOverrideRowsTableCreateCompanionBuilder,
          $$PodcastDownloadOverrideRowsTableUpdateCompanionBuilder,
          (
            PodcastDownloadOverrideRecord,
            $$PodcastDownloadOverrideRowsTableReferences,
          ),
          PodcastDownloadOverrideRecord,
          PrefetchHooks Function({bool podcastId})
        > {
  $$PodcastDownloadOverrideRowsTableTableManager(
    _$AppDatabase db,
    $PodcastDownloadOverrideRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastDownloadOverrideRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PodcastDownloadOverrideRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PodcastDownloadOverrideRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> podcastId = const Value.absent(),
                Value<bool> automatic = const Value.absent(),
                Value<int> episodeLimit = const Value.absent(),
                Value<bool> wifiOnly = const Value.absent(),
                Value<bool> chargingOnly = const Value.absent(),
                Value<int> storageFloorBytes = const Value.absent(),
                Value<String> retention = const Value.absent(),
                Value<int> retentionDelayHours = const Value.absent(),
              }) => PodcastDownloadOverrideRowsCompanion(
                podcastId: podcastId,
                automatic: automatic,
                episodeLimit: episodeLimit,
                wifiOnly: wifiOnly,
                chargingOnly: chargingOnly,
                storageFloorBytes: storageFloorBytes,
                retention: retention,
                retentionDelayHours: retentionDelayHours,
              ),
          createCompanionCallback:
              ({
                Value<int> podcastId = const Value.absent(),
                required bool automatic,
                required int episodeLimit,
                required bool wifiOnly,
                required bool chargingOnly,
                required int storageFloorBytes,
                required String retention,
                required int retentionDelayHours,
              }) => PodcastDownloadOverrideRowsCompanion.insert(
                podcastId: podcastId,
                automatic: automatic,
                episodeLimit: episodeLimit,
                wifiOnly: wifiOnly,
                chargingOnly: chargingOnly,
                storageFloorBytes: storageFloorBytes,
                retention: retention,
                retentionDelayHours: retentionDelayHours,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PodcastDownloadOverrideRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({podcastId = false}) {
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
                    if (podcastId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.podcastId,
                                referencedTable:
                                    $$PodcastDownloadOverrideRowsTableReferences
                                        ._podcastIdTable(db),
                                referencedColumn:
                                    $$PodcastDownloadOverrideRowsTableReferences
                                        ._podcastIdTable(db)
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

typedef $$PodcastDownloadOverrideRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PodcastDownloadOverrideRowsTable,
      PodcastDownloadOverrideRecord,
      $$PodcastDownloadOverrideRowsTableFilterComposer,
      $$PodcastDownloadOverrideRowsTableOrderingComposer,
      $$PodcastDownloadOverrideRowsTableAnnotationComposer,
      $$PodcastDownloadOverrideRowsTableCreateCompanionBuilder,
      $$PodcastDownloadOverrideRowsTableUpdateCompanionBuilder,
      (
        PodcastDownloadOverrideRecord,
        $$PodcastDownloadOverrideRowsTableReferences,
      ),
      PodcastDownloadOverrideRecord,
      PrefetchHooks Function({bool podcastId})
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
typedef $$InboxRowsTableCreateCompanionBuilder =
    InboxRowsCompanion Function({
      Value<int> episodeId,
      required DateTime discoveredAt,
      Value<DateTime?> removedAt,
    });
typedef $$InboxRowsTableUpdateCompanionBuilder =
    InboxRowsCompanion Function({
      Value<int> episodeId,
      Value<DateTime> discoveredAt,
      Value<DateTime?> removedAt,
    });

final class $$InboxRowsTableReferences
    extends BaseReferences<_$AppDatabase, $InboxRowsTable, InboxRecord> {
  $$InboxRowsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $EpisodeRowsTable _episodeIdTable(_$AppDatabase db) =>
      db.episodeRows.createAlias('inbox_rows__episode_id__episode_rows__id');

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

class $$InboxRowsTableFilterComposer
    extends Composer<_$AppDatabase, $InboxRowsTable> {
  $$InboxRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
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

class $$InboxRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $InboxRowsTable> {
  $$InboxRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get removedAt => $composableBuilder(
    column: $table.removedAt,
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

class $$InboxRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InboxRowsTable> {
  $$InboxRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<DateTime> get discoveredAt => $composableBuilder(
    column: $table.discoveredAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get removedAt =>
      $composableBuilder(column: $table.removedAt, builder: (column) => column);

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

class $$InboxRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InboxRowsTable,
          InboxRecord,
          $$InboxRowsTableFilterComposer,
          $$InboxRowsTableOrderingComposer,
          $$InboxRowsTableAnnotationComposer,
          $$InboxRowsTableCreateCompanionBuilder,
          $$InboxRowsTableUpdateCompanionBuilder,
          (InboxRecord, $$InboxRowsTableReferences),
          InboxRecord,
          PrefetchHooks Function({bool episodeId})
        > {
  $$InboxRowsTableTableManager(_$AppDatabase db, $InboxRowsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InboxRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InboxRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$InboxRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                Value<DateTime> discoveredAt = const Value.absent(),
                Value<DateTime?> removedAt = const Value.absent(),
              }) => InboxRowsCompanion(
                episodeId: episodeId,
                discoveredAt: discoveredAt,
                removedAt: removedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> episodeId = const Value.absent(),
                required DateTime discoveredAt,
                Value<DateTime?> removedAt = const Value.absent(),
              }) => InboxRowsCompanion.insert(
                episodeId: episodeId,
                discoveredAt: discoveredAt,
                removedAt: removedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$InboxRowsTableReferences(db, table, e),
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
                                referencedTable: $$InboxRowsTableReferences
                                    ._episodeIdTable(db),
                                referencedColumn: $$InboxRowsTableReferences
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

typedef $$InboxRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InboxRowsTable,
      InboxRecord,
      $$InboxRowsTableFilterComposer,
      $$InboxRowsTableOrderingComposer,
      $$InboxRowsTableAnnotationComposer,
      $$InboxRowsTableCreateCompanionBuilder,
      $$InboxRowsTableUpdateCompanionBuilder,
      (InboxRecord, $$InboxRowsTableReferences),
      InboxRecord,
      PrefetchHooks Function({bool episodeId})
    >;
typedef $$InboxPreferenceRowsTableCreateCompanionBuilder =
    InboxPreferenceRowsCompanion Function({
      Value<int> id,
      Value<String> leftAction,
      Value<String> rightAction,
      Value<bool> markRemovedAsPlayed,
    });
typedef $$InboxPreferenceRowsTableUpdateCompanionBuilder =
    InboxPreferenceRowsCompanion Function({
      Value<int> id,
      Value<String> leftAction,
      Value<String> rightAction,
      Value<bool> markRemovedAsPlayed,
    });

class $$InboxPreferenceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $InboxPreferenceRowsTable> {
  $$InboxPreferenceRowsTableFilterComposer({
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

  ColumnFilters<String> get leftAction => $composableBuilder(
    column: $table.leftAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rightAction => $composableBuilder(
    column: $table.rightAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get markRemovedAsPlayed => $composableBuilder(
    column: $table.markRemovedAsPlayed,
    builder: (column) => ColumnFilters(column),
  );
}

class $$InboxPreferenceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $InboxPreferenceRowsTable> {
  $$InboxPreferenceRowsTableOrderingComposer({
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

  ColumnOrderings<String> get leftAction => $composableBuilder(
    column: $table.leftAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rightAction => $composableBuilder(
    column: $table.rightAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get markRemovedAsPlayed => $composableBuilder(
    column: $table.markRemovedAsPlayed,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$InboxPreferenceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $InboxPreferenceRowsTable> {
  $$InboxPreferenceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get leftAction => $composableBuilder(
    column: $table.leftAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rightAction => $composableBuilder(
    column: $table.rightAction,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get markRemovedAsPlayed => $composableBuilder(
    column: $table.markRemovedAsPlayed,
    builder: (column) => column,
  );
}

class $$InboxPreferenceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $InboxPreferenceRowsTable,
          InboxPreferencesRecord,
          $$InboxPreferenceRowsTableFilterComposer,
          $$InboxPreferenceRowsTableOrderingComposer,
          $$InboxPreferenceRowsTableAnnotationComposer,
          $$InboxPreferenceRowsTableCreateCompanionBuilder,
          $$InboxPreferenceRowsTableUpdateCompanionBuilder,
          (
            InboxPreferencesRecord,
            BaseReferences<
              _$AppDatabase,
              $InboxPreferenceRowsTable,
              InboxPreferencesRecord
            >,
          ),
          InboxPreferencesRecord,
          PrefetchHooks Function()
        > {
  $$InboxPreferenceRowsTableTableManager(
    _$AppDatabase db,
    $InboxPreferenceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$InboxPreferenceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$InboxPreferenceRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$InboxPreferenceRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> leftAction = const Value.absent(),
                Value<String> rightAction = const Value.absent(),
                Value<bool> markRemovedAsPlayed = const Value.absent(),
              }) => InboxPreferenceRowsCompanion(
                id: id,
                leftAction: leftAction,
                rightAction: rightAction,
                markRemovedAsPlayed: markRemovedAsPlayed,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> leftAction = const Value.absent(),
                Value<String> rightAction = const Value.absent(),
                Value<bool> markRemovedAsPlayed = const Value.absent(),
              }) => InboxPreferenceRowsCompanion.insert(
                id: id,
                leftAction: leftAction,
                rightAction: rightAction,
                markRemovedAsPlayed: markRemovedAsPlayed,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$InboxPreferenceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $InboxPreferenceRowsTable,
      InboxPreferencesRecord,
      $$InboxPreferenceRowsTableFilterComposer,
      $$InboxPreferenceRowsTableOrderingComposer,
      $$InboxPreferenceRowsTableAnnotationComposer,
      $$InboxPreferenceRowsTableCreateCompanionBuilder,
      $$InboxPreferenceRowsTableUpdateCompanionBuilder,
      (
        InboxPreferencesRecord,
        BaseReferences<
          _$AppDatabase,
          $InboxPreferenceRowsTable,
          InboxPreferencesRecord
        >,
      ),
      InboxPreferencesRecord,
      PrefetchHooks Function()
    >;
typedef $$PodcastInboxOverrideRowsTableCreateCompanionBuilder =
    PodcastInboxOverrideRowsCompanion Function({
      Value<int> podcastId,
      Value<String?> leftAction,
      Value<String?> rightAction,
    });
typedef $$PodcastInboxOverrideRowsTableUpdateCompanionBuilder =
    PodcastInboxOverrideRowsCompanion Function({
      Value<int> podcastId,
      Value<String?> leftAction,
      Value<String?> rightAction,
    });

final class $$PodcastInboxOverrideRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PodcastInboxOverrideRowsTable,
          PodcastInboxOverrideRecord
        > {
  $$PodcastInboxOverrideRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PodcastRowsTable _podcastIdTable(_$AppDatabase db) => db.podcastRows
      .createAlias('podcast_inbox_override_rows__podcast_id__podcast_rows__id');

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
}

class $$PodcastInboxOverrideRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PodcastInboxOverrideRowsTable> {
  $$PodcastInboxOverrideRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get leftAction => $composableBuilder(
    column: $table.leftAction,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rightAction => $composableBuilder(
    column: $table.rightAction,
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
}

class $$PodcastInboxOverrideRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PodcastInboxOverrideRowsTable> {
  $$PodcastInboxOverrideRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get leftAction => $composableBuilder(
    column: $table.leftAction,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rightAction => $composableBuilder(
    column: $table.rightAction,
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

class $$PodcastInboxOverrideRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PodcastInboxOverrideRowsTable> {
  $$PodcastInboxOverrideRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get leftAction => $composableBuilder(
    column: $table.leftAction,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rightAction => $composableBuilder(
    column: $table.rightAction,
    builder: (column) => column,
  );

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
}

class $$PodcastInboxOverrideRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PodcastInboxOverrideRowsTable,
          PodcastInboxOverrideRecord,
          $$PodcastInboxOverrideRowsTableFilterComposer,
          $$PodcastInboxOverrideRowsTableOrderingComposer,
          $$PodcastInboxOverrideRowsTableAnnotationComposer,
          $$PodcastInboxOverrideRowsTableCreateCompanionBuilder,
          $$PodcastInboxOverrideRowsTableUpdateCompanionBuilder,
          (
            PodcastInboxOverrideRecord,
            $$PodcastInboxOverrideRowsTableReferences,
          ),
          PodcastInboxOverrideRecord,
          PrefetchHooks Function({bool podcastId})
        > {
  $$PodcastInboxOverrideRowsTableTableManager(
    _$AppDatabase db,
    $PodcastInboxOverrideRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastInboxOverrideRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PodcastInboxOverrideRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PodcastInboxOverrideRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> podcastId = const Value.absent(),
                Value<String?> leftAction = const Value.absent(),
                Value<String?> rightAction = const Value.absent(),
              }) => PodcastInboxOverrideRowsCompanion(
                podcastId: podcastId,
                leftAction: leftAction,
                rightAction: rightAction,
              ),
          createCompanionCallback:
              ({
                Value<int> podcastId = const Value.absent(),
                Value<String?> leftAction = const Value.absent(),
                Value<String?> rightAction = const Value.absent(),
              }) => PodcastInboxOverrideRowsCompanion.insert(
                podcastId: podcastId,
                leftAction: leftAction,
                rightAction: rightAction,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PodcastInboxOverrideRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({podcastId = false}) {
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
                    if (podcastId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.podcastId,
                                referencedTable:
                                    $$PodcastInboxOverrideRowsTableReferences
                                        ._podcastIdTable(db),
                                referencedColumn:
                                    $$PodcastInboxOverrideRowsTableReferences
                                        ._podcastIdTable(db)
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

typedef $$PodcastInboxOverrideRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PodcastInboxOverrideRowsTable,
      PodcastInboxOverrideRecord,
      $$PodcastInboxOverrideRowsTableFilterComposer,
      $$PodcastInboxOverrideRowsTableOrderingComposer,
      $$PodcastInboxOverrideRowsTableAnnotationComposer,
      $$PodcastInboxOverrideRowsTableCreateCompanionBuilder,
      $$PodcastInboxOverrideRowsTableUpdateCompanionBuilder,
      (PodcastInboxOverrideRecord, $$PodcastInboxOverrideRowsTableReferences),
      PodcastInboxOverrideRecord,
      PrefetchHooks Function({bool podcastId})
    >;
typedef $$SyncMutationsTableCreateCompanionBuilder =
    SyncMutationsCompanion Function({
      required String id,
      required String type,
      Value<int?> episodeId,
      Value<String> payload,
      required DateTime createdAt,
      Value<int> attempts,
      Value<String> state,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
      Value<DateTime?> failedAt,
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
      Value<String> state,
      Value<DateTime?> nextAttemptAt,
      Value<DateTime?> lastAttemptAt,
      Value<String?> lastError,
      Value<DateTime?> failedAt,
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

  ColumnFilters<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get failedAt => $composableBuilder(
    column: $table.failedAt,
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

  ColumnOrderings<String> get state => $composableBuilder(
    column: $table.state,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get failedAt => $composableBuilder(
    column: $table.failedAt,
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

  GeneratedColumn<String> get state =>
      $composableBuilder(column: $table.state, builder: (column) => column);

  GeneratedColumn<DateTime> get nextAttemptAt => $composableBuilder(
    column: $table.nextAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get lastAttemptAt => $composableBuilder(
    column: $table.lastAttemptAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);

  GeneratedColumn<DateTime> get failedAt =>
      $composableBuilder(column: $table.failedAt, builder: (column) => column);
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
                Value<String> state = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> failedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMutationsCompanion(
                id: id,
                type: type,
                episodeId: episodeId,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                state: state,
                nextAttemptAt: nextAttemptAt,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                failedAt: failedAt,
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
                Value<String> state = const Value.absent(),
                Value<DateTime?> nextAttemptAt = const Value.absent(),
                Value<DateTime?> lastAttemptAt = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<DateTime?> failedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncMutationsCompanion.insert(
                id: id,
                type: type,
                episodeId: episodeId,
                payload: payload,
                createdAt: createdAt,
                attempts: attempts,
                state: state,
                nextAttemptAt: nextAttemptAt,
                lastAttemptAt: lastAttemptAt,
                lastError: lastError,
                failedAt: failedAt,
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
typedef $$QueueSyncStateRowsTableCreateCompanionBuilder =
    QueueSyncStateRowsCompanion Function({
      Value<int> id,
      required String revision,
      Value<String> orderJson,
      required DateTime updatedAt,
    });
typedef $$QueueSyncStateRowsTableUpdateCompanionBuilder =
    QueueSyncStateRowsCompanion Function({
      Value<int> id,
      Value<String> revision,
      Value<String> orderJson,
      Value<DateTime> updatedAt,
    });

class $$QueueSyncStateRowsTableFilterComposer
    extends Composer<_$AppDatabase, $QueueSyncStateRowsTable> {
  $$QueueSyncStateRowsTableFilterComposer({
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

  ColumnFilters<String> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get orderJson => $composableBuilder(
    column: $table.orderJson,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QueueSyncStateRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $QueueSyncStateRowsTable> {
  $$QueueSyncStateRowsTableOrderingComposer({
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

  ColumnOrderings<String> get revision => $composableBuilder(
    column: $table.revision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get orderJson => $composableBuilder(
    column: $table.orderJson,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QueueSyncStateRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $QueueSyncStateRowsTable> {
  $$QueueSyncStateRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get revision =>
      $composableBuilder(column: $table.revision, builder: (column) => column);

  GeneratedColumn<String> get orderJson =>
      $composableBuilder(column: $table.orderJson, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$QueueSyncStateRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $QueueSyncStateRowsTable,
          QueueSyncStateRecord,
          $$QueueSyncStateRowsTableFilterComposer,
          $$QueueSyncStateRowsTableOrderingComposer,
          $$QueueSyncStateRowsTableAnnotationComposer,
          $$QueueSyncStateRowsTableCreateCompanionBuilder,
          $$QueueSyncStateRowsTableUpdateCompanionBuilder,
          (
            QueueSyncStateRecord,
            BaseReferences<
              _$AppDatabase,
              $QueueSyncStateRowsTable,
              QueueSyncStateRecord
            >,
          ),
          QueueSyncStateRecord,
          PrefetchHooks Function()
        > {
  $$QueueSyncStateRowsTableTableManager(
    _$AppDatabase db,
    $QueueSyncStateRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QueueSyncStateRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QueueSyncStateRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QueueSyncStateRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> revision = const Value.absent(),
                Value<String> orderJson = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
              }) => QueueSyncStateRowsCompanion(
                id: id,
                revision: revision,
                orderJson: orderJson,
                updatedAt: updatedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String revision,
                Value<String> orderJson = const Value.absent(),
                required DateTime updatedAt,
              }) => QueueSyncStateRowsCompanion.insert(
                id: id,
                revision: revision,
                orderJson: orderJson,
                updatedAt: updatedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QueueSyncStateRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $QueueSyncStateRowsTable,
      QueueSyncStateRecord,
      $$QueueSyncStateRowsTableFilterComposer,
      $$QueueSyncStateRowsTableOrderingComposer,
      $$QueueSyncStateRowsTableAnnotationComposer,
      $$QueueSyncStateRowsTableCreateCompanionBuilder,
      $$QueueSyncStateRowsTableUpdateCompanionBuilder,
      (
        QueueSyncStateRecord,
        BaseReferences<
          _$AppDatabase,
          $QueueSyncStateRowsTable,
          QueueSyncStateRecord
        >,
      ),
      QueueSyncStateRecord,
      PrefetchHooks Function()
    >;
typedef $$SyncDeviceRowsTableCreateCompanionBuilder =
    SyncDeviceRowsCompanion Function({
      Value<int> id,
      required String deviceId,
      required DateTime createdAt,
    });
typedef $$SyncDeviceRowsTableUpdateCompanionBuilder =
    SyncDeviceRowsCompanion Function({
      Value<int> id,
      Value<String> deviceId,
      Value<DateTime> createdAt,
    });

class $$SyncDeviceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $SyncDeviceRowsTable> {
  $$SyncDeviceRowsTableFilterComposer({
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

  ColumnFilters<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncDeviceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $SyncDeviceRowsTable> {
  $$SyncDeviceRowsTableOrderingComposer({
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

  ColumnOrderings<String> get deviceId => $composableBuilder(
    column: $table.deviceId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncDeviceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SyncDeviceRowsTable> {
  $$SyncDeviceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get deviceId =>
      $composableBuilder(column: $table.deviceId, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$SyncDeviceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $SyncDeviceRowsTable,
          SyncDeviceRecord,
          $$SyncDeviceRowsTableFilterComposer,
          $$SyncDeviceRowsTableOrderingComposer,
          $$SyncDeviceRowsTableAnnotationComposer,
          $$SyncDeviceRowsTableCreateCompanionBuilder,
          $$SyncDeviceRowsTableUpdateCompanionBuilder,
          (
            SyncDeviceRecord,
            BaseReferences<
              _$AppDatabase,
              $SyncDeviceRowsTable,
              SyncDeviceRecord
            >,
          ),
          SyncDeviceRecord,
          PrefetchHooks Function()
        > {
  $$SyncDeviceRowsTableTableManager(
    _$AppDatabase db,
    $SyncDeviceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncDeviceRowsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncDeviceRowsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncDeviceRowsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> deviceId = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => SyncDeviceRowsCompanion(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String deviceId,
                required DateTime createdAt,
              }) => SyncDeviceRowsCompanion.insert(
                id: id,
                deviceId: deviceId,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncDeviceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $SyncDeviceRowsTable,
      SyncDeviceRecord,
      $$SyncDeviceRowsTableFilterComposer,
      $$SyncDeviceRowsTableOrderingComposer,
      $$SyncDeviceRowsTableAnnotationComposer,
      $$SyncDeviceRowsTableCreateCompanionBuilder,
      $$SyncDeviceRowsTableUpdateCompanionBuilder,
      (
        SyncDeviceRecord,
        BaseReferences<_$AppDatabase, $SyncDeviceRowsTable, SyncDeviceRecord>,
      ),
      SyncDeviceRecord,
      PrefetchHooks Function()
    >;
typedef $$PlaybackPreferenceRowsTableCreateCompanionBuilder =
    PlaybackPreferenceRowsCompanion Function({
      Value<int> id,
      Value<double> speed,
      Value<String> skipSilence,
    });
typedef $$PlaybackPreferenceRowsTableUpdateCompanionBuilder =
    PlaybackPreferenceRowsCompanion Function({
      Value<int> id,
      Value<double> speed,
      Value<String> skipSilence,
    });

class $$PlaybackPreferenceRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PlaybackPreferenceRowsTable> {
  $$PlaybackPreferenceRowsTableFilterComposer({
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

  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skipSilence => $composableBuilder(
    column: $table.skipSilence,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlaybackPreferenceRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlaybackPreferenceRowsTable> {
  $$PlaybackPreferenceRowsTableOrderingComposer({
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

  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skipSilence => $composableBuilder(
    column: $table.skipSilence,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlaybackPreferenceRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlaybackPreferenceRowsTable> {
  $$PlaybackPreferenceRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<String> get skipSilence => $composableBuilder(
    column: $table.skipSilence,
    builder: (column) => column,
  );
}

class $$PlaybackPreferenceRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlaybackPreferenceRowsTable,
          PlaybackPreferencesRecord,
          $$PlaybackPreferenceRowsTableFilterComposer,
          $$PlaybackPreferenceRowsTableOrderingComposer,
          $$PlaybackPreferenceRowsTableAnnotationComposer,
          $$PlaybackPreferenceRowsTableCreateCompanionBuilder,
          $$PlaybackPreferenceRowsTableUpdateCompanionBuilder,
          (
            PlaybackPreferencesRecord,
            BaseReferences<
              _$AppDatabase,
              $PlaybackPreferenceRowsTable,
              PlaybackPreferencesRecord
            >,
          ),
          PlaybackPreferencesRecord,
          PrefetchHooks Function()
        > {
  $$PlaybackPreferenceRowsTableTableManager(
    _$AppDatabase db,
    $PlaybackPreferenceRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlaybackPreferenceRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PlaybackPreferenceRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlaybackPreferenceRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<String> skipSilence = const Value.absent(),
              }) => PlaybackPreferenceRowsCompanion(
                id: id,
                speed: speed,
                skipSilence: skipSilence,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<double> speed = const Value.absent(),
                Value<String> skipSilence = const Value.absent(),
              }) => PlaybackPreferenceRowsCompanion.insert(
                id: id,
                speed: speed,
                skipSilence: skipSilence,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlaybackPreferenceRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlaybackPreferenceRowsTable,
      PlaybackPreferencesRecord,
      $$PlaybackPreferenceRowsTableFilterComposer,
      $$PlaybackPreferenceRowsTableOrderingComposer,
      $$PlaybackPreferenceRowsTableAnnotationComposer,
      $$PlaybackPreferenceRowsTableCreateCompanionBuilder,
      $$PlaybackPreferenceRowsTableUpdateCompanionBuilder,
      (
        PlaybackPreferencesRecord,
        BaseReferences<
          _$AppDatabase,
          $PlaybackPreferenceRowsTable,
          PlaybackPreferencesRecord
        >,
      ),
      PlaybackPreferencesRecord,
      PrefetchHooks Function()
    >;
typedef $$PodcastPlaybackOverrideRowsTableCreateCompanionBuilder =
    PodcastPlaybackOverrideRowsCompanion Function({
      Value<int> podcastId,
      Value<double?> speed,
      Value<String?> skipSilence,
    });
typedef $$PodcastPlaybackOverrideRowsTableUpdateCompanionBuilder =
    PodcastPlaybackOverrideRowsCompanion Function({
      Value<int> podcastId,
      Value<double?> speed,
      Value<String?> skipSilence,
    });

final class $$PodcastPlaybackOverrideRowsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PodcastPlaybackOverrideRowsTable,
          PodcastPlaybackOverrideRecord
        > {
  $$PodcastPlaybackOverrideRowsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PodcastRowsTable _podcastIdTable(_$AppDatabase db) =>
      db.podcastRows.createAlias(
        'podcast_playback_override_rows__podcast_id__podcast_rows__id',
      );

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
}

class $$PodcastPlaybackOverrideRowsTableFilterComposer
    extends Composer<_$AppDatabase, $PodcastPlaybackOverrideRowsTable> {
  $$PodcastPlaybackOverrideRowsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get skipSilence => $composableBuilder(
    column: $table.skipSilence,
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
}

class $$PodcastPlaybackOverrideRowsTableOrderingComposer
    extends Composer<_$AppDatabase, $PodcastPlaybackOverrideRowsTable> {
  $$PodcastPlaybackOverrideRowsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<double> get speed => $composableBuilder(
    column: $table.speed,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get skipSilence => $composableBuilder(
    column: $table.skipSilence,
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

class $$PodcastPlaybackOverrideRowsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PodcastPlaybackOverrideRowsTable> {
  $$PodcastPlaybackOverrideRowsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<double> get speed =>
      $composableBuilder(column: $table.speed, builder: (column) => column);

  GeneratedColumn<String> get skipSilence => $composableBuilder(
    column: $table.skipSilence,
    builder: (column) => column,
  );

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
}

class $$PodcastPlaybackOverrideRowsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PodcastPlaybackOverrideRowsTable,
          PodcastPlaybackOverrideRecord,
          $$PodcastPlaybackOverrideRowsTableFilterComposer,
          $$PodcastPlaybackOverrideRowsTableOrderingComposer,
          $$PodcastPlaybackOverrideRowsTableAnnotationComposer,
          $$PodcastPlaybackOverrideRowsTableCreateCompanionBuilder,
          $$PodcastPlaybackOverrideRowsTableUpdateCompanionBuilder,
          (
            PodcastPlaybackOverrideRecord,
            $$PodcastPlaybackOverrideRowsTableReferences,
          ),
          PodcastPlaybackOverrideRecord,
          PrefetchHooks Function({bool podcastId})
        > {
  $$PodcastPlaybackOverrideRowsTableTableManager(
    _$AppDatabase db,
    $PodcastPlaybackOverrideRowsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PodcastPlaybackOverrideRowsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PodcastPlaybackOverrideRowsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PodcastPlaybackOverrideRowsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> podcastId = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<String?> skipSilence = const Value.absent(),
              }) => PodcastPlaybackOverrideRowsCompanion(
                podcastId: podcastId,
                speed: speed,
                skipSilence: skipSilence,
              ),
          createCompanionCallback:
              ({
                Value<int> podcastId = const Value.absent(),
                Value<double?> speed = const Value.absent(),
                Value<String?> skipSilence = const Value.absent(),
              }) => PodcastPlaybackOverrideRowsCompanion.insert(
                podcastId: podcastId,
                speed: speed,
                skipSilence: skipSilence,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$PodcastPlaybackOverrideRowsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({podcastId = false}) {
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
                    if (podcastId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.podcastId,
                                referencedTable:
                                    $$PodcastPlaybackOverrideRowsTableReferences
                                        ._podcastIdTable(db),
                                referencedColumn:
                                    $$PodcastPlaybackOverrideRowsTableReferences
                                        ._podcastIdTable(db)
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

typedef $$PodcastPlaybackOverrideRowsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PodcastPlaybackOverrideRowsTable,
      PodcastPlaybackOverrideRecord,
      $$PodcastPlaybackOverrideRowsTableFilterComposer,
      $$PodcastPlaybackOverrideRowsTableOrderingComposer,
      $$PodcastPlaybackOverrideRowsTableAnnotationComposer,
      $$PodcastPlaybackOverrideRowsTableCreateCompanionBuilder,
      $$PodcastPlaybackOverrideRowsTableUpdateCompanionBuilder,
      (
        PodcastPlaybackOverrideRecord,
        $$PodcastPlaybackOverrideRowsTableReferences,
      ),
      PodcastPlaybackOverrideRecord,
      PrefetchHooks Function({bool podcastId})
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$PodcastRowsTableTableManager get podcastRows =>
      $$PodcastRowsTableTableManager(_db, _db.podcastRows);
  $$DiscoveryCacheRowsTableTableManager get discoveryCacheRows =>
      $$DiscoveryCacheRowsTableTableManager(_db, _db.discoveryCacheRows);
  $$EpisodeRowsTableTableManager get episodeRows =>
      $$EpisodeRowsTableTableManager(_db, _db.episodeRows);
  $$DownloadJobRowsTableTableManager get downloadJobRows =>
      $$DownloadJobRowsTableTableManager(_db, _db.downloadJobRows);
  $$DownloadPreferenceRowsTableTableManager get downloadPreferenceRows =>
      $$DownloadPreferenceRowsTableTableManager(
        _db,
        _db.downloadPreferenceRows,
      );
  $$PodcastDownloadOverrideRowsTableTableManager
  get podcastDownloadOverrideRows =>
      $$PodcastDownloadOverrideRowsTableTableManager(
        _db,
        _db.podcastDownloadOverrideRows,
      );
  $$QueueRowsTableTableManager get queueRows =>
      $$QueueRowsTableTableManager(_db, _db.queueRows);
  $$InboxRowsTableTableManager get inboxRows =>
      $$InboxRowsTableTableManager(_db, _db.inboxRows);
  $$InboxPreferenceRowsTableTableManager get inboxPreferenceRows =>
      $$InboxPreferenceRowsTableTableManager(_db, _db.inboxPreferenceRows);
  $$PodcastInboxOverrideRowsTableTableManager get podcastInboxOverrideRows =>
      $$PodcastInboxOverrideRowsTableTableManager(
        _db,
        _db.podcastInboxOverrideRows,
      );
  $$SyncMutationsTableTableManager get syncMutations =>
      $$SyncMutationsTableTableManager(_db, _db.syncMutations);
  $$QueueSyncStateRowsTableTableManager get queueSyncStateRows =>
      $$QueueSyncStateRowsTableTableManager(_db, _db.queueSyncStateRows);
  $$SyncDeviceRowsTableTableManager get syncDeviceRows =>
      $$SyncDeviceRowsTableTableManager(_db, _db.syncDeviceRows);
  $$PlaybackPreferenceRowsTableTableManager get playbackPreferenceRows =>
      $$PlaybackPreferenceRowsTableTableManager(
        _db,
        _db.playbackPreferenceRows,
      );
  $$PodcastPlaybackOverrideRowsTableTableManager
  get podcastPlaybackOverrideRows =>
      $$PodcastPlaybackOverrideRowsTableTableManager(
        _db,
        _db.podcastPlaybackOverrideRows,
      );
}
