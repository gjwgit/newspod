/// The stories from every feed, newest first.
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

import 'package:newspod/services/news.dart';
import 'package:newspod/widgets/dismissible_story.dart';
import 'package:newspod/widgets/feed_errors_note.dart';

/// The news list, pulled down to refresh, each story moved to viewed once
/// opened, and swiped right to keep it for later or left to remove it, with a
/// note at the top when a feed could not be read.

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: news,
      builder: (context, _) {
        if (news.stories.isEmpty && news.loading) {
          return const Center(child: CircularProgressIndicator());
        }

        final now = DateTime.now();

        return Column(
          children: [
            if (news.loading) const LinearProgressIndicator(),
            Expanded(
              child: RefreshIndicator(
                onRefresh: news.refresh,
                child: ListView(
                  children: [
                    if (news.errors.isNotEmpty)
                      FeedErrorsNote(count: news.errors.length),
                    if (news.stories.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(32),
                        child: Text(
                          'No stories. Pull down for the latest, or add a '
                          'feed under Feeds.',
                          textAlign: TextAlign.center,
                        ),
                      ),
                    for (final story in news.stories)
                      DismissibleStory(story: story, now: now),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
