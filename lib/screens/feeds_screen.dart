/// The feeds, with a field to add one.
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

import 'package:newspod/services/feed_list.dart';
import 'package:newspod/services/news.dart';
import 'package:newspod/widgets/feed_tile.dart';
import 'package:newspod/widgets/find_feeds_field.dart';

/// The feeds the news is gathered from, each marked when it could not be
/// read, and a field to find more.

class FeedsScreen extends StatelessWidget {
  const FeedsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([feedList, news]),
      builder: (context, _) => ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const FindFeedsField(),
          const SizedBox(height: 16),
          for (final feed in feedList.feeds)
            FeedTile(feed: feed, error: news.errors[feed.url]),
        ],
      ),
    );
  }
}
