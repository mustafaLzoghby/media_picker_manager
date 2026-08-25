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
      const MaterialApp(
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

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: SuperMediaPicker(
            controller: controller,
            config: const SuperMediaPickerConfig(),
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
