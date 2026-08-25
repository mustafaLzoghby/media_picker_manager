import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_picker_manager/media_picker_manager.dart';

class _ImageModel {
  const _ImageModel(this.id, this.url);

  final int id;
  final String url;
}

void main() {
  testWidgets('delete callbacks separate one remote ID from delete all IDs', (
    tester,
  ) async {
    String? deletedId;
    List<String>? deletedIds;
    final controller = SuperMediaController(
      initialItems: [
        SuperMediaItem.remote(id: 'api-1', url: 'https://example.com/one.jpg'),
        SuperMediaItem.remote(id: 'api-2', url: 'https://example.com/two.jpg'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperImagesPicker(
            controller: controller,
            onDelete: (id) => deletedId = id,
            onDeleteAll: (ids) => deletedIds = ids,
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close).first);
    await tester.pump();
    expect(deletedId, 'api-1');
    expect(deletedIds, isNull);

    controller.restoreRemote(controller.removedItems.single);
    controller.deleteAllItems();
    expect(deletedIds, containsAll(<String>['api-1', 'api-2']));
    controller.dispose();
  });

  testWidgets(
    'single picker supports full width, height, and start alignment',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SuperImagePicker(
              width: double.infinity,
              height: 180,
              alignment: AlignmentDirectional.centerStart,
            ),
          ),
        ),
      );

      final inner = tester.widget<SuperMediaPicker>(
        find.byType(SuperMediaPicker),
      );
      expect(inner.config.crossAxisCount, 1);
      expect(inner.config.itemFrame.width, double.infinity);
      expect(inner.config.itemFrame.height, 180);
      expect(
        inner.config.itemFrame.alignment,
        AlignmentDirectional.centerStart,
      );
    },
  );

  testWidgets('any typed model list uses a typed mapper without casts', (
    tester,
  ) async {
    const images = <_ImageModel>[
      _ImageModel(1, 'https://example.com/one.jpg'),
      _ImageModel(2, 'https://example.com/two.jpg'),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperImagesPicker<_ImageModel>(
            initialImages: images,
            initialItemMapper:
                (image, index) => SuperMediaItem.remote(
                  id: image.id.toString(),
                  url: image.url,
                ),
          ),
        ),
      ),
    );

    expect(find.text('one.jpg'), findsOneWidget);
    expect(find.text('two.jpg'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('every simple picker scopes media type and multiplicity', (
    tester,
  ) async {
    Future<void> expectScope(
      Widget picker,
      Set<SuperMediaType> types,
      bool multiple,
    ) async {
      await tester.pumpWidget(MaterialApp(home: Scaffold(body: picker)));
      final inner = tester.widget<SuperMediaPicker>(
        find.byType(SuperMediaPicker),
      );
      expect(inner.config.allowedTypes, types);
      expect(inner.config.allowMultiple, multiple);
    }

    await expectScope(const SuperImagePicker(), {SuperMediaType.image}, false);
    await expectScope(const SuperImagesPicker(), {SuperMediaType.image}, true);
    await expectScope(const SuperVideoPicker(), {SuperMediaType.video}, false);
    await expectScope(const SuperVideosPicker(), {SuperMediaType.video}, true);
    await expectScope(const SuperFilePicker(), {SuperMediaType.file}, false);
    await expectScope(const SuperFilesPicker(), {SuperMediaType.file}, true);
    await expectScope(const SuperSingleMediaPicker(), {
      SuperMediaType.image,
      SuperMediaType.video,
    }, false);
    await expectScope(const SuperMultipleMediaPicker(), {
      SuperMediaType.image,
      SuperMediaType.video,
    }, true);
  });

  testWidgets('single image callback returns the picked path', (tester) async {
    String? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperImagePicker(onUploadImage: (path) => received = path),
        ),
      ),
    );

    final inner = tester.widget<SuperMediaPicker>(
      find.byType(SuperMediaPicker),
    );
    inner.onPicked?.call([
      SuperMediaItem.local(
        id: 'image',
        path: '/tmp/image.jpg',
        type: SuperMediaType.image,
      ),
    ]);

    expect(received, '/tmp/image.jpg');
  });

  testWidgets('multiple video callback returns one batch of paths', (
    tester,
  ) async {
    List<String>? received;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperVideosPicker(onUploadVideos: (paths) => received = paths),
        ),
      ),
    );

    final inner = tester.widget<SuperMediaPicker>(
      find.byType(SuperMediaPicker),
    );
    inner.onPicked?.call([
      SuperMediaItem.local(
        id: 'one',
        path: '/tmp/one.mp4',
        type: SuperMediaType.video,
      ),
      SuperMediaItem.local(
        id: 'two',
        path: '/tmp/two.mp4',
        type: SuperMediaType.video,
      ),
    ]);

    expect(received, ['/tmp/one.mp4', '/tmp/two.mp4']);
  });

  testWidgets('simple picker preserves visual configuration', (tester) async {
    const config = SuperMediaPickerConfig(
      layout: SuperMediaLayout.list,
      listItemHeight: 77,
      frame: SuperMediaFrameConfig(width: 240, height: 180),
      textDirection: TextDirection.rtl,
    );
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: SuperFilePicker(config: config))),
    );

    final inner = tester.widget<SuperMediaPicker>(
      find.byType(SuperMediaPicker),
    );
    expect(inner.config.layout, SuperMediaLayout.list);
    expect(inner.config.listItemHeight, 77);
    expect(inner.config.frame.width, 240);
    expect(inner.config.textDirection, TextDirection.rtl);
  });

  testWidgets('multiple image picker exposes quality, size, and count limits', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperImagesPicker(
            maxItems: 6,
            quality: 72,
            maxWidth: 1600,
            maxHeight: 1200,
            maxSizeBytes: 5.mb,
            maxTotalSizeBytes: 20.mb,
          ),
        ),
      ),
    );

    final config =
        tester.widget<SuperMediaPicker>(find.byType(SuperMediaPicker)).config;
    expect(config.limits.maxItems, 6);
    expect(config.limits.maxImages, 6);
    expect(config.limits.maxTotalSizeBytes, 20.mb);
    expect(config.image.quality, 72);
    expect(config.image.maxWidth, 1600);
    expect(config.image.maxHeight, 1200);
    expect(config.image.maxSizeBytes, 5.mb);
  });

  testWidgets('multiple video and file pickers expose their own limits', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperVideosPicker(
            maxItems: 4,
            maxSizeBytes: 100.mb,
            maxTotalSizeBytes: 300.mb,
            maxDuration: const Duration(minutes: 5),
          ),
        ),
      ),
    );
    var config =
        tester.widget<SuperMediaPicker>(find.byType(SuperMediaPicker)).config;
    expect(config.limits.maxItems, 4);
    expect(config.limits.maxVideos, 4);
    expect(config.limits.maxTotalSizeBytes, 300.mb);
    expect(config.video.maxSizeBytes, 100.mb);
    expect(config.video.maxDuration, const Duration(minutes: 5));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperFilesPicker(
            maxItems: 5,
            maxSizeBytes: 10.mb,
            maxTotalSizeBytes: 40.mb,
          ),
        ),
      ),
    );
    config =
        tester.widget<SuperMediaPicker>(find.byType(SuperMediaPicker)).config;
    expect(config.limits.maxItems, 5);
    expect(config.limits.maxFiles, 5);
    expect(config.limits.maxTotalSizeBytes, 40.mb);
    expect(config.file.maxSizeBytes, 10.mb);
  });

  testWidgets('multiple mixed media supports total and per-type limits', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMultipleMediaPicker(
            maxItems: 8,
            maxImages: 6,
            maxVideos: 2,
            imageQuality: 75,
            imageMaxSizeBytes: 5.mb,
            videoMaxSizeBytes: 100.mb,
            maxTotalSizeBytes: 300.mb,
          ),
        ),
      ),
    );

    final config =
        tester.widget<SuperMediaPicker>(find.byType(SuperMediaPicker)).config;
    expect(config.limits.maxItems, 8);
    expect(config.limits.maxImages, 6);
    expect(config.limits.maxVideos, 2);
    expect(config.limits.maxTotalSizeBytes, 300.mb);
    expect(config.image.quality, 75);
    expect(config.image.maxSizeBytes, 5.mb);
    expect(config.video.maxSizeBytes, 100.mb);
  });

  testWidgets('simple picker can completely replace the default add frame', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperImagePicker(
            addButtonBuilder:
                (_, openPicker) => GestureDetector(
                  key: const Key('custom-upload-frame'),
                  onTap: openPicker,
                  child: const Text('My upload design'),
                ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('custom-upload-frame')), findsOneWidget);
    expect(find.text('My upload design'), findsOneWidget);
    expect(find.text('Add media'), findsNothing);

    await tester.tap(find.byKey(const Key('custom-upload-frame')));
    await tester.pumpAndSettle();
    expect(find.text('Images'), findsOneWidget);
  });
}
