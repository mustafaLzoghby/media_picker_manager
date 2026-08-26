import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_picker_manager/media_picker_manager.dart';

void main() {
  testWidgets('hides the reorder handle icon by default', (tester) async {
    final controller = SuperMediaController(
      initialItems: [
        SuperMediaItem.local(id: 'one', path: '/one.jpg'),
        SuperMediaItem.local(id: 'two', path: '/two.jpg'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SuperMediaPicker(controller: controller)),
      ),
    );

    expect(find.byIcon(Icons.drag_indicator_rounded), findsNothing);
    expect(
      tester
          .widget<SuperMediaPicker>(find.byType(SuperMediaPicker))
          .config
          .enableReorder,
      isTrue,
    );
    controller.dispose();
  });

  testWidgets('controls item frame width and height in list layout', (
    tester,
  ) async {
    final controller = SuperMediaController(
      initialItems: [SuperMediaItem.local(id: 'item', path: '/item.txt')],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            controller: controller,
            config: const SuperMediaPickerConfig(
              layout: SuperMediaLayout.list,
              itemFrame: SuperMediaItemFrameConfig(width: 200, height: 80),
            ),
            itemBuilder:
                (_, _, _, _) => const ColoredBox(
                  key: Key('sized-item'),
                  color: Colors.blue,
                ),
          ),
        ),
      ),
    );

    expect(
      tester.getSize(find.byKey(const Key('sized-item'))),
      const Size(200, 80),
    );
    controller.dispose();
  });

  testWidgets('merges newly added initial API items without a restart', (
    tester,
  ) async {
    final first = SuperMediaItem.remote(
      id: 'api-1',
      url: 'https://example.com/1',
    );
    final second = SuperMediaItem.remote(
      id: 'api-2',
      url: 'https://example.com/2',
    );
    final items = ValueNotifier<List<SuperMediaItem>>([first]);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<List<SuperMediaItem>>(
            valueListenable: items,
            builder: (_, value, _) => SuperMediaPicker(initialItems: value),
          ),
        ),
      ),
    );
    expect(find.text('api-1'), findsOneWidget);

    items.value = [first, second];
    await tester.pump();

    expect(find.text('api-1'), findsOneWidget);
    expect(find.text('api-2'), findsOneWidget);
    items.dispose();
  });

  testWidgets('does not duplicate a picked path passed back as initialImage', (
    tester,
  ) async {
    const path = '/tmp/picked-image.jpg';
    final controller = SuperMediaController(
      initialItems: [SuperMediaItem.local(id: 'generated-id', path: path)],
    );
    final initialImage = ValueNotifier<String?>(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<String?>(
            valueListenable: initialImage,
            builder:
                (_, value, _) => SuperImagePicker<String>(
                  controller: controller,
                  initialImage: value,
                ),
          ),
        ),
      ),
    );

    initialImage.value = path;
    await tester.pump();

    expect(controller.items, hasLength(1));
    expect(controller.items.single.path, path);
    initialImage.dispose();
    controller.dispose();
  });

  testWidgets('single picker syncs a different incoming initial path', (
    tester,
  ) async {
    final controller = SuperMediaController(
      initialItems: [
        SuperMediaItem.local(id: 'picked-id', path: '/tmp/old.jpg'),
      ],
    );
    final initialImage = ValueNotifier<String?>(null);

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ValueListenableBuilder<String?>(
            valueListenable: initialImage,
            builder:
                (_, value, _) => SuperImagePicker<String>(
                  controller: controller,
                  initialImage: value,
                ),
          ),
        ),
      ),
    );

    initialImage.value = '/tmp/new.jpg';
    await tester.pump();

    expect(controller.items, hasLength(1));
    expect(controller.items.single.path, '/tmp/new.jpg');
    initialImage.dispose();
    controller.dispose();
  });

  testWidgets('allowMultiple false hides add after one item', (tester) async {
    final controller = SuperMediaController(
      initialItems: [
        SuperMediaItem.local(id: 'only-item', path: '/tmp/only.jpg'),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            controller: controller,
            config: const SuperMediaPickerConfig(allowMultiple: false),
          ),
        ),
      ),
    );

    expect(find.text('Add media'), findsNothing);
    controller.dispose();
  });

  testWidgets('supports separate remote and local metadata visibility', (
    tester,
  ) async {
    final controller = SuperMediaController(
      initialItems: [
        SuperMediaItem.remote(
          id: 'remote',
          url: 'https://example.com/remote.jpg',
          sizeBytes: 200,
        ),
        SuperMediaItem.local(id: 'local', path: '/local.jpg', sizeBytes: 100),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            controller: controller,
            config: const SuperMediaPickerConfig(
              showFileName: false,
              showFileSize: false,
              showLocalFileSize: true,
              showRemoteFileSize: false,
            ),
          ),
        ),
      ),
    );

    expect(find.text('100 B'), findsOneWidget);
    expect(find.text('200 B'), findsNothing);
    expect(find.text('local.jpg'), findsNothing);
    expect(find.text('remote.jpg'), findsNothing);
    controller.dispose();
  });

  testWidgets('uses device-language text and RTL direction automatically', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            config: SuperMediaPickerConfig(locale: Locale('ar')),
          ),
        ),
      ),
    );

    expect(find.text('إضافة وسائط'), findsOneWidget);
    final directionality = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.text('إضافة وسائط'),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });

  testWidgets('follows the application locale and direction before device', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Localizations(
            locale: Locale('ar'),
            delegates: [DefaultWidgetsLocalizations.delegate],
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: SuperMediaPicker(),
            ),
          ),
        ),
      ),
    );

    expect(find.text('إضافة وسائط'), findsOneWidget);
    final directionality = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.text('إضافة وسائط'),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });

  testWidgets('supports an explicit RTL direction override', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            config: SuperMediaPickerConfig(
              locale: Locale('en'),
              textDirection: TextDirection.rtl,
            ),
          ),
        ),
      ),
    );

    final directionality = tester.widget<Directionality>(
      find
          .ancestor(
            of: find.text('Add media'),
            matching: find.byType(Directionality),
          )
          .first,
    );
    expect(directionality.textDirection, TextDirection.rtl);
  });

  testWidgets('supports application-provided locale translations', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            config: SuperMediaPickerConfig(
              locale: Locale('it'),
              translations: {
                'it': SuperMediaTextConfig(addMedia: 'Carica media'),
              },
            ),
          ),
        ),
      ),
    );

    expect(find.text('Carica media'), findsOneWidget);
  });

  testWidgets('tapping an image opens the full-screen preview', (tester) async {
    final controller = SuperMediaController(
      initialItems: [
        SuperMediaItem.local(
          id: 'image',
          path: '/missing-image.jpg',
          name: 'preview-me.jpg',
          type: SuperMediaType.image,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: SuperMediaPicker(controller: controller)),
      ),
    );

    await tester.tap(find.text('preview-me.jpg'));
    await tester.pumpAndSettle();

    expect(find.byType(SuperMediaPreview), findsOneWidget);
    expect(find.byType(InteractiveViewer), findsOneWidget);
    controller.dispose();
  });

  testWidgets('uses custom text and widget icons', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            config: const SuperMediaPickerConfig(
              text: SuperMediaTextConfig(
                addMedia: 'Upload now',
                images: 'Choose photos',
              ),
              icons: SuperMediaIconConfig(
                addMedia: SizedBox(key: Key('upload-widget')),
                images: SizedBox(key: Key('images-widget')),
              ),
            ),
          ),
        ),
      ),
    );

    expect(find.text('Upload now'), findsOneWidget);
    expect(find.byKey(const Key('upload-widget')), findsOneWidget);

    await tester.tap(find.text('Upload now'));
    await tester.pumpAndSettle();

    expect(find.text('Choose photos'), findsOneWidget);
    expect(find.byKey(const Key('images-widget')), findsOneWidget);
  });

  testWidgets('can present source widgets in a dialog', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            config: SuperMediaPickerConfig(
              allowedTypes: {SuperMediaType.image},
              sources: {SuperMediaSource.gallery, SuperMediaSource.camera},
              sourcePresentation: SuperMediaSourcePresentation.dialog,
              icons: SuperMediaIconConfig(
                images: SizedBox(key: Key('dialog-gallery-widget')),
                takePhoto: SizedBox(key: Key('dialog-camera-widget')),
              ),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('Add media'));
    await tester.pumpAndSettle();

    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Choose a source'), findsOneWidget);
    expect(find.byKey(const Key('dialog-gallery-widget')), findsOneWidget);
    expect(find.byKey(const Key('dialog-camera-widget')), findsOneWidget);
  });

  testWidgets('confirmation and async endpoint run before removing an item', (
    tester,
  ) async {
    final controller = SuperMediaController(
      initialItems: [
        SuperMediaItem.remote(
          id: 'api-delete',
          url: 'https://example.com/delete.jpg',
        ),
      ],
    );
    var endpointCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            controller: controller,
            config: const SuperMediaPickerConfig(confirmDelete: true),
            onDeleteRequest: (item) async {
              endpointCalls++;
              return item.id == 'api-delete';
            },
          ),
        ),
      ),
    );

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    expect(find.text('Delete media?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(controller.items, hasLength(1));
    expect(endpointCalls, 0);

    await tester.tap(find.byIcon(Icons.close));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(endpointCalls, 1);
    expect(controller.items, isEmpty);
    controller.dispose();
  });

  testWidgets('uses separate local and remote item builders', (tester) async {
    final controller = SuperMediaController(
      initialItems: [
        SuperMediaItem.local(id: 'local', path: '/local.txt'),
        SuperMediaItem.remote(
          id: 'remote',
          url: 'https://example.com/remote.txt',
        ),
      ],
    );
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            controller: controller,
            localItemBuilder: (_, item, _, _) => Text('Local ${item.id}'),
            remoteItemBuilder: (_, item, _, _) => Text('API ${item.id}'),
          ),
        ),
      ),
    );

    expect(find.text('Local local'), findsOneWidget);
    expect(find.text('API remote'), findsOneWidget);
    controller.dispose();
  });

  testWidgets('applies frame configuration and custom container builder', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            config: const SuperMediaPickerConfig(
              frame: SuperMediaFrameConfig(
                width: 320,
                padding: EdgeInsets.all(12),
              ),
            ),
            containerBuilder:
                (_, child) => ColoredBox(
                  key: const Key('custom-container'),
                  color: Colors.blue,
                  child: child,
                ),
          ),
        ),
      ),
    );

    expect(find.byKey(const Key('custom-container')), findsOneWidget);
    expect(tester.getSize(find.byType(Container).first).width, 320);
  });

  testWidgets('outer frame changes size when selection state changes', (
    tester,
  ) async {
    final controller = SuperMediaController();
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            controller: controller,
            config: const SuperMediaPickerConfig(
              crossAxisCount: 1,
              gridItemHeight: 80,
              frame: SuperMediaFrameConfig(
                width: 280,
                height: 140,
                emptyWidth: 220,
                emptyHeight: 100,
                nonEmptyWidth: 340,
                nonEmptyHeight: 180,
              ),
            ),
          ),
        ),
      ),
    );

    expect(tester.getSize(find.byType(Container).first), const Size(220, 100));

    controller.add(
      SuperMediaItem.local(
        id: 'selected-file',
        path: '/selected.txt',
        name: 'selected.txt',
        type: SuperMediaType.file,
      ),
      config: const SuperMediaPickerConfig(),
    );
    await tester.pump();

    expect(tester.getSize(find.byType(Container).first), const Size(340, 180));
    controller.dispose();
  });

  testWidgets('grid layout renders custom empty state and add button', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            emptyBuilder: (_) => const Text('Nothing selected'),
          ),
        ),
      ),
    );

    expect(find.text('Nothing selected'), findsOneWidget);
    expect(find.text('Add media'), findsOneWidget);
  });

  testWidgets('reorder-enabled items can be dragged in grid layout', (
    tester,
  ) async {
    final controller = SuperMediaController(
      initialItems: [
        SuperMediaItem.local(
          id: 'a',
          path: '/a.txt',
          name: 'a.txt',
          type: SuperMediaType.file,
        ),
        SuperMediaItem.local(
          id: 'b',
          path: '/b.txt',
          name: 'b.txt',
          type: SuperMediaType.file,
        ),
      ],
    );

    List<String>? orderedIds;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            controller: controller,
            config: const SuperMediaPickerConfig(),
            onReorder: (ids) => orderedIds = ids,
          ),
        ),
      ),
    );

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('a.txt')),
    );
    await tester.pump(kLongPressTimeout);
    await gesture.moveTo(tester.getCenter(find.text('b.txt')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.items.map((item) => item.id), ['b', 'a']);
    expect(orderedIds, ['b', 'a']);
    controller.dispose();
  });

  testWidgets('items can be dragged to sort in list layout', (tester) async {
    final controller = SuperMediaController(
      initialItems: [
        SuperMediaItem.local(
          id: 'a',
          path: '/a.txt',
          name: 'a.txt',
          type: SuperMediaType.file,
        ),
        SuperMediaItem.local(
          id: 'b',
          path: '/b.txt',
          name: 'b.txt',
          type: SuperMediaType.file,
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            controller: controller,
            config: const SuperMediaPickerConfig(layout: SuperMediaLayout.list),
          ),
        ),
      ),
    );

    expect(find.byIcon(Icons.drag_indicator_rounded), findsNothing);

    final gesture = await tester.startGesture(
      tester.getCenter(find.text('a.txt')),
    );
    await tester.pump(kLongPressTimeout);
    await gesture.moveTo(tester.getCenter(find.text('b.txt')));
    await tester.pump();
    await gesture.up();
    await tester.pumpAndSettle();

    expect(controller.items.map((item) => item.id), ['b', 'a']);
    controller.dispose();
  });
}
