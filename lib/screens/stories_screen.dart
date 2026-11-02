/// The stories kept for later, viewed, or dismissed.
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

import 'package:newspod/models/story_place.dart';
import 'package:newspod/services/news.dart';
import 'package:newspod/widgets/dismissible_story.dart';

/// The stories kept for later or viewed, the latest first, or those swiped
/// out of the news that the feeds still have, newest first, each swiped on as
/// [DismissibleStory] says. Tapped a story opens. When there are none,
/// [empty] says how a story gets here.

class StoriesScreen extends StatelessWidget {
  const StoriesScreen({super.key, required this.place, required this.empty});

  /// Which stories, those kept for later, viewed or dismissed.

  final StoryPlace place;

  /// What to say when there are none.

  final String empty;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: news,
      builder: (context, _) {
        final now = DateTime.now();
        final stories = switch (place) {
          StoryPlace.news => news.stories,
          StoryPlace.later => news.later,
          StoryPlace.viewed => news.viewed,
          StoryPlace.dismissed => news.dismissed,
        };

        return ListView(
          children: [
            if (stories.isEmpty)
              Padding(
                padding: const EdgeInsets.all(32),
                child: Text(empty, textAlign: TextAlign.center),
              ),
            for (final story in stories)
              DismissibleStory(story: story, now: now, place: place),
          ],
        );
      },
    );
  }
}
