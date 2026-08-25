import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_picker_manager_example/main.dart';

void main() {
  testWidgets('shows every separate picker example', (tester) async {
    await tester.pumpWidget(const ExampleApp());

    expect(find.text('Media Picker Manager'), findsOneWidget);
    for (final title in [
      'One image',
      'Any typed model',
      'Multiple images',
      'One video',
      'Multiple videos',
      'One file',
      'Multiple files',
      'One image or video',
      'Multiple images and videos',
      'Advanced mixed picker',
    ]) {
      await tester.scrollUntilVisible(
        find.text(title),
        400,
        scrollable:
            find
                .descendant(
                  of: find.byType(ListView),
                  matching: find.byType(Scrollable),
                )
                .first,
      );
      expect(find.text(title), findsOneWidget);
      if (title == 'Any typed model') {
        expect(find.text('Delete all with controller'), findsOneWidget);
      }
    }
  });
}
