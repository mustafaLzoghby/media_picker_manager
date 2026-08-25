import 'package:flutter/widgets.dart';

import '../config/super_media_picker_config.dart';
import '../controllers/super_media_controller.dart';
import '../enums/media_enums.dart';
import '../models/super_media_item.dart';
import '../services/super_media_picker_service.dart';
import 'super_media_picker_widget.dart';

typedef SuperUploadPath = void Function(String path);
typedef SuperUploadPaths = void Function(List<String> paths);

/// Picks exactly one image and returns its local path.
class SuperImagePicker<T extends Object> extends StatelessWidget {
  const SuperImagePicker({
    super.key,
    this.controller,
    this.initialImage,
    this.initialItemMapper,
    this.config = const SuperMediaPickerConfig(),
    this.width,
    this.height,
    this.alignment,
    this.quality,
    this.maxWidth,
    this.maxHeight,
    this.maxSizeBytes,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onUploadImage,
    this.onChanged,
    this.onValidationError,
  });

  final SuperMediaController? controller;
  final T? initialImage;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final int? quality;
  final int? maxWidth;
  final int? maxHeight;
  final int? maxSizeBytes;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperUploadPath? onUploadImage;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItem: initialImage,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.image},
      multiple: false,
      width: width,
      height: height,
      alignment: alignment,
      imageQuality: quality,
      imageMaxWidth: maxWidth,
      imageMaxHeight: maxHeight,
      imageMaxSizeBytes: maxSizeBytes,
    ),
    transform: transform,
    addButtonBuilder: addButtonBuilder,
    itemBuilder: itemBuilder,
    onDelete: onDelete,
    onDeleteAll: onDeleteAll,
    onPicked: (items) => _onePath(items, onUploadImage),
    onChanged: onChanged,
    onValidationError: onValidationError,
  );
}

/// Picks multiple images and returns the paths from one picker action.
class SuperImagesPicker<T extends Object> extends StatelessWidget {
  const SuperImagesPicker({
    super.key,
    this.controller,
    this.initialImages = const [],
    this.initialItemMapper,
    this.config = const SuperMediaPickerConfig(),
    this.maxItems,
    this.quality,
    this.maxWidth,
    this.maxHeight,
    this.maxSizeBytes,
    this.maxTotalSizeBytes,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onUploadImages,
    this.onChanged,
    this.onValidationError,
  });

  final SuperMediaController? controller;
  final Iterable<T> initialImages;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final int? maxItems;
  final int? quality;
  final int? maxWidth;
  final int? maxHeight;
  final int? maxSizeBytes;
  final int? maxTotalSizeBytes;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperUploadPaths? onUploadImages;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItems: initialImages,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.image},
      multiple: true,
      maxItems: maxItems,
      maxImages: maxItems,
      imageQuality: quality,
      imageMaxWidth: maxWidth,
      imageMaxHeight: maxHeight,
      imageMaxSizeBytes: maxSizeBytes,
      maxTotalSizeBytes: maxTotalSizeBytes,
    ),
    transform: transform,
    addButtonBuilder: addButtonBuilder,
    itemBuilder: itemBuilder,
    onDelete: onDelete,
    onDeleteAll: onDeleteAll,
    onPicked: (items) => _manyPaths(items, onUploadImages),
    onChanged: onChanged,
    onValidationError: onValidationError,
  );
}

/// Picks exactly one video and returns its local path.
class SuperVideoPicker<T extends Object> extends StatelessWidget {
  const SuperVideoPicker({
    super.key,
    this.controller,
    this.initialVideo,
    this.initialItemMapper,
    this.config = const SuperMediaPickerConfig(),
    this.width,
    this.height,
    this.alignment,
    this.maxSizeBytes,
    this.maxDuration,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onUploadVideo,
    this.onChanged,
    this.onValidationError,
  });

  final SuperMediaController? controller;
  final T? initialVideo;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final int? maxSizeBytes;
  final Duration? maxDuration;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperUploadPath? onUploadVideo;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItem: initialVideo,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.video},
      multiple: false,
      width: width,
      height: height,
      alignment: alignment,
      videoMaxSizeBytes: maxSizeBytes,
      videoMaxDuration: maxDuration,
    ),
    transform: transform,
    addButtonBuilder: addButtonBuilder,
    itemBuilder: itemBuilder,
    onDelete: onDelete,
    onDeleteAll: onDeleteAll,
    onPicked: (items) => _onePath(items, onUploadVideo),
    onChanged: onChanged,
    onValidationError: onValidationError,
  );
}

/// Picks multiple videos and returns the paths from one picker action.
class SuperVideosPicker<T extends Object> extends StatelessWidget {
  const SuperVideosPicker({
    super.key,
    this.controller,
    this.initialVideos = const [],
    this.initialItemMapper,
    this.config = const SuperMediaPickerConfig(),
    this.maxItems,
    this.maxSizeBytes,
    this.maxTotalSizeBytes,
    this.maxDuration,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onUploadVideos,
    this.onChanged,
    this.onValidationError,
  });

  final SuperMediaController? controller;
  final Iterable<T> initialVideos;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final int? maxItems;
  final int? maxSizeBytes;
  final int? maxTotalSizeBytes;
  final Duration? maxDuration;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperUploadPaths? onUploadVideos;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItems: initialVideos,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.video},
      multiple: true,
      maxItems: maxItems,
      maxVideos: maxItems,
      videoMaxSizeBytes: maxSizeBytes,
      videoMaxDuration: maxDuration,
      maxTotalSizeBytes: maxTotalSizeBytes,
    ),
    transform: transform,
    addButtonBuilder: addButtonBuilder,
    itemBuilder: itemBuilder,
    onDelete: onDelete,
    onDeleteAll: onDeleteAll,
    onPicked: (items) => _manyPaths(items, onUploadVideos),
    onChanged: onChanged,
    onValidationError: onValidationError,
  );
}

/// Picks exactly one generic file and returns its local path.
class SuperFilePicker<T extends Object> extends StatelessWidget {
  const SuperFilePicker({
    super.key,
    this.controller,
    this.initialFile,
    this.initialItemMapper,
    this.config = const SuperMediaPickerConfig(),
    this.width,
    this.height,
    this.alignment,
    this.maxSizeBytes,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onUploadFile,
    this.onChanged,
    this.onValidationError,
  });

  final SuperMediaController? controller;
  final T? initialFile;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final int? maxSizeBytes;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperUploadPath? onUploadFile;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItem: initialFile,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.file},
      multiple: false,
      width: width,
      height: height,
      alignment: alignment,
      fileMaxSizeBytes: maxSizeBytes,
    ),
    transform: transform,
    addButtonBuilder: addButtonBuilder,
    itemBuilder: itemBuilder,
    onDelete: onDelete,
    onDeleteAll: onDeleteAll,
    onPicked: (items) => _onePath(items, onUploadFile),
    onChanged: onChanged,
    onValidationError: onValidationError,
  );
}

/// Picks multiple generic files and returns the paths from one picker action.
class SuperFilesPicker<T extends Object> extends StatelessWidget {
  const SuperFilesPicker({
    super.key,
    this.controller,
    this.initialFiles = const [],
    this.initialItemMapper,
    this.config = const SuperMediaPickerConfig(),
    this.maxItems,
    this.maxSizeBytes,
    this.maxTotalSizeBytes,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onUploadFiles,
    this.onChanged,
    this.onValidationError,
  });

  final SuperMediaController? controller;
  final Iterable<T> initialFiles;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final int? maxItems;
  final int? maxSizeBytes;
  final int? maxTotalSizeBytes;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperUploadPaths? onUploadFiles;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItems: initialFiles,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.file},
      multiple: true,
      maxItems: maxItems,
      maxFiles: maxItems,
      fileMaxSizeBytes: maxSizeBytes,
      maxTotalSizeBytes: maxTotalSizeBytes,
    ),
    transform: transform,
    addButtonBuilder: addButtonBuilder,
    itemBuilder: itemBuilder,
    onDelete: onDelete,
    onDeleteAll: onDeleteAll,
    onPicked: (items) => _manyPaths(items, onUploadFiles),
    onChanged: onChanged,
    onValidationError: onValidationError,
  );
}

/// Picks exactly one image or video and returns its local path.
class SuperSingleMediaPicker<T extends Object> extends StatelessWidget {
  const SuperSingleMediaPicker({
    super.key,
    this.controller,
    this.initialMedia,
    this.initialItemMapper,
    this.config = const SuperMediaPickerConfig(),
    this.width,
    this.height,
    this.alignment,
    this.imageQuality,
    this.imageMaxWidth,
    this.imageMaxHeight,
    this.imageMaxSizeBytes,
    this.videoMaxSizeBytes,
    this.videoMaxDuration,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onUploadMedia,
    this.onChanged,
    this.onValidationError,
  });

  final SuperMediaController? controller;
  final T? initialMedia;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final AlignmentGeometry? alignment;
  final int? imageQuality;
  final int? imageMaxWidth;
  final int? imageMaxHeight;
  final int? imageMaxSizeBytes;
  final int? videoMaxSizeBytes;
  final Duration? videoMaxDuration;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperUploadPath? onUploadMedia;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItem: initialMedia,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.image, SuperMediaType.video},
      multiple: false,
      width: width,
      height: height,
      alignment: alignment,
      imageQuality: imageQuality,
      imageMaxWidth: imageMaxWidth,
      imageMaxHeight: imageMaxHeight,
      imageMaxSizeBytes: imageMaxSizeBytes,
      videoMaxSizeBytes: videoMaxSizeBytes,
      videoMaxDuration: videoMaxDuration,
    ),
    transform: transform,
    addButtonBuilder: addButtonBuilder,
    itemBuilder: itemBuilder,
    onDelete: onDelete,
    onDeleteAll: onDeleteAll,
    onPicked: (items) => _onePath(items, onUploadMedia),
    onChanged: onChanged,
    onValidationError: onValidationError,
  );
}

/// Picks multiple images and videos and returns their local paths.
class SuperMultipleMediaPicker<T extends Object> extends StatelessWidget {
  const SuperMultipleMediaPicker({
    super.key,
    this.controller,
    this.initialMedia = const [],
    this.initialItemMapper,
    this.config = const SuperMediaPickerConfig(),
    this.maxItems,
    this.maxImages,
    this.maxVideos,
    this.imageQuality,
    this.imageMaxWidth,
    this.imageMaxHeight,
    this.imageMaxSizeBytes,
    this.videoMaxSizeBytes,
    this.videoMaxDuration,
    this.maxTotalSizeBytes,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onUploadMedia,
    this.onChanged,
    this.onValidationError,
  });

  final SuperMediaController? controller;
  final Iterable<T> initialMedia;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final int? maxItems;
  final int? maxImages;
  final int? maxVideos;
  final int? imageQuality;
  final int? imageMaxWidth;
  final int? imageMaxHeight;
  final int? imageMaxSizeBytes;
  final int? videoMaxSizeBytes;
  final Duration? videoMaxDuration;
  final int? maxTotalSizeBytes;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperUploadPaths? onUploadMedia;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItems: initialMedia,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.image, SuperMediaType.video},
      multiple: true,
      maxItems: maxItems,
      maxImages: maxImages,
      maxVideos: maxVideos,
      imageQuality: imageQuality,
      imageMaxWidth: imageMaxWidth,
      imageMaxHeight: imageMaxHeight,
      imageMaxSizeBytes: imageMaxSizeBytes,
      videoMaxSizeBytes: videoMaxSizeBytes,
      videoMaxDuration: videoMaxDuration,
      maxTotalSizeBytes: maxTotalSizeBytes,
    ),
    transform: transform,
    addButtonBuilder: addButtonBuilder,
    itemBuilder: itemBuilder,
    onDelete: onDelete,
    onDeleteAll: onDeleteAll,
    onPicked: (items) => _manyPaths(items, onUploadMedia),
    onChanged: onChanged,
    onValidationError: onValidationError,
  );
}

void _onePath(List<SuperMediaItem> items, SuperUploadPath? callback) {
  if (callback == null) return;
  for (final item in items) {
    final path = item.path;
    if (path != null) callback(path);
  }
}

void _manyPaths(List<SuperMediaItem> items, SuperUploadPaths? callback) {
  if (callback == null) return;
  final paths = items.map((item) => item.path).whereType<String>().toList();
  if (paths.isNotEmpty) callback(List.unmodifiable(paths));
}

SuperMediaPickerConfig _scope(
  SuperMediaPickerConfig config,
  Set<SuperMediaType> types, {
  required bool multiple,
  double? width,
  double? height,
  AlignmentGeometry? alignment,
  int? maxItems,
  int? maxImages,
  int? maxVideos,
  int? maxFiles,
  int? maxTotalSizeBytes,
  int? imageQuality,
  int? imageMaxSizeBytes,
  int? imageMaxWidth,
  int? imageMaxHeight,
  int? videoMaxSizeBytes,
  Duration? videoMaxDuration,
  int? fileMaxSizeBytes,
}) {
  return SuperMediaPickerConfig(
    allowedTypes: types,
    sources: config.sources,
    allowMultiple: multiple,
    enableReorder: config.enableReorder,
    showReorderHandle: config.showReorderHandle,
    enablePreview: config.enablePreview,
    keepAlive: config.keepAlive,
    showFileSize: config.showFileSize,
    showFileName: config.showFileName,
    showLocalFileSize: config.showLocalFileSize,
    showLocalFileName: config.showLocalFileName,
    showRemoteFileSize: config.showRemoteFileSize,
    showRemoteFileName: config.showRemoteFileName,
    showRemoveButton: config.showRemoveButton,
    showRemoteBadge: config.showRemoteBadge,
    layout: config.layout,
    crossAxisCount: multiple ? config.crossAxisCount : 1,
    spacing: config.spacing,
    borderRadius: config.borderRadius,
    gridItemAspectRatio: config.gridItemAspectRatio,
    gridItemHeight: config.gridItemHeight,
    listItemHeight: config.listItemHeight,
    image: SuperImageConfig(
      allowMultiple: multiple,
      maxSizeBytes: imageMaxSizeBytes ?? config.image.maxSizeBytes,
      maxWidth: imageMaxWidth ?? config.image.maxWidth,
      maxHeight: imageMaxHeight ?? config.image.maxHeight,
      quality: imageQuality ?? config.image.quality,
      preset: config.image.preset,
    ),
    video: SuperVideoConfig(
      allowMultiple: multiple,
      maxSizeBytes: videoMaxSizeBytes ?? config.video.maxSizeBytes,
      maxDuration: videoMaxDuration ?? config.video.maxDuration,
    ),
    file: SuperFileConfig(
      allowMultiple: multiple,
      maxSizeBytes: fileMaxSizeBytes ?? config.file.maxSizeBytes,
      allowedExtensions: config.file.allowedExtensions,
    ),
    limits: SuperMediaLimits(
      maxItems: multiple ? maxItems ?? config.limits.maxItems : 1,
      maxImages: _singleTypeLimit(
        maxImages ?? config.limits.maxImages,
        types,
        SuperMediaType.image,
        multiple,
      ),
      maxVideos: _singleTypeLimit(
        maxVideos ?? config.limits.maxVideos,
        types,
        SuperMediaType.video,
        multiple,
      ),
      maxFiles: _singleTypeLimit(
        maxFiles ?? config.limits.maxFiles,
        types,
        SuperMediaType.file,
        multiple,
      ),
      maxTotalSizeBytes: maxTotalSizeBytes ?? config.limits.maxTotalSizeBytes,
    ),
    frame: config.frame,
    itemFrame: SuperMediaItemFrameConfig(
      width: width ?? config.itemFrame.width,
      height: height ?? config.itemFrame.height,
      alignment: alignment ?? config.itemFrame.alignment,
    ),
    text: config.text,
    locale: config.locale,
    textDirection: config.textDirection,
    translations: config.translations,
    icons: config.icons,
  );
}

int? _singleTypeLimit(
  int? configured,
  Set<SuperMediaType> types,
  SuperMediaType type,
  bool multiple,
) {
  if (!multiple && types.length == 1 && types.contains(type)) return 1;
  return configured;
}
