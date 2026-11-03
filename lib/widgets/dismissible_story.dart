/// A story that can be swiped from one list to another.
//
// Time-stamp: <>
//
/// Copyright (C) 2026, Togaware Pty Ltd
///
/// Licensed under the GNU General Public License, Version 3 (the "License").
///
/// License: https://opensource.org/license/gpl-3-0.
//
// This program is free software: you can redistribute it and/or modify it under
// the terms of the GNU General Public License as published by the Free Software
// Foundation, either version 3 of the License, or (at your option) any later
// version.
//
// This program is distributed in the hope that it will be useful, but WITHOUT
// ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS
// FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more
// details.
//
// You should have received a copy of the GNU General Public License along with
// this program.  If not, see <https://opensource.org/license/gpl-3-0>.
///
/// Authors: Graham Williams

library;

import 'package:flutter/material.dart';

import 'package:solidui/solidui.dart';

import 'package:newspod/models/story.dart';
import 'package:newspod/models/story_place.dart';
import 'package:newspod/services/news.dart';
import 'package:newspod/widgets/story_tile.dart';

/// [story] in the list for [place], with the divider beneath it. In the news
/// it is swiped right to keep it for later and left to remove it, and once
/// opened it moves to viewed. Kept for later it is swiped right, once read,
/// to viewed. Viewed it is swiped right back to the news. Dismissed it is
/// swiped right back to the news. Swiped left it is removed. Each swipe has
/// Undo.

class DismissibleStory extends StatelessWidget {
  const DismissibleStory({
    super.key,
    required this.story,
    required this.now,
    this.place = StoryPlace.news,
  });

  /// The story to show.

  final Story story;

  /// The time the ages are reckoned from, the same for the whole list.

  final DateTime now;

  /// The list the story is shown in.

  final StoryPlace place;

  // Where a swipe right, then a swipe left, takes a story from each list.

  static const _moves = {
    StoryPlace.news: (StoryPlace.later, StoryPlace.dismissed),
    StoryPlace.later: (StoryPlace.viewed, StoryPlace.dismissed),
    StoryPlace.viewed: (StoryPlace.news, StoryPlace.dismissed),
    StoryPlace.dismissed: (StoryPlace.news, null),
  };

  void _swiped(BuildContext context, StoryPlace to) {
    news.move(story, to);

    showPositiveSnackBar(
      context,
      switch (to) {
        StoryPlace.news => 'Back in the news.',
        StoryPlace.later => 'Kept for later.',
        StoryPlace.viewed => 'Moved to Viewed.',
        StoryPlace.dismissed => 'Removed from the news.',
      },
      actionLabel: 'Undo',
      onAction: () => news.move(story, place),
    );
  }

  Widget _background(BuildContext context, StoryPlace to, Alignment side) {
    final colours = Theme.of(context).colorScheme;
    final (back, fore, icon) = switch (to) {
      StoryPlace.news => (
        colours.primaryContainer,
        colours.onPrimaryContainer,
        Icons.restore,
      ),
      StoryPlace.later => (
        colours.tertiaryContainer,
        colours.onTertiaryContainer,
        Icons.watch_later_outlined,
      ),
      StoryPlace.viewed => (
        colours.secondaryContainer,
        colours.onSecondaryContainer,
        Icons.history,
      ),
      StoryPlace.dismissed => (
        colours.errorContainer,
        colours.onErrorContainer,
        Icons.delete_outline,
      ),
    };

    return ColoredBox(
      color: back,
      child: Align(
        alignment: side,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Icon(icon, color: fore),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final (right, left) = _moves[place]!;

    return Dismissible(
      key: ValueKey(story.link),
      direction: left == null
          ? DismissDirection.startToEnd
          : DismissDirection.horizontal,
      onDismissed: (direction) => _swiped(
        context,
        direction == DismissDirection.startToEnd ? right : left!,
      ),
      background: _background(context, right, Alignment.centerLeft),
      secondaryBackground: left == null
          ? null
          : _background(context, left, Alignment.centerRight),
      child: Column(
        children: [
          StoryTile(
            story: story,
            now: now,
            onOpened: place == StoryPlace.news
                ? () => news.move(story, StoryPlace.viewed)
                : null,
          ),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
