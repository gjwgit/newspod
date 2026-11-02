/// Tests for a story in the news list.

library;

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/models/story.dart';
import 'package:newspod/widgets/story_tile.dart';

Widget _wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  final now = DateTime.utc(2026, 11, 2, 12);

  testWidgets('the source and age, headline and summary show', (tester) async {
    await tester.pumpWidget(
      _wrap(
        StoryTile(
          now: now,
          story: Story(
            title: 'A headline',
            link: 'https://example.com/a',
            source: 'ABC News',
            summary: 'The opening lines.',
            published: now.subtract(const Duration(hours: 3)),
          ),
        ),
      ),
    );

    expect(find.text('ABC News · 3h'), findsOneWidget);
    expect(find.text('A headline'), findsOneWidget);
    expect(find.text('The opening lines.'), findsOneWidget);
    expect(find.byType(Image), findsNothing);
  });

  testWidgets('a story with no date or summary shows just its source', (
    tester,
  ) async {
    await tester.pumpWidget(
      _wrap(
        StoryTile(
          now: now,
          story: const Story(
            title: 'Undated',
            link: 'https://example.com/b',
            source: 'BBC World',
          ),
        ),
      ),
    );

    expect(find.text('BBC World'), findsOneWidget);
    expect(find.text('Undated'), findsOneWidget);
  });
}
