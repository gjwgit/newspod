/// The stories dismissed from the news, to bring back.
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

/// The stories swiped out of the news that the feeds still have, newest
/// first. Swiped right a story goes back to the news; tapped it opens.

class DismissedScreen extends StatelessWidget {
  const DismissedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: news,
      builder: (context, _) {
        final now = DateTime.now();

        return ListView(
          children: [
            if (news.dismissed.isEmpty)
              const Padding(
                padding: EdgeInsets.all(32),
                child: Text(
                  'Nothing dismissed. Swipe a story left in the News to '
                  'dismiss it, and it is listed here until its feed drops it.',
                  textAlign: TextAlign.center,
                ),
              ),
            for (final story in news.dismissed)
              DismissibleStory(story: story, now: now, dismissed: true),
          ],
        );
      },
    );
  }
}
