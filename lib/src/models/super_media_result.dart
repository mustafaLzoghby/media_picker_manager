import '../enums/media_enums.dart';
import 'super_media_item.dart';

class SuperMediaResult {
  final List<SuperMediaItem> items;
  final List<SuperMediaItem> removedItems;

  const SuperMediaResult({required this.items, required this.removedItems});

  List<SuperMediaItem> get addedItems =>
      items.where((e) => e.isLocal).toList(growable: false);
  List<SuperMediaItem> get existingItems =>
      items.where((e) => e.isRemote).toList(growable: false);
  List<SuperMediaItem> get addedImages => addedItems
      .where((e) => e.type == SuperMediaType.image)
      .toList(growable: false);
  List<SuperMediaItem> get addedVideos => addedItems
      .where((e) => e.type == SuperMediaType.video)
      .toList(growable: false);
  List<SuperMediaItem> get addedFiles => addedItems
      .where((e) => e.type == SuperMediaType.file)
      .toList(growable: false);
  List<String> get addedImagePaths => _paths(addedImages);
  List<String> get addedVideoPaths => _paths(addedVideos);
  List<String> get addedFilePaths => _paths(addedFiles);
  List<String> get addedMediaPaths => _paths(addedItems);
  List<SuperMediaItem> get images => items
      .where((e) => e.type == SuperMediaType.image)
      .toList(growable: false);
  List<SuperMediaItem> get videos => items
      .where((e) => e.type == SuperMediaType.video)
      .toList(growable: false);
  List<SuperMediaItem> get files =>
      items.where((e) => e.type == SuperMediaType.file).toList(growable: false);
  int get totalSizeBytes =>
      items.fold(0, (total, item) => total + (item.sizeBytes ?? 0));
  List<String> get removedItemIds =>
      removedItems.map((item) => item.id).toList(growable: false);

  List<String> _paths(Iterable<SuperMediaItem> source) => source
      .map((item) => item.path)
      .whereType<String>()
      .toList(growable: false);
}
