import 'package:flutter_test/flutter_test.dart';
import 'package:media_picker_manager/media_picker_manager.dart';

class _JsonApiMedia {
  const _JsonApiMedia(this.id, this.url);

  final String id;
  final String url;

  Map<String, Object?> toJson() => {
    'media_id': id,
    'video_url': url,
    'mime_type': 'video/mp4',
    'file_size': 2048,
  };
}

class _OpaqueApiMedia {
  const _OpaqueApiMedia(this.url);

  final String url;
}

void main() {
  test('initial items accept URL strings and API maps', () {
    final controller = SuperMediaController(
      initialItems: [
        'https://example.com/photo.jpg',
        {
          'id': 'video-api',
          'url': 'https://example.com/media/42',
          'type': 'video',
          'size': 1200,
          'thumbnailUrl': 'https://example.com/thumb.jpg',
        },
      ],
    );

    expect(controller.items.first.name, 'photo.jpg');
    expect(controller.items.first.type, SuperMediaType.image);
    expect(controller.items.last.id, 'video-api');
    expect(controller.items.last.type, SuperMediaType.video);
    expect(controller.items.last.sizeBytes, 1200);
    expect(controller.items.last.thumbnailUrl, 'https://example.com/thumb.jpg');
  });

  test('initial item accepts one string or one API object', () {
    final fromString = SuperMediaController(
      initialItem: 'https://example.com/single.jpg',
    );
    final fromMap = SuperMediaController(
      initialItem: {
        'id': 'single-video',
        'url': 'https://example.com/media/1',
        'type': 'video',
      },
    );

    expect(fromString.items.single.name, 'single.jpg');
    expect(fromString.items.single.type, SuperMediaType.image);
    expect(fromMap.items.single.id, 'single-video');
    expect(fromMap.items.single.type, SuperMediaType.video);
  });

  test('initial item and initial items combine without duplicate IDs', () {
    final shared = SuperMediaItem.remote(
      id: 'shared',
      url: 'https://example.com/shared.jpg',
    );
    final controller = SuperMediaController(
      initialItem: shared,
      initialItems: [shared, 'https://example.com/another.jpg'],
    );

    expect(controller.items.length, 2);
  });

  test('URI values are normalized automatically', () {
    final controller = SuperMediaController(
      initialItems: [Uri.parse('https://example.com/custom.jpg')],
    );

    expect(controller.items.single.url, 'https://example.com/custom.jpg');
    expect(controller.items.single.type, SuperMediaType.image);
  });

  test('maps accept common API key styles', () {
    final controller = SuperMediaController(
      initialItem: {
        'media_id': 'api-9',
        'image_url': 'https://example.com/extensionless',
        'file_size': 4096,
      },
    );

    expect(controller.items.single.id, 'api-9');
    expect(controller.items.single.type, SuperMediaType.image);
    expect(controller.items.single.sizeBytes, 4096);
  });

  test('custom objects with toJson are normalized automatically', () {
    final controller = SuperMediaController(
      initialItem: const _JsonApiMedia(
        'json-video',
        'https://example.com/media/9',
      ),
    );

    expect(controller.items.single.id, 'json-video');
    expect(controller.items.single.type, SuperMediaType.video);
    expect(controller.items.single.sizeBytes, 2048);
    expect(controller.items.single.data, isA<_JsonApiMedia>());
  });

  test('initial item mapper supports opaque custom object lists', () {
    final controller = SuperMediaController(
      initialItems: const [_OpaqueApiMedia('https://example.com/custom.jpg')],
      initialItemMapper: (value, index) {
        return SuperMediaItem.remote(id: 'custom-$index', url: value.url);
      },
    );

    expect(controller.items.single.id, 'custom-0');
    expect(controller.items.single.type, SuperMediaType.image);
  });

  test('local and remote factories infer optional name and type', () {
    final remote = SuperMediaItem.remote(
      id: 'remote',
      url: 'https://example.com/uploads/photo.jpg?token=abc',
    );
    final local = SuperMediaItem.local(id: 'local', path: '/tmp/movie.mp4');

    expect(remote.name, 'photo.jpg');
    expect(remote.type, SuperMediaType.image);
    expect(remote.sizeBytes, isNull);
    expect(local.name, 'movie.mp4');
    expect(local.type, SuperMediaType.video);
  });

  test('result exposes upload-ready paths separated by type', () {
    final result = SuperMediaResult(
      items: [
        SuperMediaItem.local(id: 'image', path: '/tmp/image.jpg'),
        SuperMediaItem.local(id: 'video', path: '/tmp/video.mp4'),
        SuperMediaItem.local(id: 'file', path: '/tmp/document.pdf'),
        SuperMediaItem.remote(id: 'remote', url: 'https://example.com/old.jpg'),
      ],
      removedItems: const [],
    );

    expect(result.addedImagePaths, ['/tmp/image.jpg']);
    expect(result.addedVideoPaths, ['/tmp/video.mp4']);
    expect(result.addedFilePaths, ['/tmp/document.pdf']);
    expect(result.addedMediaPaths, [
      '/tmp/image.jpg',
      '/tmp/video.mp4',
      '/tmp/document.pdf',
    ]);
  });

  test('extensionless remote APIs default to an image named by ID', () {
    final remote = SuperMediaItem.remote(
      id: 'api-2',
      url: 'https://picsum.photos/id/1062/600/600',
    );

    expect(remote.name, 'api-2');
    expect(remote.type, SuperMediaType.image);
    expect(remote.sizeBytes, isNull);
  });

  test('delete by ID and delete all track remote endpoint IDs', () {
    final first = SuperMediaItem.remote(
      id: 'api-1',
      url: 'https://example.com/1',
    );
    final second = SuperMediaItem.remote(
      id: 'api-2',
      url: 'https://example.com/2',
    );
    final local = SuperMediaItem.local(id: 'local', path: '/local.jpg');
    final controller = SuperMediaController(
      initialItems: [first, second, local],
    );

    expect(controller.deleteItemById('api-1'), isTrue);
    expect(controller.deleteItemById('missing'), isFalse);
    expect(controller.result.removedItemIds, ['api-1']);

    final deleteAllIds = controller.deleteAllItems();
    expect(controller.items, isEmpty);
    expect(deleteAllIds, ['api-2']);
    expect(controller.result.removedItemIds, ['api-1', 'api-2']);
  });

  test('per-type multiple selection overrides the global default', () {
    const config = SuperMediaPickerConfig(
      allowMultiple: true,
      image: SuperImageConfig(allowMultiple: true),
      video: SuperVideoConfig(allowMultiple: false),
      file: SuperFileConfig(allowMultiple: false),
    );

    expect(config.allowsMultipleFor(SuperMediaType.image), isTrue);
    expect(config.allowsMultipleFor(SuperMediaType.video), isFalse);
    expect(config.allowsMultipleFor(SuperMediaType.file), isFalse);
  });

  test('remote removals are tracked and local additions are reported', () {
    final remote = SuperMediaItem.remote(
      id: '1',
      url: 'https://example.com/a.jpg',
      name: 'a.jpg',
      type: SuperMediaType.image,
    );
    final controller = SuperMediaController(initialItems: [remote]);
    const config = SuperMediaPickerConfig();
    final local = SuperMediaItem.local(
      id: '2',
      path: '/tmp/b.jpg',
      name: 'b.jpg',
      type: SuperMediaType.image,
      sizeBytes: 100,
    );

    expect(controller.add(local, config: config), isNull);
    controller.remove(remote);

    expect(controller.result.addedItems, contains(local));
    expect(controller.result.removedItems.single.id, '1');
  });

  test('max item limit returns validation error', () {
    final controller = SuperMediaController();
    const config = SuperMediaPickerConfig(
      limits: SuperMediaLimits(maxItems: 1),
    );
    controller.add(
      SuperMediaItem.local(
        id: '1',
        path: '/a',
        name: 'a.jpg',
        type: SuperMediaType.image,
      ),
      config: config,
    );
    final error = controller.add(
      SuperMediaItem.local(
        id: '2',
        path: '/b',
        name: 'b.jpg',
        type: SuperMediaType.image,
      ),
      config: config,
    );
    expect(error?.code, 'max_items');
  });

  test(
    'single selection replaces an existing item despite collection limits',
    () {
      final remote = SuperMediaItem.remote(
        id: 'remote',
        url: 'https://example.com/a.jpg',
        name: 'a.jpg',
        type: SuperMediaType.image,
        sizeBytes: 100,
      );
      final local = SuperMediaItem.local(
        id: 'local',
        path: '/b.jpg',
        name: 'b.jpg',
        type: SuperMediaType.image,
        sizeBytes: 100,
      );
      final controller = SuperMediaController(initialItems: [remote]);
      const config = SuperMediaPickerConfig(
        allowMultiple: false,
        limits: SuperMediaLimits(
          maxItems: 1,
          maxImages: 1,
          maxTotalSizeBytes: 100,
        ),
      );

      expect(controller.add(local, config: config), isNull);
      expect(controller.items, [local]);
      expect(controller.removedItems.single.id, remote.id);
    },
  );

  test('upload lifecycle does not remove local items from addedItems', () {
    final local = SuperMediaItem.local(
      id: 'local',
      path: '/a.jpg',
      name: 'a.jpg',
      type: SuperMediaType.image,
    );
    final controller = SuperMediaController(initialItems: [local]);

    controller.setUploadProgress(local.id, 0.5);
    expect(controller.result.addedItems.single.id, local.id);

    controller.markUploaded(local.id);
    expect(controller.result.addedItems.single.id, local.id);
  });
}
