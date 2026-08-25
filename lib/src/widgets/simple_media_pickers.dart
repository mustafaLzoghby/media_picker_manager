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
    this.emptyWidth,
    this.emptyHeight,
    this.nonEmptyWidth,
    this.nonEmptyHeight,
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
    this.onDeleteRequest,
    this.deleteConfirmation,
    this.onPickStarted,
    this.onPickFinished,
    this.onPickerFailure,
    this.validator,
    this.onUploadImage,
    this.onChanged,
    this.onValidationError,
    this.localItemBuilder,
    this.remoteItemBuilder,
    this.pickingBuilder,
    this.pickErrorBuilder,
    this.sourceOptionBuilder,
  });

  final SuperMediaController? controller;
  final T? initialImage;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final double? emptyWidth;
  final double? emptyHeight;
  final double? nonEmptyWidth;
  final double? nonEmptyHeight;
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
  final SuperMediaDeleteRequest? onDeleteRequest;
  final SuperMediaDeleteConfirmation? deleteConfirmation;
  final VoidCallback? onPickStarted;
  final VoidCallback? onPickFinished;
  final SuperMediaPickerFailure? onPickerFailure;
  final SuperMediaValidator? validator;
  final SuperUploadPath? onUploadImage;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;
  final SuperMediaItemBuilder? localItemBuilder;
  final SuperMediaItemBuilder? remoteItemBuilder;
  final WidgetBuilder? pickingBuilder;
  final SuperMediaPickerErrorBuilder? pickErrorBuilder;
  final SuperMediaSourceOptionBuilder? sourceOptionBuilder;

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
      emptyWidth: emptyWidth,
      emptyHeight: emptyHeight,
      nonEmptyWidth: nonEmptyWidth,
      nonEmptyHeight: nonEmptyHeight,
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
    onDeleteRequest: onDeleteRequest,
    deleteConfirmation: deleteConfirmation,
    onPickStarted: onPickStarted,
    onPickFinished: onPickFinished,
    onPickerFailure: onPickerFailure,
    validator: validator,
    onPicked: (items) => _onePath(items, onUploadImage),
    onChanged: onChanged,
    onValidationError: onValidationError,
    localItemBuilder: localItemBuilder,
    remoteItemBuilder: remoteItemBuilder,
    pickingBuilder: pickingBuilder,
    pickErrorBuilder: pickErrorBuilder,
    sourceOptionBuilder: sourceOptionBuilder,
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
    this.width,
    this.height,
    this.emptyWidth,
    this.emptyHeight,
    this.nonEmptyWidth,
    this.nonEmptyHeight,
    this.alignment,
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
    this.onDeleteRequest,
    this.deleteConfirmation,
    this.onPickStarted,
    this.onPickFinished,
    this.onPickerFailure,
    this.onReorder,
    this.validator,
    this.onUploadImages,
    this.onChanged,
    this.onValidationError,
    this.localItemBuilder,
    this.remoteItemBuilder,
    this.pickingBuilder,
    this.pickErrorBuilder,
    this.sourceOptionBuilder,
  });

  final SuperMediaController? controller;
  final Iterable<T> initialImages;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final double? emptyWidth;
  final double? emptyHeight;
  final double? nonEmptyWidth;
  final double? nonEmptyHeight;
  final AlignmentGeometry? alignment;
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
  final SuperMediaDeleteRequest? onDeleteRequest;
  final SuperMediaDeleteConfirmation? deleteConfirmation;
  final VoidCallback? onPickStarted;
  final VoidCallback? onPickFinished;
  final SuperMediaPickerFailure? onPickerFailure;
  final SuperMediaReordered? onReorder;
  final SuperMediaValidator? validator;
  final SuperUploadPaths? onUploadImages;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;
  final SuperMediaItemBuilder? localItemBuilder;
  final SuperMediaItemBuilder? remoteItemBuilder;
  final WidgetBuilder? pickingBuilder;
  final SuperMediaPickerErrorBuilder? pickErrorBuilder;
  final SuperMediaSourceOptionBuilder? sourceOptionBuilder;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItems: initialImages,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.image},
      multiple: true,
      width: width,
      height: height,
      emptyWidth: emptyWidth,
      emptyHeight: emptyHeight,
      nonEmptyWidth: nonEmptyWidth,
      nonEmptyHeight: nonEmptyHeight,
      alignment: alignment,
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
    onDeleteRequest: onDeleteRequest,
    deleteConfirmation: deleteConfirmation,
    onPickStarted: onPickStarted,
    onPickFinished: onPickFinished,
    onPickerFailure: onPickerFailure,
    onReorder: onReorder,
    validator: validator,
    onPicked: (items) => _manyPaths(items, onUploadImages),
    onChanged: onChanged,
    onValidationError: onValidationError,
    localItemBuilder: localItemBuilder,
    remoteItemBuilder: remoteItemBuilder,
    pickingBuilder: pickingBuilder,
    pickErrorBuilder: pickErrorBuilder,
    sourceOptionBuilder: sourceOptionBuilder,
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
    this.emptyWidth,
    this.emptyHeight,
    this.nonEmptyWidth,
    this.nonEmptyHeight,
    this.alignment,
    this.maxSizeBytes,
    this.maxDuration,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onDeleteRequest,
    this.deleteConfirmation,
    this.onPickStarted,
    this.onPickFinished,
    this.onPickerFailure,
    this.validator,
    this.onUploadVideo,
    this.onChanged,
    this.onValidationError,
    this.localItemBuilder,
    this.remoteItemBuilder,
    this.pickingBuilder,
    this.pickErrorBuilder,
    this.sourceOptionBuilder,
  });

  final SuperMediaController? controller;
  final T? initialVideo;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final double? emptyWidth;
  final double? emptyHeight;
  final double? nonEmptyWidth;
  final double? nonEmptyHeight;
  final AlignmentGeometry? alignment;
  final int? maxSizeBytes;
  final Duration? maxDuration;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperMediaDeleteRequest? onDeleteRequest;
  final SuperMediaDeleteConfirmation? deleteConfirmation;
  final VoidCallback? onPickStarted;
  final VoidCallback? onPickFinished;
  final SuperMediaPickerFailure? onPickerFailure;
  final SuperMediaValidator? validator;
  final SuperUploadPath? onUploadVideo;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;
  final SuperMediaItemBuilder? localItemBuilder;
  final SuperMediaItemBuilder? remoteItemBuilder;
  final WidgetBuilder? pickingBuilder;
  final SuperMediaPickerErrorBuilder? pickErrorBuilder;
  final SuperMediaSourceOptionBuilder? sourceOptionBuilder;

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
      emptyWidth: emptyWidth,
      emptyHeight: emptyHeight,
      nonEmptyWidth: nonEmptyWidth,
      nonEmptyHeight: nonEmptyHeight,
      alignment: alignment,
      videoMaxSizeBytes: maxSizeBytes,
      videoMaxDuration: maxDuration,
    ),
    transform: transform,
    addButtonBuilder: addButtonBuilder,
    itemBuilder: itemBuilder,
    onDelete: onDelete,
    onDeleteAll: onDeleteAll,
    onDeleteRequest: onDeleteRequest,
    deleteConfirmation: deleteConfirmation,
    onPickStarted: onPickStarted,
    onPickFinished: onPickFinished,
    onPickerFailure: onPickerFailure,
    validator: validator,
    onPicked: (items) => _onePath(items, onUploadVideo),
    onChanged: onChanged,
    onValidationError: onValidationError,
    localItemBuilder: localItemBuilder,
    remoteItemBuilder: remoteItemBuilder,
    pickingBuilder: pickingBuilder,
    pickErrorBuilder: pickErrorBuilder,
    sourceOptionBuilder: sourceOptionBuilder,
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
    this.width,
    this.height,
    this.emptyWidth,
    this.emptyHeight,
    this.nonEmptyWidth,
    this.nonEmptyHeight,
    this.alignment,
    this.maxItems,
    this.maxSizeBytes,
    this.maxTotalSizeBytes,
    this.maxDuration,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onDeleteRequest,
    this.deleteConfirmation,
    this.onPickStarted,
    this.onPickFinished,
    this.onPickerFailure,
    this.onReorder,
    this.validator,
    this.onUploadVideos,
    this.onChanged,
    this.onValidationError,
    this.localItemBuilder,
    this.remoteItemBuilder,
    this.pickingBuilder,
    this.pickErrorBuilder,
    this.sourceOptionBuilder,
  });

  final SuperMediaController? controller;
  final Iterable<T> initialVideos;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final double? emptyWidth;
  final double? emptyHeight;
  final double? nonEmptyWidth;
  final double? nonEmptyHeight;
  final AlignmentGeometry? alignment;
  final int? maxItems;
  final int? maxSizeBytes;
  final int? maxTotalSizeBytes;
  final Duration? maxDuration;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperMediaDeleteRequest? onDeleteRequest;
  final SuperMediaDeleteConfirmation? deleteConfirmation;
  final VoidCallback? onPickStarted;
  final VoidCallback? onPickFinished;
  final SuperMediaPickerFailure? onPickerFailure;
  final SuperMediaReordered? onReorder;
  final SuperMediaValidator? validator;
  final SuperUploadPaths? onUploadVideos;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;
  final SuperMediaItemBuilder? localItemBuilder;
  final SuperMediaItemBuilder? remoteItemBuilder;
  final WidgetBuilder? pickingBuilder;
  final SuperMediaPickerErrorBuilder? pickErrorBuilder;
  final SuperMediaSourceOptionBuilder? sourceOptionBuilder;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItems: initialVideos,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.video},
      multiple: true,
      width: width,
      height: height,
      emptyWidth: emptyWidth,
      emptyHeight: emptyHeight,
      nonEmptyWidth: nonEmptyWidth,
      nonEmptyHeight: nonEmptyHeight,
      alignment: alignment,
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
    onDeleteRequest: onDeleteRequest,
    deleteConfirmation: deleteConfirmation,
    onPickStarted: onPickStarted,
    onPickFinished: onPickFinished,
    onPickerFailure: onPickerFailure,
    onReorder: onReorder,
    validator: validator,
    onPicked: (items) => _manyPaths(items, onUploadVideos),
    onChanged: onChanged,
    onValidationError: onValidationError,
    localItemBuilder: localItemBuilder,
    remoteItemBuilder: remoteItemBuilder,
    pickingBuilder: pickingBuilder,
    pickErrorBuilder: pickErrorBuilder,
    sourceOptionBuilder: sourceOptionBuilder,
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
    this.emptyWidth,
    this.emptyHeight,
    this.nonEmptyWidth,
    this.nonEmptyHeight,
    this.alignment,
    this.maxSizeBytes,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onDeleteRequest,
    this.deleteConfirmation,
    this.onPickStarted,
    this.onPickFinished,
    this.onPickerFailure,
    this.validator,
    this.onUploadFile,
    this.onChanged,
    this.onValidationError,
    this.localItemBuilder,
    this.remoteItemBuilder,
    this.pickingBuilder,
    this.pickErrorBuilder,
    this.sourceOptionBuilder,
  });

  final SuperMediaController? controller;
  final T? initialFile;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final double? emptyWidth;
  final double? emptyHeight;
  final double? nonEmptyWidth;
  final double? nonEmptyHeight;
  final AlignmentGeometry? alignment;
  final int? maxSizeBytes;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperMediaDeleteRequest? onDeleteRequest;
  final SuperMediaDeleteConfirmation? deleteConfirmation;
  final VoidCallback? onPickStarted;
  final VoidCallback? onPickFinished;
  final SuperMediaPickerFailure? onPickerFailure;
  final SuperMediaValidator? validator;
  final SuperUploadPath? onUploadFile;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;
  final SuperMediaItemBuilder? localItemBuilder;
  final SuperMediaItemBuilder? remoteItemBuilder;
  final WidgetBuilder? pickingBuilder;
  final SuperMediaPickerErrorBuilder? pickErrorBuilder;
  final SuperMediaSourceOptionBuilder? sourceOptionBuilder;

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
      emptyWidth: emptyWidth,
      emptyHeight: emptyHeight,
      nonEmptyWidth: nonEmptyWidth,
      nonEmptyHeight: nonEmptyHeight,
      alignment: alignment,
      fileMaxSizeBytes: maxSizeBytes,
    ),
    transform: transform,
    addButtonBuilder: addButtonBuilder,
    itemBuilder: itemBuilder,
    onDelete: onDelete,
    onDeleteAll: onDeleteAll,
    onDeleteRequest: onDeleteRequest,
    deleteConfirmation: deleteConfirmation,
    onPickStarted: onPickStarted,
    onPickFinished: onPickFinished,
    onPickerFailure: onPickerFailure,
    validator: validator,
    onPicked: (items) => _onePath(items, onUploadFile),
    onChanged: onChanged,
    onValidationError: onValidationError,
    localItemBuilder: localItemBuilder,
    remoteItemBuilder: remoteItemBuilder,
    pickingBuilder: pickingBuilder,
    pickErrorBuilder: pickErrorBuilder,
    sourceOptionBuilder: sourceOptionBuilder,
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
    this.width,
    this.height,
    this.emptyWidth,
    this.emptyHeight,
    this.nonEmptyWidth,
    this.nonEmptyHeight,
    this.alignment,
    this.maxItems,
    this.maxSizeBytes,
    this.maxTotalSizeBytes,
    this.transform,
    this.addButtonBuilder,
    this.itemBuilder,
    this.onDelete,
    this.onDeleteAll,
    this.onDeleteRequest,
    this.deleteConfirmation,
    this.onPickStarted,
    this.onPickFinished,
    this.onPickerFailure,
    this.onReorder,
    this.validator,
    this.onUploadFiles,
    this.onChanged,
    this.onValidationError,
    this.localItemBuilder,
    this.remoteItemBuilder,
    this.pickingBuilder,
    this.pickErrorBuilder,
    this.sourceOptionBuilder,
  });

  final SuperMediaController? controller;
  final Iterable<T> initialFiles;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final double? emptyWidth;
  final double? emptyHeight;
  final double? nonEmptyWidth;
  final double? nonEmptyHeight;
  final AlignmentGeometry? alignment;
  final int? maxItems;
  final int? maxSizeBytes;
  final int? maxTotalSizeBytes;
  final SuperMediaTransform? transform;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaDelete? onDelete;
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperMediaDeleteRequest? onDeleteRequest;
  final SuperMediaDeleteConfirmation? deleteConfirmation;
  final VoidCallback? onPickStarted;
  final VoidCallback? onPickFinished;
  final SuperMediaPickerFailure? onPickerFailure;
  final SuperMediaReordered? onReorder;
  final SuperMediaValidator? validator;
  final SuperUploadPaths? onUploadFiles;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;
  final SuperMediaItemBuilder? localItemBuilder;
  final SuperMediaItemBuilder? remoteItemBuilder;
  final WidgetBuilder? pickingBuilder;
  final SuperMediaPickerErrorBuilder? pickErrorBuilder;
  final SuperMediaSourceOptionBuilder? sourceOptionBuilder;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItems: initialFiles,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.file},
      multiple: true,
      width: width,
      height: height,
      emptyWidth: emptyWidth,
      emptyHeight: emptyHeight,
      nonEmptyWidth: nonEmptyWidth,
      nonEmptyHeight: nonEmptyHeight,
      alignment: alignment,
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
    onDeleteRequest: onDeleteRequest,
    deleteConfirmation: deleteConfirmation,
    onPickStarted: onPickStarted,
    onPickFinished: onPickFinished,
    onPickerFailure: onPickerFailure,
    onReorder: onReorder,
    validator: validator,
    onPicked: (items) => _manyPaths(items, onUploadFiles),
    onChanged: onChanged,
    onValidationError: onValidationError,
    localItemBuilder: localItemBuilder,
    remoteItemBuilder: remoteItemBuilder,
    pickingBuilder: pickingBuilder,
    pickErrorBuilder: pickErrorBuilder,
    sourceOptionBuilder: sourceOptionBuilder,
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
    this.emptyWidth,
    this.emptyHeight,
    this.nonEmptyWidth,
    this.nonEmptyHeight,
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
    this.onDeleteRequest,
    this.deleteConfirmation,
    this.onPickStarted,
    this.onPickFinished,
    this.onPickerFailure,
    this.validator,
    this.onUploadMedia,
    this.onChanged,
    this.onValidationError,
    this.localItemBuilder,
    this.remoteItemBuilder,
    this.pickingBuilder,
    this.pickErrorBuilder,
    this.sourceOptionBuilder,
  });

  final SuperMediaController? controller;
  final T? initialMedia;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final double? emptyWidth;
  final double? emptyHeight;
  final double? nonEmptyWidth;
  final double? nonEmptyHeight;
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
  final SuperMediaDeleteRequest? onDeleteRequest;
  final SuperMediaDeleteConfirmation? deleteConfirmation;
  final VoidCallback? onPickStarted;
  final VoidCallback? onPickFinished;
  final SuperMediaPickerFailure? onPickerFailure;
  final SuperMediaValidator? validator;
  final SuperUploadPath? onUploadMedia;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;
  final SuperMediaItemBuilder? localItemBuilder;
  final SuperMediaItemBuilder? remoteItemBuilder;
  final WidgetBuilder? pickingBuilder;
  final SuperMediaPickerErrorBuilder? pickErrorBuilder;
  final SuperMediaSourceOptionBuilder? sourceOptionBuilder;

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
      emptyWidth: emptyWidth,
      emptyHeight: emptyHeight,
      nonEmptyWidth: nonEmptyWidth,
      nonEmptyHeight: nonEmptyHeight,
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
    onDeleteRequest: onDeleteRequest,
    deleteConfirmation: deleteConfirmation,
    onPickStarted: onPickStarted,
    onPickFinished: onPickFinished,
    onPickerFailure: onPickerFailure,
    validator: validator,
    onPicked: (items) => _onePath(items, onUploadMedia),
    onChanged: onChanged,
    onValidationError: onValidationError,
    localItemBuilder: localItemBuilder,
    remoteItemBuilder: remoteItemBuilder,
    pickingBuilder: pickingBuilder,
    pickErrorBuilder: pickErrorBuilder,
    sourceOptionBuilder: sourceOptionBuilder,
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
    this.width,
    this.height,
    this.emptyWidth,
    this.emptyHeight,
    this.nonEmptyWidth,
    this.nonEmptyHeight,
    this.alignment,
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
    this.onDeleteRequest,
    this.deleteConfirmation,
    this.onPickStarted,
    this.onPickFinished,
    this.onPickerFailure,
    this.onReorder,
    this.validator,
    this.onUploadMedia,
    this.onChanged,
    this.onValidationError,
    this.localItemBuilder,
    this.remoteItemBuilder,
    this.pickingBuilder,
    this.pickErrorBuilder,
    this.sourceOptionBuilder,
  });

  final SuperMediaController? controller;
  final Iterable<T> initialMedia;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;
  final double? width;
  final double? height;
  final double? emptyWidth;
  final double? emptyHeight;
  final double? nonEmptyWidth;
  final double? nonEmptyHeight;
  final AlignmentGeometry? alignment;
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
  final SuperMediaDeleteRequest? onDeleteRequest;
  final SuperMediaDeleteConfirmation? deleteConfirmation;
  final VoidCallback? onPickStarted;
  final VoidCallback? onPickFinished;
  final SuperMediaPickerFailure? onPickerFailure;
  final SuperMediaReordered? onReorder;
  final SuperMediaValidator? validator;
  final SuperUploadPaths? onUploadMedia;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;
  final SuperMediaItemBuilder? localItemBuilder;
  final SuperMediaItemBuilder? remoteItemBuilder;
  final WidgetBuilder? pickingBuilder;
  final SuperMediaPickerErrorBuilder? pickErrorBuilder;
  final SuperMediaSourceOptionBuilder? sourceOptionBuilder;

  @override
  Widget build(BuildContext context) => SuperMediaPicker<T>(
    controller: controller,
    initialItems: initialMedia,
    initialItemMapper: initialItemMapper,
    config: _scope(
      config,
      const {SuperMediaType.image, SuperMediaType.video},
      multiple: true,
      width: width,
      height: height,
      emptyWidth: emptyWidth,
      emptyHeight: emptyHeight,
      nonEmptyWidth: nonEmptyWidth,
      nonEmptyHeight: nonEmptyHeight,
      alignment: alignment,
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
    onDeleteRequest: onDeleteRequest,
    deleteConfirmation: deleteConfirmation,
    onPickStarted: onPickStarted,
    onPickFinished: onPickFinished,
    onPickerFailure: onPickerFailure,
    onReorder: onReorder,
    validator: validator,
    onPicked: (items) => _manyPaths(items, onUploadMedia),
    onChanged: onChanged,
    onValidationError: onValidationError,
    localItemBuilder: localItemBuilder,
    remoteItemBuilder: remoteItemBuilder,
    pickingBuilder: pickingBuilder,
    pickErrorBuilder: pickErrorBuilder,
    sourceOptionBuilder: sourceOptionBuilder,
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
  double? emptyWidth,
  double? emptyHeight,
  double? nonEmptyWidth,
  double? nonEmptyHeight,
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
    confirmDelete: config.confirmDelete,
    sourcePresentation: config.sourcePresentation,
    directSource: config.directSource,
    directType: config.directType,
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
      emptyWidth: emptyWidth ?? config.itemFrame.emptyWidth,
      emptyHeight: emptyHeight ?? config.itemFrame.emptyHeight,
      nonEmptyWidth: nonEmptyWidth ?? config.itemFrame.nonEmptyWidth,
      nonEmptyHeight: nonEmptyHeight ?? config.itemFrame.nonEmptyHeight,
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
