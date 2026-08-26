import 'dart:convert';
import 'dart:io';

import 'package:cross_file/cross_file.dart';

import '../enums/media_enums.dart';
import '../utils/media_utils.dart';

/// Converts an arbitrary application model into a [SuperMediaItem].
typedef SuperMediaValueMapper<T extends Object> =
    SuperMediaItem Function(T value, int index);

/// A non-generic mapper retained for dynamically typed integrations.
typedef SuperMediaItemMapper = SuperMediaValueMapper<Object>;

/// Represents one local selection or one existing remote API media value.
class SuperMediaItem {
  /// Stable local or server identifier used for updates and deletion.
  final String id;

  /// Local filesystem path for newly selected media.
  final String? path;

  /// Remote URL for media that already exists in an API.
  final String? url;

  /// Optional local poster or thumbnail path, commonly used for videos.
  final String? thumbnailPath;

  /// Optional remote poster or thumbnail URL.
  final String? thumbnailUrl;

  /// Display name and extension used for type inference.
  final String name;

  /// Whether this item is an image, video, or generic file.
  final SuperMediaType type;

  /// Known file size in bytes, or null when the API omits it.
  final int? sizeBytes;

  /// Known video duration, or null when it has not been supplied.
  final Duration? duration;

  /// Whether the item is a new local selection or existing remote media.
  final SuperMediaItemOrigin origin;

  /// Current upload or deletion lifecycle state.
  final SuperMediaItemStatus status;

  /// Upload completion from zero to one.
  final double uploadProgress;

  /// Original developer model or any custom metadata attached to the item.
  final Object? data;

  /// Creates a fully specified media item.
  ///
  /// Either [path] or [url] must be supplied and [uploadProgress] must be
  /// between zero and one.
  const SuperMediaItem({
    required this.id,
    this.path,
    this.url,
    this.thumbnailPath,
    this.thumbnailUrl,
    required this.name,
    required this.type,
    this.sizeBytes,
    this.duration,
    required this.origin,
    required this.status,
    this.uploadProgress = 0,
    this.data,
  }) : assert(path != null || url != null),
       assert(uploadProgress >= 0 && uploadProgress <= 1);

  /// Creates a newly selected local item and infers omitted metadata.
  factory SuperMediaItem.local({
    required String id,
    required String path,
    String? name,
    SuperMediaType? type,
    int? sizeBytes,
    Duration? duration,
    String? thumbnailPath,
    String? thumbnailUrl,
    Object? data,
  }) {
    final resolvedName = name ?? mediaNameFromPathOrUrl(path);
    return SuperMediaItem(
      id: id,
      path: path,
      name: resolvedName,
      type: type ?? mediaTypeFromName(resolvedName),
      sizeBytes: sizeBytes,
      duration: duration,
      thumbnailPath: thumbnailPath,
      thumbnailUrl: thumbnailUrl,
      origin: SuperMediaItemOrigin.local,
      status: SuperMediaItemStatus.added,
      data: data,
    );
  }

  /// Creates an existing API item and infers its name and type from [url].
  factory SuperMediaItem.remote({
    required String id,
    required String url,
    String? name,
    SuperMediaType? type,
    int? sizeBytes,
    Duration? duration,
    String? thumbnailPath,
    String? thumbnailUrl,
    Object? data,
  }) {
    final inferredName = mediaNameFromPathOrUrl(url);
    final hasExtension = extensionOf(inferredName).isNotEmpty;
    final resolvedName = name ?? (hasExtension ? inferredName : id);
    return SuperMediaItem(
      id: id,
      url: url,
      name: resolvedName,
      type:
          type ??
          (hasExtension
              ? mediaTypeFromName(resolvedName)
              : SuperMediaType.image),
      sizeBytes: sizeBytes,
      duration: duration,
      thumbnailPath: thumbnailPath,
      thumbnailUrl: thumbnailUrl,
      origin: SuperMediaItemOrigin.remote,
      status: SuperMediaItemStatus.existing,
      data: data,
    );
  }

  /// Converts common dynamic media values into a media item.
  static SuperMediaItem fromObject<T extends Object>(
    T value, {
    int index = 0,
    SuperMediaValueMapper<T>? mapper,
  }) {
    if (value is SuperMediaItem) return value;
    if (value is String) {
      final uri = Uri.tryParse(value);
      if (uri?.scheme == 'file' || _looksLikeLocalPath(value)) {
        final path = uri?.scheme == 'file' ? uri!.toFilePath() : value;
        return SuperMediaItem.local(id: path, path: path);
      }
      return SuperMediaItem.remote(id: value, url: value);
    }
    if (value is Uri) {
      return value.scheme == 'file'
          ? SuperMediaItem.local(id: value.toString(), path: value.toFilePath())
          : SuperMediaItem.remote(id: value.toString(), url: value.toString());
    }
    if (value is File) {
      return SuperMediaItem.local(
        id: value.path,
        path: value.path,
        data: value,
      );
    }
    if (value is XFile) {
      return SuperMediaItem.local(
        id: value.path,
        path: value.path,
        name: value.name.isEmpty ? null : value.name,
        data: value,
      );
    }
    if (value is Map) {
      return _fromMap(value, index: index, originalData: value);
    }
    final jsonMap = _tryJsonMap(value);
    if (jsonMap != null) {
      return _fromMap(jsonMap, index: index, originalData: value);
    }
    if (mapper != null) return mapper(value, index);
    throw ArgumentError.value(
      value,
      'value',
      'Use a SuperMediaItem, URL string, map, or initialItemMapper.',
    );
  }

  static SuperMediaItem _fromMap(
    Map<dynamic, dynamic> value, {
    required int index,
    required Object originalData,
  }) {
    final map = <String, Object?>{};
    for (final entry in value.entries) {
      map[_normalizeKey(entry.key)] = entry.value;
    }

    Object? read(List<String> keys) {
      for (final key in keys) {
        final result = map[key];
        if (result != null) return result;
      }
      return null;
    }

    final imageValue = read(const ['imageurl', 'image']);
    final videoValue = read(const ['videourl', 'video']);
    final fileValue = read(const ['fileurl', 'file']);
    final urlValue =
        read(const [
          'url',
          'mediaurl',
          'downloadurl',
          'src',
          'source',
          'uri',
          'link',
        ]) ??
        imageValue ??
        videoValue ??
        fileValue;
    final pathValue = read(const ['path', 'filepath', 'localpath']);
    final location = urlValue ?? pathValue;
    if (location == null) {
      throw ArgumentError.value(
        originalData,
        'value',
        'Dynamic media must expose a URL or local path.',
      );
    }

    final idValue = read(const ['id', 'mediaid', 'fileid', 'uuid', 'key']);
    final id = (idValue ?? location).toString();
    final name = read(const ['name', 'filename', 'title'])?.toString();
    final explicitType = _typeFromValue(
      read(const ['type', 'mediatype', 'filetype', 'mime', 'mimetype']),
    );
    final inferredType =
        imageValue != null
            ? SuperMediaType.image
            : videoValue != null
            ? SuperMediaType.video
            : fileValue != null
            ? SuperMediaType.file
            : null;
    final sizeValue = read(const ['sizebytes', 'filesize', 'size', 'length']);
    final sizeBytes = sizeValue is num ? sizeValue.round() : null;
    final durationValue = read(const ['duration', 'durationms']);
    final duration = switch (durationValue) {
      Duration duration => duration,
      num milliseconds => Duration(milliseconds: milliseconds.round()),
      _ => null,
    };
    final thumbnailPath =
        read(const ['thumbnailpath', 'thumbpath', 'posterpath'])?.toString();
    final thumbnailUrl =
        read(const [
          'thumbnailurl',
          'thumburl',
          'posterurl',
          'previewurl',
          'poster',
        ])?.toString();
    final data = read(const ['data']) ?? originalData;

    if (urlValue != null) {
      return SuperMediaItem.remote(
        id: id,
        url: urlValue.toString(),
        name: name,
        type: explicitType ?? inferredType,
        sizeBytes: sizeBytes,
        duration: duration,
        thumbnailPath: thumbnailPath,
        thumbnailUrl: thumbnailUrl,
        data: data,
      );
    }
    return SuperMediaItem.local(
      id: id,
      path: pathValue.toString(),
      name: name,
      type: explicitType ?? inferredType,
      sizeBytes: sizeBytes,
      duration: duration,
      thumbnailPath: thumbnailPath,
      thumbnailUrl: thumbnailUrl,
      data: data,
    );
  }

  static Map<dynamic, dynamic>? _tryJsonMap(Object value) {
    try {
      final decoded = jsonDecode(jsonEncode(value));
      return decoded is Map ? decoded : null;
    } on Object {
      return null;
    }
  }

  static String _normalizeKey(Object? key) {
    return key.toString().toLowerCase().replaceAll(RegExp('[^a-z0-9]'), '');
  }

  static bool _looksLikeLocalPath(String value) {
    return value.startsWith('/') ||
        value.startsWith('./') ||
        value.startsWith('../') ||
        RegExp(r'^[a-zA-Z]:[\\/]').hasMatch(value);
  }

  /// Normalizes an iterable of strings, maps, files, or custom models.
  static List<SuperMediaItem> fromObjects<T extends Object>(
    Iterable<T> values, {
    SuperMediaValueMapper<T>? mapper,
  }) {
    return [
      for (final (index, value) in values.indexed)
        SuperMediaItem.fromObject(value, index: index, mapper: mapper),
    ];
  }

  /// Combines singular and plural initial values without duplicate sources.
  static List<SuperMediaItem> fromInitialValues<T extends Object>({
    T? item,
    Iterable<T> items = const [],
    SuperMediaValueMapper<T>? mapper,
  }) {
    final values = <T>[if (item != null) item, ...items];
    final result = <SuperMediaItem>[];
    for (final (index, value) in values.indexed) {
      final media = SuperMediaItem.fromObject(
        value,
        index: index,
        mapper: mapper,
      );
      if (!result.any((item) => item.hasSameSource(media))) result.add(media);
    }
    return result;
  }

  static SuperMediaType? _typeFromValue(Object? value) {
    if (value is SuperMediaType) return value;
    final normalized = value?.toString().toLowerCase();
    if (normalized?.startsWith('image/') ?? false) {
      return SuperMediaType.image;
    }
    if (normalized?.startsWith('video/') ?? false) {
      return SuperMediaType.video;
    }
    return switch (normalized) {
      'image' => SuperMediaType.image,
      'video' => SuperMediaType.video,
      'file' => SuperMediaType.file,
      _ => null,
    };
  }

  /// Whether this item represents a local file awaiting upload.
  bool get isLocal => origin == SuperMediaItemOrigin.local;

  /// Whether this item represents media that already exists in an API.
  bool get isRemote => origin == SuperMediaItemOrigin.remote;

  /// Whether [other] has the same ID, local path, or remote URL.
  bool hasSameSource(SuperMediaItem other) {
    if (id == other.id) return true;
    if (path != null && other.path != null && path == other.path) return true;
    return url != null && other.url != null && url == other.url;
  }

  /// Whether this remote item has been marked for deletion.
  bool get isRemoved => status == SuperMediaItemStatus.removed;

  /// A [File] for [path], or null for URL-only remote items.
  File? get file => path == null ? null : File(path!);

  /// Returns a copy with the supplied values replacing current metadata.
  SuperMediaItem copyWith({
    String? id,
    String? path,
    String? url,
    String? thumbnailPath,
    String? thumbnailUrl,
    String? name,
    SuperMediaType? type,
    int? sizeBytes,
    Duration? duration,
    SuperMediaItemOrigin? origin,
    SuperMediaItemStatus? status,
    double? uploadProgress,
    Object? data,
  }) {
    return SuperMediaItem(
      id: id ?? this.id,
      path: path ?? this.path,
      url: url ?? this.url,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      name: name ?? this.name,
      type: type ?? this.type,
      sizeBytes: sizeBytes ?? this.sizeBytes,
      duration: duration ?? this.duration,
      origin: origin ?? this.origin,
      status: status ?? this.status,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      data: data ?? this.data,
    );
  }

  @override
  bool operator ==(Object other) => other is SuperMediaItem && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
