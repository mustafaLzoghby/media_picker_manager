import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../config/super_media_picker_config.dart';
import '../controllers/super_media_controller.dart';
import '../enums/media_enums.dart';
import '../extensions/byte_size_extension.dart';
import '../models/super_media_item.dart';
import '../models/super_media_result.dart';
import '../models/super_media_validation_error.dart';
import '../services/super_media_picker_service.dart';
import 'super_media_preview.dart';

typedef SuperMediaChanged = void Function(SuperMediaResult result);
typedef SuperMediaPicked = void Function(List<SuperMediaItem> items);
typedef SuperMediaDelete = void Function(String id);
typedef SuperMediaDeleteAll = void Function(List<String> ids);
typedef SuperMediaError = void Function(SuperMediaValidationError error);
typedef SuperMediaItemBuilder =
    Widget Function(
      BuildContext context,
      SuperMediaItem item,
      int index,
      VoidCallback remove,
    );

typedef SuperMediaAddButtonBuilder =
    Widget Function(BuildContext context, VoidCallback openPicker);
typedef SuperMediaContainerBuilder =
    Widget Function(BuildContext context, Widget child);
typedef SuperMediaPreviewBuilder =
    Widget Function(BuildContext context, SuperMediaItem item);
typedef SuperMediaItemFrameBuilder =
    Widget Function(
      BuildContext context,
      SuperMediaItem item,
      int index,
      Widget child,
    );

class SuperMediaPicker<T extends Object> extends StatefulWidget {
  const SuperMediaPicker({
    super.key,
    this.controller,
    this.initialItem,
    this.initialItems = const [],
    this.initialItemMapper,
    this.config = const SuperMediaPickerConfig(),
    this.onPicked,
    this.onDelete,
    this.onDeleteAll,
    this.onChanged,
    this.onValidationError,
    this.transform,
    this.itemBuilder,
    this.addButtonBuilder,
    this.emptyBuilder,
    this.containerBuilder,
    this.previewBuilder,
    this.itemFrameBuilder,
  });

  final SuperMediaController? controller;
  final T? initialItem;
  final Iterable<T> initialItems;
  final SuperMediaValueMapper<T>? initialItemMapper;
  final SuperMediaPickerConfig config;

  /// Called once for each successful picker action with only the new items.
  final SuperMediaPicked? onPicked;

  /// Called when a remote/initial item is removed, with its API ID.
  final SuperMediaDelete? onDelete;

  /// Called when multiple remote/initial items are removed in one operation.
  final SuperMediaDeleteAll? onDeleteAll;
  final SuperMediaChanged? onChanged;
  final SuperMediaError? onValidationError;
  final SuperMediaTransform? transform;
  final SuperMediaItemBuilder? itemBuilder;
  final SuperMediaAddButtonBuilder? addButtonBuilder;
  final WidgetBuilder? emptyBuilder;
  final SuperMediaContainerBuilder? containerBuilder;
  final SuperMediaPreviewBuilder? previewBuilder;
  final SuperMediaItemFrameBuilder? itemFrameBuilder;

  @override
  State<SuperMediaPicker<T>> createState() => _SuperMediaPickerState<T>();
}

class _SuperMediaPickerState<T extends Object>
    extends State<SuperMediaPicker<T>>
    with AutomaticKeepAliveClientMixin<SuperMediaPicker<T>> {
  late SuperMediaController _controller;
  late bool _ownsController;
  final _service = SuperMediaPickerService();
  final Set<String> _knownRemovedIds = {};

  @override
  void initState() {
    super.initState();
    _ownsController = widget.controller == null;
    _controller =
        widget.controller ??
        SuperMediaController<T>(
          initialItem: widget.initialItem,
          initialItems: widget.initialItems,
          initialItemMapper: _mapper(widget),
        );
    if (widget.controller != null &&
        (widget.initialItem != null || widget.initialItems.isNotEmpty) &&
        _controller.items.isEmpty) {
      _controller.setItems(_initialItems(widget));
    }
    _knownRemovedIds.addAll(_controller.result.removedItemIds);
    _controller.addListener(_changed);
  }

  @override
  void didUpdateWidget(covariant SuperMediaPicker<T> oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config.keepAlive != widget.config.keepAlive) {
      updateKeepAlive();
    }
    if (oldWidget.initialItem != widget.initialItem ||
        !listEquals(
          oldWidget.initialItems.toList(),
          widget.initialItems.toList(),
        ) ||
        oldWidget.initialItemMapper != widget.initialItemMapper) {
      _mergeNewInitialItems(_initialItems(oldWidget), _initialItems(widget));
    }
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?.removeListener(_changed);
      if (_ownsController) _controller.dispose();
      _ownsController = widget.controller == null;
      _controller =
          widget.controller ??
          SuperMediaController<T>(
            initialItem: widget.initialItem,
            initialItems: widget.initialItems,
            initialItemMapper: _mapper(widget),
          );
      _knownRemovedIds
        ..clear()
        ..addAll(_controller.result.removedItemIds);
      _controller.addListener(_changed);
    }
  }

  void _changed() {
    if (mounted) setState(() {});
    final result = _controller.result;
    final removedIds = result.removedItemIds.toSet();
    final newlyRemoved = removedIds.difference(_knownRemovedIds).toList();
    _knownRemovedIds
      ..retainAll(removedIds)
      ..addAll(newlyRemoved);
    if (newlyRemoved.length == 1) {
      widget.onDelete?.call(newlyRemoved.single);
    } else if (newlyRemoved.length > 1) {
      widget.onDeleteAll?.call(List.unmodifiable(newlyRemoved));
    }
    widget.onChanged?.call(result);
  }

  void _mergeNewInitialItems(
    List<SuperMediaItem> oldItems,
    List<SuperMediaItem> newItems,
  ) {
    final previousIds = oldItems.map((item) => item.id).toSet();
    final visibleIds = _controller.items.map((item) => item.id).toSet();
    final additions = newItems.where(
      (item) => !previousIds.contains(item.id) && !visibleIds.contains(item.id),
    );
    if (additions.isEmpty) return;
    _controller.setItems(
      [..._controller.items, ...additions],
      resetRemoved: false,
      notify: false,
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) widget.onChanged?.call(_controller.result);
    });
  }

  List<SuperMediaItem> _initialItems(SuperMediaPicker<T> picker) {
    return SuperMediaItem.fromInitialValues(
      item: picker.initialItem,
      items: picker.initialItems,
      mapper: _mapper(picker),
    );
  }

  SuperMediaValueMapper<T>? _mapper(SuperMediaPicker<T> picker) =>
      picker.initialItemMapper;

  @override
  void dispose() {
    _controller.removeListener(_changed);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  bool get _canAdd {
    final max = widget.config.limits.maxItems;
    return max == null || _controller.items.length < max;
  }

  Future<void> _openPicker() async {
    final options = <_PickerOption>[];
    final c = widget.config;
    final text = _text(context);
    if (c.allowedTypes.contains(SuperMediaType.image)) {
      if (c.sources.contains(SuperMediaSource.gallery)) {
        options.add(
          _PickerOption(
            text.images,
            c.icons.images ?? const Icon(Icons.image_outlined),
            SuperMediaType.image,
            SuperMediaSource.gallery,
          ),
        );
      }
      if (c.sources.contains(SuperMediaSource.camera)) {
        options.add(
          _PickerOption(
            text.takePhoto,
            c.icons.takePhoto ?? const Icon(Icons.photo_camera_outlined),
            SuperMediaType.image,
            SuperMediaSource.camera,
          ),
        );
      }
    }
    if (c.allowedTypes.contains(SuperMediaType.video)) {
      if (c.sources.contains(SuperMediaSource.gallery)) {
        options.add(
          _PickerOption(
            text.videos,
            c.icons.videos ?? const Icon(Icons.videocam_outlined),
            SuperMediaType.video,
            SuperMediaSource.gallery,
          ),
        );
      }
      if (c.sources.contains(SuperMediaSource.camera)) {
        options.add(
          _PickerOption(
            text.recordVideo,
            c.icons.recordVideo ?? const Icon(Icons.video_camera_back_outlined),
            SuperMediaType.video,
            SuperMediaSource.camera,
          ),
        );
      }
    }
    if (c.allowedTypes.contains(SuperMediaType.file) &&
        c.sources.contains(SuperMediaSource.files)) {
      options.add(
        _PickerOption(
          text.files,
          c.icons.files ?? const Icon(Icons.attach_file),
          SuperMediaType.file,
          SuperMediaSource.files,
        ),
      );
    }

    if (!mounted || options.isEmpty) return;
    final selected = await showModalBottomSheet<_PickerOption>(
      context: context,
      showDragHandle: true,
      builder:
          (context) => Directionality(
            textDirection: _textDirection(context),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final option in options)
                    ListTile(
                      leading: option.icon,
                      title: Text(option.label),
                      onTap: () => Navigator.pop(context, option),
                    ),
                ],
              ),
            ),
          ),
    );
    if (selected == null) return;

    final picked = await _service.pick(
      type: selected.type,
      source: selected.source,
      config: c,
      transform: widget.transform,
    );
    final previousIds = _controller.items.map((item) => item.id).toSet();
    final errors = _controller.addAll(picked, config: c);
    final accepted = picked
        .where(
          (item) =>
              !previousIds.contains(item.id) &&
              _controller.items.any((current) => current.id == item.id),
        )
        .toList(growable: false);
    if (accepted.isNotEmpty) widget.onPicked?.call(accepted);
    for (final error in errors) {
      widget.onValidationError?.call(error);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final frame = widget.config.frame;
    final content = Container(
      width: frame.width,
      height: frame.height,
      constraints: frame.constraints,
      margin: frame.margin,
      padding: frame.padding,
      alignment: frame.alignment,
      decoration: frame.decoration,
      foregroundDecoration: frame.foregroundDecoration,
      clipBehavior: frame.clipBehavior,
      child: _buildContent(context),
    );
    final localizedContent = Directionality(
      textDirection: _textDirection(context),
      child: content,
    );
    return widget.containerBuilder?.call(context, localizedContent) ??
        localizedContent;
  }

  @override
  bool get wantKeepAlive => widget.config.keepAlive;

  Widget _buildContent(BuildContext context) {
    final items = _controller.items;

    if (widget.config.layout == SuperMediaLayout.list) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (items.isEmpty && widget.emptyBuilder != null)
            widget.emptyBuilder!(context),
          for (var i = 0; i < items.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: widget.config.spacing),
              child: SizedBox(
                height:
                    widget.config.itemFrame.height ??
                    widget.config.listItemHeight,
                child: _applyItemFrame(_buildItemWithReorder(items[i], i)),
              ),
            ),
          if (_canAdd)
            SizedBox(
              height:
                  widget.config.itemFrame.height ??
                  widget.config.listItemHeight,
              child: _applyItemFrame(_buildAddButton()),
            ),
        ],
      );
    }

    final count = items.length + (_canAdd ? 1 : 0);
    final grid = GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: count,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: widget.config.crossAxisCount,
        crossAxisSpacing: widget.config.spacing,
        mainAxisSpacing: widget.config.spacing,
        childAspectRatio: widget.config.gridItemAspectRatio,
        mainAxisExtent:
            widget.config.itemFrame.height ?? widget.config.gridItemHeight,
      ),
      itemBuilder: (context, index) {
        if (index == items.length) {
          return _applyItemFrame(_buildAddButton());
        }
        return _applyItemFrame(_buildItemWithReorder(items[index], index));
      },
    );
    if (items.isEmpty && widget.emptyBuilder != null) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          widget.emptyBuilder!(context),
          if (_canAdd) SizedBox(height: widget.config.spacing),
          grid,
        ],
      );
    }
    return grid;
  }

  Widget _buildAddButton() {
    if (widget.addButtonBuilder != null) {
      return widget.addButtonBuilder!(context, _openPicker);
    }
    return InkWell(
      onTap: _openPicker,
      borderRadius: BorderRadius.circular(widget.config.borderRadius),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.config.borderRadius),
          border: Border.all(
            color: Theme.of(context).colorScheme.outlineVariant,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              widget.config.icons.addMedia ??
                  const Icon(Icons.add_rounded, size: 34),
              const SizedBox(height: 4),
              Text(_text(context).addMedia),
            ],
          ),
        ),
      ),
    );
  }

  Widget _applyItemFrame(Widget child) {
    final frame = widget.config.itemFrame;
    if (frame.width == null && frame.height == null) return child;
    return Align(
      alignment: frame.alignment,
      child: SizedBox(width: frame.width, height: frame.height, child: child),
    );
  }

  Widget _buildItem(SuperMediaItem item, int index) {
    void remove() => _controller.remove(item);
    if (widget.itemBuilder != null) {
      return widget.itemBuilder!(context, item, index, remove);
    }
    final defaultTile = _DefaultMediaTile(
      item: item,
      config: widget.config,
      text: _text(context),
      onRemove: remove,
      showReorderHandle:
          widget.config.enableReorder &&
          widget.config.showReorderHandle &&
          _controller.items.length > 1,
      onPreview:
          widget.config.enablePreview && item.type != SuperMediaType.file
              ? () => _openPreview(item)
              : null,
    );
    return widget.itemFrameBuilder?.call(context, item, index, defaultTile) ??
        defaultTile;
  }

  void _openPreview(SuperMediaItem item) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (context) =>
                widget.previewBuilder?.call(context, item) ??
                SuperMediaPreview(
                  item: item,
                  text: _text(context),
                  locale: _locale(context),
                  textDirection: _textDirection(context),
                ),
      ),
    );
  }

  SuperMediaTextConfig _text(BuildContext context) {
    return widget.config.resolveText(_locale(context));
  }

  Locale _locale(BuildContext context) {
    return widget.config.locale ?? View.of(context).platformDispatcher.locale;
  }

  TextDirection _textDirection(BuildContext context) {
    if (widget.config.textDirection != null) {
      return widget.config.textDirection!;
    }
    const rtlLanguages = {'ar', 'fa', 'he', 'ur'};
    return rtlLanguages.contains(_locale(context).languageCode.toLowerCase())
        ? TextDirection.rtl
        : TextDirection.ltr;
  }

  Widget _buildItemWithReorder(SuperMediaItem item, int index) {
    final child = _buildItem(item, index);
    if (!widget.config.enableReorder || _controller.items.length < 2) {
      return child;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final feedbackWidth =
            constraints.hasBoundedWidth
                ? constraints.maxWidth
                : MediaQuery.sizeOf(context).width;
        return DragTarget<int>(
          onWillAcceptWithDetails: (details) => details.data != index,
          onAcceptWithDetails: (details) {
            final oldIndex = details.data;
            final newIndex = oldIndex < index ? index + 1 : index;
            _controller.reorder(oldIndex, newIndex);
          },
          builder:
              (context, candidates, rejected) => LongPressDraggable<int>(
                data: index,
                feedback: Material(
                  elevation: 6,
                  borderRadius: BorderRadius.circular(
                    widget.config.borderRadius,
                  ),
                  child: SizedBox(
                    width: feedbackWidth,
                    height:
                        constraints.hasBoundedHeight
                            ? constraints.maxHeight
                            : null,
                    child: _buildItem(item, index),
                  ),
                ),
                childWhenDragging: Opacity(opacity: 0.35, child: child),
                child: AnimatedScale(
                  scale: candidates.isEmpty ? 1 : 0.96,
                  duration: const Duration(milliseconds: 120),
                  child: child,
                ),
              ),
        );
      },
    );
  }
}

class _DefaultMediaTile extends StatelessWidget {
  const _DefaultMediaTile({
    required this.item,
    required this.config,
    required this.text,
    required this.onRemove,
    required this.showReorderHandle,
    this.onPreview,
  });
  final SuperMediaItem item;
  final SuperMediaPickerConfig config;
  final SuperMediaTextConfig text;
  final VoidCallback onRemove;
  final bool showReorderHandle;
  final VoidCallback? onPreview;

  @override
  Widget build(BuildContext context) {
    final showName =
        item.isRemote
            ? config.showRemoteFileName ?? config.showFileName
            : config.showLocalFileName ?? config.showFileName;
    final showSize =
        item.isRemote
            ? config.showRemoteFileSize ?? config.showFileSize
            : config.showLocalFileSize ?? config.showFileSize;
    return Semantics(
      button: onPreview != null,
      label: onPreview == null ? null : 'Preview ${item.name}',
      child: GestureDetector(
        onTap: onPreview,
        child: ClipRRect(
          borderRadius: BorderRadius.circular(config.borderRadius),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: _content(context),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(6),
                  color: Colors.black54,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showName)
                        Text(
                          item.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                          ),
                        ),
                      if (showSize)
                        Text(
                          formatBytes(
                            item.sizeBytes,
                            unknownLabel: text.unknownSize,
                          ),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                      if (item.status == SuperMediaItemStatus.uploading)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: LinearProgressIndicator(
                            value: item.uploadProgress,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              if (config.showRemoveButton)
                PositionedDirectional(
                  top: 5,
                  end: 5,
                  child: Material(
                    color: Colors.black54,
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: onRemove,
                      child: Padding(
                        padding: const EdgeInsets.all(5),
                        child:
                            config.icons.remove ??
                            const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 17,
                            ),
                      ),
                    ),
                  ),
                ),
              if (item.isRemote && config.showRemoteBadge)
                PositionedDirectional(
                  top: 6,
                  start: 6,
                  child: DecoratedBox(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.all(Radius.circular(12)),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 3,
                      ),
                      child: Text(
                        text.remoteBadge,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              if (showReorderHandle)
                Align(
                  alignment: Alignment.topCenter,
                  child: IgnorePointer(
                    child: Container(
                      margin: const EdgeInsets.only(top: 5),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 4,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.black54,
                        borderRadius: BorderRadius.all(Radius.circular(12)),
                      ),
                      child:
                          config.icons.reorder ??
                          const Icon(
                            Icons.drag_indicator_rounded,
                            color: Colors.white,
                            size: 17,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _content(BuildContext context) {
    if (item.type == SuperMediaType.image) {
      if (item.url != null) {
        return Image.network(
          item.url!,
          fit: BoxFit.cover,
          errorBuilder:
              (_, _, _) => _fallback(
                config.icons.brokenImage ??
                    const Icon(Icons.broken_image_outlined, size: 36),
              ),
        );
      }
      if (item.path != null) {
        return Image.file(
          File(item.path!),
          fit: BoxFit.cover,
          errorBuilder:
              (_, _, _) => _fallback(
                config.icons.brokenImage ??
                    const Icon(Icons.broken_image_outlined, size: 36),
              ),
        );
      }
    }
    if (item.type == SuperMediaType.video) {
      if (item.thumbnailUrl != null) {
        return Image.network(
          item.thumbnailUrl!,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _videoFallback(),
        );
      }
      if (item.thumbnailPath != null) {
        return Image.file(
          File(item.thumbnailPath!),
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => _videoFallback(),
        );
      }
      return _VideoThumbnail(item: item, fallback: _videoFallback());
    }
    return _fallback(
      config.icons.filePlaceholder ??
          const Icon(Icons.insert_drive_file_outlined, size: 42),
    );
  }

  Widget _fallback(Widget icon) => Center(child: icon);

  Widget _videoFallback() => _fallback(
    config.icons.videoPlaceholder ??
        const Icon(Icons.play_circle_fill_rounded, size: 46),
  );
}

class _VideoThumbnail extends StatefulWidget {
  const _VideoThumbnail({required this.item, required this.fallback});

  final SuperMediaItem item;
  final Widget fallback;

  @override
  State<_VideoThumbnail> createState() => _VideoThumbnailState();
}

class _VideoThumbnailState extends State<_VideoThumbnail> {
  late final VideoPlayerController _controller;
  bool _ready = false;

  @override
  void initState() {
    super.initState();
    _controller = videoControllerFor(widget.item);
    _controller
        .initialize()
        .then((_) {
          if (mounted) setState(() => _ready = true);
        })
        .catchError((_) {});
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_ready || _controller.value.size.isEmpty) return widget.fallback;
    final size = _controller.value.size;
    return FittedBox(
      fit: BoxFit.cover,
      clipBehavior: Clip.hardEdge,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(_controller),
      ),
    );
  }
}

class _PickerOption {
  const _PickerOption(this.label, this.icon, this.type, this.source);
  final String label;
  final Widget icon;
  final SuperMediaType type;
  final SuperMediaSource source;
}
