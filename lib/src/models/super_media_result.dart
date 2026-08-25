import '../enums/media_enums.dart';
import 'super_media_item.dart';

/// An immutable snapshot of visible items and remote deletion intent.
class SuperMediaResult {
  /// All media items currently visible in the picker.
  final List<SuperMediaItem> items;

  /// Remote items removed by the user and ready for an API delete request.
  final List<SuperMediaItem> removedItems;

  /// Creates a result from current [items] and tracked [removedItems].
  const SuperMediaResult({required this.items, required this.removedItems});

  /// Newly selected local items that are ready to upload.
  List<SuperMediaItem> get addedItems =>
      items.where((e) => e.isLocal).toList(growable: false);

  /// Unchanged remote items that already exist in the API.
  List<SuperMediaItem> get existingItems =>
      items.where((e) => e.isRemote).toList(growable: false);

  /// Newly selected local image items.
  List<SuperMediaItem> get addedImages => addedItems
      .where((e) => e.type == SuperMediaType.image)
      .toList(growable: false);

  /// Newly selected local video items.
  List<SuperMediaItem> get addedVideos => addedItems
      .where((e) => e.type == SuperMediaType.video)
      .toList(growable: false);

  /// Newly selected local generic file items.
  List<SuperMediaItem> get addedFiles => addedItems
      .where((e) => e.type == SuperMediaType.file)
      .toList(growable: false);

  /// Local paths for newly selected images.
  List<String> get addedImagePaths => _paths(addedImages);

  /// Local paths for newly selected videos.
  List<String> get addedVideoPaths => _paths(addedVideos);

  /// Local paths for newly selected generic files.
  List<String> get addedFilePaths => _paths(addedFiles);

  /// Local paths for every newly selected media item.
  List<String> get addedMediaPaths => _paths(addedItems);

  /// Every currently visible image, including local and remote items.
  List<SuperMediaItem> get images => items
      .where((e) => e.type == SuperMediaType.image)
      .toList(growable: false);

  /// Every currently visible video, including local and remote items.
  List<SuperMediaItem> get videos => items
      .where((e) => e.type == SuperMediaType.video)
      .toList(growable: false);

  /// Every currently visible generic file.
  List<SuperMediaItem> get files =>
      items.where((e) => e.type == SuperMediaType.file).toList(growable: false);

  /// Sum of all known item sizes; unknown sizes contribute zero.
  int get totalSizeBytes =>
      items.fold(0, (total, item) => total + (item.sizeBytes ?? 0));

  /// API identifiers for remote items that the user removed.
  List<String> get removedItemIds =>
      removedItems.map((item) => item.id).toList(growable: false);

  List<String> _paths(Iterable<SuperMediaItem> source) => source
      .map((item) => item.path)
      .whereType<String>()
      .toList(growable: false);
}
