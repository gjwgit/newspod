/// Tests for swiping a story from one list to another.

library;

import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:newspod/models/story.dart';
import 'package:newspod/models/story_place.dart';
import 'package:newspod/services/news.dart';
import 'package:newspod/widgets/dismissible_story.dart';

const _story = Story(
  title: 'A headline',
  link: 'https://example.com/a',
  source: 'ABC News',
);

// The links dismissed, and those kept for later, as saved on the device.

Future<List<Object?>> _dismissed() async => _saved('newspod_dismissed_links');

Future<List<Object?>> _later() async => [
  for (final story in await _saved('newspod_later'))
    (story as Map<String, dynamic>)['link'],
];

Future<List<Object?>> _saved(String key) async {
  final prefs = await SharedPreferences.getInstance();

  return jsonDecode(prefs.getString(key) ?? '[]') as List;
}

// The story shown in [place]'s list, which drops it once News says it
// changed, as the lists do, which a Dismissible needs.

Future<void> _show(WidgetTester tester, StoryPlace place) async {
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
                  place: place,
                )
              : const SizedBox(),
        ),
      ),
    ),
  );
}

Future<void> _swipe(WidgetTester tester, double dx) async {
  await tester.drag(find.text('A headline'), Offset(dx, 0));
  await tester.pumpAndSettle();
}

// The bar hides itself after a few seconds, which a test waits for.

Future<void> _barGone(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 10));
  await tester.pumpAndSettle();
}

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await news.move(_story, StoryPlace.news);
  });

  testWidgets('in the news, swiped left the story goes, is remembered, and '
      'Undo restores it', (tester) async {
    await _show(tester, StoryPlace.news);
    await _swipe(tester, -600);

    expect(find.text('A headline'), findsNothing);
    expect(find.text('Removed from the news.'), findsOneWidget);
    expect(await _dismissed(), [_story.link]);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(await _dismissed(), isEmpty);

    await _barGone(tester);
  });

  testWidgets('in the news, swiped right the story is kept for later, and '
      'Undo puts it back', (tester) async {
    await _show(tester, StoryPlace.news);
    await _swipe(tester, 600);

    expect(find.text('A headline'), findsNothing);
    expect(find.text('Kept for later.'), findsOneWidget);
    expect(await _later(), [_story.link]);
    expect(news.later.single.title, 'A headline');

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(await _later(), isEmpty);

    await _barGone(tester);
  });

  testWidgets('under Later, swiped left the story is removed from the news, '
      'and Undo keeps it again', (tester) async {
    await news.move(_story, StoryPlace.later);
    await _show(tester, StoryPlace.later);
    await _swipe(tester, -600);

    expect(find.text('Removed from the news.'), findsOneWidget);
    expect(await _later(), isEmpty);
    expect(await _dismissed(), [_story.link]);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(await _later(), [_story.link]);
    expect(await _dismissed(), isEmpty);

    await _barGone(tester);
  });

  testWidgets('under Later, swiped right the story moves to Viewed, and '
      'Undo keeps it for later again', (tester) async {
    await news.move(_story, StoryPlace.later);
    await _show(tester, StoryPlace.later);
    await _swipe(tester, 600);

    expect(find.text('Moved to Viewed.'), findsOneWidget);
    expect(await _later(), isEmpty);
    expect(news.viewed.single.link, _story.link);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(await _later(), [_story.link]);
    expect(news.viewed, isEmpty);

    await _barGone(tester);
  });

  testWidgets('under Viewed, swiped right the story goes back to the news, '
      'and Undo views it again', (tester) async {
    await news.move(_story, StoryPlace.viewed);
    await _show(tester, StoryPlace.viewed);
    await _swipe(tester, 600);

    expect(find.text('Back in the news.'), findsOneWidget);
    expect(news.viewed, isEmpty);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(news.viewed.single.link, _story.link);

    await _barGone(tester);
  });

  testWidgets('under Dismissed, swiped right the story goes back to the '
      'news, and Undo dismisses it again', (tester) async {
    await news.move(_story, StoryPlace.dismissed);
    await _show(tester, StoryPlace.dismissed);

    // Swiped left nothing happens: that is the way into Dismissed.

    await _swipe(tester, -600);
    expect(find.text('A headline'), findsOneWidget);

    await _swipe(tester, 600);
    expect(find.text('Back in the news.'), findsOneWidget);
    expect(await _dismissed(), isEmpty);

    await tester.tap(find.text('Undo'));
    await tester.pumpAndSettle();
    expect(await _dismissed(), [_story.link]);

    await _barGone(tester);
  });
}
