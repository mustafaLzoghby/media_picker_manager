import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image_picker/image_picker.dart';

import '../config/super_media_picker_config.dart';
import '../enums/media_enums.dart';
import '../models/super_media_item.dart';

typedef SuperMediaTransform =
    Future<SuperMediaItem> Function(SuperMediaItem item);

class SuperMediaPickerService {
  SuperMediaPickerService({ImagePicker? imagePicker})
    : _imagePicker = imagePicker ?? ImagePicker();

  final ImagePicker _imagePicker;

  Future<List<SuperMediaItem>> pick({
    required SuperMediaType type,
    required SuperMediaSource source,
    required SuperMediaPickerConfig config,
    SuperMediaTransform? transform,
  }) async {
    List<SuperMediaItem> items;
    if (type == SuperMediaType.file || source == SuperMediaSource.files) {
      items = await _pickFiles(config, requestedType: type);
    } else if (type == SuperMediaType.image) {
      items = await _pickImages(source, config);
    } else {
      items = await _pickVideos(source, config);
    }
    if (transform != null) {
      final result = <SuperMediaItem>[];
      for (final item in items) {
        result.add(await transform(item));
      }
      return result;
    }
    return items;
  }

  Future<List<SuperMediaItem>> _pickImages(
    SuperMediaSource source,
    SuperMediaPickerConfig config,
  ) async {
    final imageQuality =
        config.image.preset == SuperMediaImageQuality.original
            ? null
            : config.image.quality;
    if (source == SuperMediaSource.camera) {
      final x = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: imageQuality,
        maxWidth: config.image.maxWidth?.toDouble(),
        maxHeight: config.image.maxHeight?.toDouble(),
      );
      return x == null ? [] : [await _fromXFile(x, SuperMediaType.image)];
    }
    if (config.allowsMultipleFor(SuperMediaType.image)) {
      final xs = await _imagePicker.pickMultiImage(
        imageQuality: imageQuality,
        maxWidth: config.image.maxWidth?.toDouble(),
        maxHeight: config.image.maxHeight?.toDouble(),
      );
      return Future.wait(xs.map((x) => _fromXFile(x, SuperMediaType.image)));
    }
    final x = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: imageQuality,
      maxWidth: config.image.maxWidth?.toDouble(),
      maxHeight: config.image.maxHeight?.toDouble(),
    );
    return x == null ? [] : [await _fromXFile(x, SuperMediaType.image)];
  }

  Future<List<SuperMediaItem>> _pickVideos(
    SuperMediaSource source,
    SuperMediaPickerConfig config,
  ) async {
    if (source == SuperMediaSource.camera) {
      final x = await _imagePicker.pickVideo(
        source: ImageSource.camera,
        maxDuration: config.video.maxDuration,
      );
      return x == null ? [] : [await _fromXFile(x, SuperMediaType.video)];
    }
    if (config.allowsMultipleFor(SuperMediaType.video)) {
      final xs = await _imagePicker.pickMultiVideo(
        maxDuration: config.video.maxDuration,
      );
      return Future.wait(xs.map((x) => _fromXFile(x, SuperMediaType.video)));
    }
    final x = await _imagePicker.pickVideo(
      source: ImageSource.gallery,
      maxDuration: config.video.maxDuration,
    );
    return x == null ? [] : [await _fromXFile(x, SuperMediaType.video)];
  }

  Future<List<SuperMediaItem>> _pickFiles(
    SuperMediaPickerConfig config, {
    required SuperMediaType requestedType,
  }) async {
    FileType fileType = FileType.any;
    List<String>? extensions;
    if (requestedType == SuperMediaType.image) fileType = FileType.image;
    if (requestedType == SuperMediaType.video) fileType = FileType.video;
    if (requestedType == SuperMediaType.file &&
        config.file.allowedExtensions.isNotEmpty) {
      fileType = FileType.custom;
      extensions =
          config.file.allowedExtensions
              .map((e) => e.replaceFirst('.', ''))
              .toList();
    }
    final result = await FilePicker.pickFiles(
      allowMultiple: config.allowsMultipleFor(requestedType),
      type: fileType,
      allowedExtensions: extensions,
    );
    if (result == null) return [];
    return result.files
        .where((f) => f.path != null)
        .map((f) {
          return SuperMediaItem.local(
            id: _id(),
            path: f.path!,
            name: f.name,
            type: requestedType,
            sizeBytes: f.size,
          );
        })
        .toList(growable: false);
  }

  Future<SuperMediaItem> _fromXFile(XFile x, SuperMediaType type) async {
    final size = await x.length();
    return SuperMediaItem.local(
      id: _id(),
      path: x.path,
      name: x.name.isEmpty ? File(x.path).uri.pathSegments.last : x.name,
      type: type,
      sizeBytes: size,
    );
  }

  String _id() =>
      '${DateTime.now().microsecondsSinceEpoch}_${Object().hashCode}';
}
