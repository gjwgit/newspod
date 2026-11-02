/// A note that some feeds could not be read.
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

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:newspod/constants/app.dart';
import 'package:newspod/utils/open_link.dart';

/// Says at the top of the news that [count] feeds could not be read, and
/// where to see why. In a browser it says why there and then, since there
/// almost every feed fails, and offers the install guide.

class FeedErrorsNote extends StatelessWidget {
  const FeedErrorsNote({super.key, required this.count, this.web = kIsWeb});

  /// How many feeds failed.

  final int count;

  /// Whether the app is running in a browser.

  final bool web;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).colorScheme;

    // 20261102 gjw A news site serves its feed to any app, but tells a
    // browser to let only the site's own pages read it (CORS), so in a
    // browser the feeds fail however they are asked for.

    if (web) {
      return ListTile(
        leading: Icon(Icons.info_outline, color: colours.error),
        title: const Text('A browser cannot read most news feeds.'),
        subtitle: const Text(
          'News sites only allow their own web pages to read their feeds, '
          'and the browser holds NewsPod to that. Install NewsPod on your '
          'desktop, laptop or phone, where the feeds can be read.',
        ),
        trailing: TextButton(
          onPressed: () => openLink(context, installGuideUrl),
          child: const Text('Install'),
        ),
      );
    }

    return ListTile(
      leading: Icon(Icons.info_outline, color: colours.error),
      title: Text(
        count == 1
            ? 'One feed could not be read.'
            : '$count feeds could not be read.',
      ),
      subtitle: const Text('Feeds says why.'),
    );
  }
}
