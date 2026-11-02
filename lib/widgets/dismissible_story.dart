/// A story that can be swiped left out of the news.
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
import 'package:newspod/services/news.dart';
import 'package:newspod/widgets/story_tile.dart';

/// [story] in the news list, with the divider beneath it. Swiped left it is
/// removed, for good, with Undo to bring it back.

class DismissibleStory extends StatelessWidget {
  const DismissibleStory({super.key, required this.story, required this.now});

  /// The story to show.

  final Story story;

  /// The time the ages are reckoned from, the same for the whole list.

  final DateTime now;

  void _dismiss(BuildContext context) {
    news.dismiss(story);

    showPositiveSnackBar(
      context,
      'Removed from the news.',
      actionLabel: 'Undo',
      onAction: () => news.restore(story),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).colorScheme;

    return Dismissible(
      key: ValueKey(story.link),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _dismiss(context),
      background: ColoredBox(
        color: colours.errorContainer,
        child: Align(
          alignment: Alignment.centerRight,
          child: Padding(
            padding: const EdgeInsets.only(right: 24),
            child: Icon(Icons.delete_outline, color: colours.onErrorContainer),
          ),
        ),
      ),
      child: Column(
        children: [
          StoryTile(story: story, now: now),
          const Divider(height: 1),
        ],
      ),
    );
  }
}
