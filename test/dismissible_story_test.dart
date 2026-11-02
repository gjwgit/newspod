/// Tests for swiping a story out of the news.

library;

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:newspod/models/story.dart';
import 'package:newspod/services/news.dart';
import 'package:newspod/widgets/dismissible_story.dart';

const _story = Story(
  title: 'A headline',
  link: 'https://example.com/a',
  source: 'ABC News',
);

// The dismissed links as saved on the device.

List<Object?> _saved(SharedPreferences prefs) =>
    jsonDecode(prefs.getString('newspod_dismissed_links')!) as List;

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('swiped left the story goes, is remembered, and Undo restores '
      'it', (tester) async {
    // The list drops the story once News says it changed, as the news list
    // does, which a Dismissible needs.

    var shown = true;
    void hide() => shown = false;
    news.addListener(hide);
    addTearDown(() => news.removeListener(hide));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListenableBuilder(
            listenable: news,
            builder: (context, _) => shown
                ? DismissibleStory(story: _story, now: DateTime.now())
                : const SizedBox(),
          ),
        ),
      ),
    );

    await tester.drag(find.text('A headline'), const Offset(-600, 0));
    await tester.pumpAndSettle();

    expect(find.text('A headline'), findsNothing);
    expect(find.text('Removed from the news.'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(_saved(prefs), [_story.link]);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_saved(prefs), isEmpty);

    // The bar hides itself after a few seconds, which the test waits for.

    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
  });

  testWidgets('under Dismissed, swiped right the story goes back to the '
      'news, and Undo dismisses it again', (tester) async {
    await news.dismiss(_story);

    var shown = true;
    void hide() => shown = false;
    news.addListener(hide);
    addTearDown(() => news.removeListener(hide));

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListenableBuilder(
            listenable: news,
            builder: (context, _) => shown
                ? DismissibleStory(
                    story: _story,
                    now: DateTime.now(),
                    dismissed: true,
                  )
                : const SizedBox(),
          ),
        ),
      ),
    );

    // Swiped left nothing happens: that is the way into Dismissed.

    await tester.drag(find.text('A headline'), const Offset(-600, 0));
    await tester.pumpAndSettle();
    expect(find.text('A headline'), findsOneWidget);

    await tester.drag(find.text('A headline'), const Offset(600, 0));
    await tester.pumpAndSettle();

    expect(find.text('Back in the news.'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    expect(_saved(prefs), isEmpty);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(_saved(prefs), [_story.link]);

    // The bar hides itself after a few seconds, which the test waits for.

    await tester.pump(const Duration(seconds: 10));
    await tester.pumpAndSettle();
  });

  testWidgets('swiped right nothing happens', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DismissibleStory(story: _story, now: DateTime.now()),
        ),
      ),
    );

    await tester.drag(find.text('A headline'), const Offset(600, 0));
    await tester.pumpAndSettle();

    expect(find.text('A headline'), findsOneWidget);
  });
}
