import 'package:flutter/foundation.dart';

import '../config/super_media_picker_config.dart';
import '../enums/media_enums.dart';
import '../models/super_media_item.dart';
import '../models/super_media_result.dart';
import '../models/super_media_validation_error.dart';

/// Owns picker state and exposes upload-ready and deletion-ready results.
class SuperMediaController<T extends Object> extends ChangeNotifier {
  /// Creates a controller with optional singular and plural initial API data.
  SuperMediaController({
    T? initialItem,
    Iterable<T> initialItems = const [],
    SuperMediaValueMapper<T>? initialItemMapper,
  }) : _items = SuperMediaItem.fromInitialValues(
         item: initialItem,
         items: initialItems,
         mapper: initialItemMapper,
       );

  final List<SuperMediaItem> _removedItems = [];
  List<SuperMediaItem> _items;

  /// Immutable view of all media currently displayed by the picker.
  List<SuperMediaItem> get items => List.unmodifiable(_items);

  /// Immutable view of remote items marked for API deletion.
  List<SuperMediaItem> get removedItems => List.unmodifiable(_removedItems);

  /// Current upload and deletion snapshot for submitting a form.
  SuperMediaResult get result =>
      SuperMediaResult(items: items, removedItems: removedItems);

  /// All currently visible image items.
  List<SuperMediaItem> get images => _items
      .where((e) => e.type == SuperMediaType.image)
      .toList(growable: false);

  /// All currently visible video items.
  List<SuperMediaItem> get videos => _items
      .where((e) => e.type == SuperMediaType.video)
      .toList(growable: false);

  /// All currently visible generic file items.
  List<SuperMediaItem> get files => _items
      .where((e) => e.type == SuperMediaType.file)
      .toList(growable: false);

  /// Newly selected local items ready for upload.
  List<SuperMediaItem> get localItems =>
      _items.where((e) => e.isLocal).toList(growable: false);

  /// Existing remote API items that have not been removed.
  List<SuperMediaItem> get remoteItems =>
      _items.where((e) => e.isRemote).toList(growable: false);

  /// Sum of known file sizes for visible media.
  int get totalSizeBytes =>
      _items.fold(0, (sum, e) => sum + (e.sizeBytes ?? 0));

  /// Validates [item] against type, count, size, extension, and duration rules.
  SuperMediaValidationError? validateItem(
    SuperMediaItem item,
    SuperMediaPickerConfig config, {
    Iterable<SuperMediaItem>? currentItems,
  }) {
    final items = currentItems ?? _items;
    if (!config.allowedTypes.contains(item.type)) {
      return SuperMediaValidationError(
        'type_not_allowed',
        '${item.type.name} is not allowed.',
        item: item,
      );
    }
    final limits = config.limits;
    if (limits.maxItems != null && items.length >= limits.maxItems!) {
      return SuperMediaValidationError(
        'max_items',
        'Maximum ${limits.maxItems} items allowed.',
        item: item,
      );
    }
    final typeCount = items.where((e) => e.type == item.type).length;
    final typeLimit = switch (item.type) {
      SuperMediaType.image => limits.maxImages,
      SuperMediaType.video => limits.maxVideos,
      SuperMediaType.file => limits.maxFiles,
    };
    if (typeLimit != null && typeCount >= typeLimit) {
      return SuperMediaValidationError(
        'max_${item.type.name}s',
        'Maximum $typeLimit ${item.type.name}s allowed.',
        item: item,
      );
    }
    final sizeLimit = switch (item.type) {
      SuperMediaType.image => config.image.maxSizeBytes,
      SuperMediaType.video => config.video.maxSizeBytes,
      SuperMediaType.file => config.file.maxSizeBytes,
    };
    if (sizeLimit != null &&
        item.sizeBytes != null &&
        item.sizeBytes! > sizeLimit) {
      return SuperMediaValidationError(
        'file_too_large',
        '${item.name} is larger than the allowed size.',
        item: item,
      );
    }
    final currentSizeBytes = items.fold<int>(
      0,
      (sum, e) => sum + (e.sizeBytes ?? 0),
    );
    if (limits.maxTotalSizeBytes != null &&
        item.sizeBytes != null &&
        currentSizeBytes + item.sizeBytes! > limits.maxTotalSizeBytes!) {
      return SuperMediaValidationError(
        'total_size_exceeded',
        'Maximum total media size exceeded.',
        item: item,
      );
    }
    if (item.type == SuperMediaType.file &&
        config.file.allowedExtensions.isNotEmpty) {
      final lower = item.name.toLowerCase();
      final allowed = config.file.allowedExtensions.any(
        (e) => lower.endsWith('.${e.toLowerCase().replaceFirst('.', '')}'),
      );
      if (!allowed) {
        return SuperMediaValidationError(
          'extension_not_allowed',
          'File extension is not allowed.',
          item: item,
        );
      }
    }
    if (item.type == SuperMediaType.video &&
        config.video.maxDuration != null &&
        item.duration != null &&
        item.duration! > config.video.maxDuration!) {
      return SuperMediaValidationError(
        'video_too_long',
        'Video duration exceeds the allowed duration.',
        item: item,
      );
    }
    return null;
  }

  /// Adds [item], returning a validation error instead of throwing on failure.
  SuperMediaValidationError? add(
    SuperMediaItem item, {
    required SuperMediaPickerConfig config,
  }) {
    if (_items.any((current) => current.hasSameSource(item))) return null;
    final error = validateItem(
      item,
      config,
      currentItems: config.allowMultiple ? _items : const <SuperMediaItem>[],
    );
    if (error != null) return error;
    if (!config.allowMultiple) {
      _trackRemoteRemovals();
      _items.clear();
    }
    _items.add(item);
    notifyListeners();
    return null;
  }

  /// Adds each supplied item and returns every validation failure.
  List<SuperMediaValidationError> addAll(
    List<SuperMediaItem> items, {
    required SuperMediaPickerConfig config,
  }) {
    final errors = <SuperMediaValidationError>[];
    for (final item in items) {
      final error = add(item, config: config);
      if (error != null) errors.add(error);
      if (!config.allowMultiple) break;
    }
    return errors;
  }

  /// Removes [item] and tracks it when a remote API item is removed.
  void remove(SuperMediaItem item) {
    final index = _items.indexWhere((e) => e.id == item.id);
    if (index == -1) return;
    final removed = _items.removeAt(index);
    if (removed.isRemote && !_removedItems.any((e) => e.id == removed.id)) {
      _removedItems.add(removed.copyWith(status: SuperMediaItemStatus.removed));
    }
    notifyListeners();
  }

  /// Deletes one visible item by its local or API ID.
  ///
  /// Remote items are added to [removedItems] so their IDs can be sent to a
  /// delete endpoint. Returns false when no matching item exists.
  bool deleteItemById(String id) {
    final index = _items.indexWhere((item) => item.id == id);
    if (index == -1) return false;
    remove(_items[index]);
    return true;
  }

  /// Deletes every visible item.
  ///
  /// By default, every remote item is retained in [removedItems] for API
  /// deletion while local items are simply removed.
  List<String> deleteAllItems({bool trackRemoteRemovals = true}) {
    final remoteIds = _items
        .where((item) => item.isRemote)
        .map((item) => item.id)
        .toList(growable: false);
    clear(trackRemoteRemovals: trackRemoteRemovals);
    return remoteIds;
  }

  /// Removes the visible item at [index].
  void removeAt(int index) => remove(_items[index]);

  /// Restores a previously removed remote item to the visible collection.
  void restoreRemote(SuperMediaItem item) {
    final index = _removedItems.indexWhere((e) => e.id == item.id);
    if (index == -1) return;
    final restored = _removedItems
        .removeAt(index)
        .copyWith(status: SuperMediaItemStatus.existing);
    _items.add(restored);
    notifyListeners();
  }

  /// Replaces [oldItem] after validating [newItem] with [config].
  void replace(
    SuperMediaItem oldItem,
    SuperMediaItem newItem, {
    required SuperMediaPickerConfig config,
  }) {
    final index = _items.indexWhere((e) => e.id == oldItem.id);
    if (index == -1) return;
    remove(oldItem);
    final error = add(newItem, config: config);
    if (error != null) {
      _items.insert(index.clamp(0, _items.length).toInt(), oldItem);
      if (oldItem.isRemote) {
        _removedItems.removeWhere((e) => e.id == oldItem.id);
      }
      notifyListeners();
      throw error;
    }
  }

  /// Moves an item between indices using reorderable-list index semantics.
  void reorder(int oldIndex, int newIndex) {
    if (newIndex > oldIndex) newIndex -= 1;
    final item = _items.removeAt(oldIndex);
    _items.insert(newIndex, item);
    notifyListeners();
  }

  /// Updates upload [progress] and [status] for the item identified by [id].
  void setUploadProgress(
    String id,
    double progress, {
    SuperMediaItemStatus status = SuperMediaItemStatus.uploading,
  }) {
    final index = _items.indexWhere((e) => e.id == id);
    if (index == -1) return;
    _items[index] = _items[index].copyWith(
      uploadProgress: progress.clamp(0.0, 1.0).toDouble(),
      status: status,
    );
    notifyListeners();
  }

  /// Marks the item identified by [id] as completely uploaded.
  void markUploaded(String id) =>
      setUploadProgress(id, 1, status: SuperMediaItemStatus.uploaded);

  /// Replaces visible state, optionally preserving deletion history or silence.
  void setItems(
    List<SuperMediaItem> items, {
    bool resetRemoved = true,
    bool notify = true,
  }) {
    _items = List.of(items);
    if (resetRemoved) _removedItems.clear();
    if (notify) notifyListeners();
  }

  /// Clears visible state and optionally tracks remote items for deletion.
  void clear({bool trackRemoteRemovals = true}) {
    if (trackRemoteRemovals) _trackRemoteRemovals();
    _items.clear();
    notifyListeners();
  }

  void _trackRemoteRemovals() {
    for (final item in _items.where((e) => e.isRemote)) {
      if (!_removedItems.any((e) => e.id == item.id)) {
        _removedItems.add(item.copyWith(status: SuperMediaItemStatus.removed));
      }
    }
  }
}
