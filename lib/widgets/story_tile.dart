/// One story in the news list.
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

import 'package:newspod/models/story.dart';
import 'package:newspod/utils/open_link.dart';
import 'package:newspod/utils/time_ago.dart';

/// A story: its source and age, headline and summary, and its picture when
/// it has one. A tap opens the full story on its own site.

class StoryTile extends StatelessWidget {
  const StoryTile({super.key, required this.story, required this.now});

  /// The story to show.

  final Story story;

  /// The time the ages are reckoned from, the same for the whole list.

  final DateTime now;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final published = story.published;
    final byline = [
      story.source,
      if (published != null) timeAgo(published, now),
    ].where((s) => s.isNotEmpty).join(' · ');

    return InkWell(
      onTap: () => openLink(context, story.link),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    byline,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(story.title, style: theme.textTheme.titleMedium),
                  if (story.summary.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      story.summary,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            if (story.imageUrl case final url?) ...[
              const SizedBox(width: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.network(
                  url,
                  width: 112,
                  height: 84,
                  fit: BoxFit.cover,

                  // A picture that will not load is left out, not shown broken.
                  errorBuilder: (_, _, _) => const SizedBox.shrink(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
