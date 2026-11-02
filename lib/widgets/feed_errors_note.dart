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

import 'package:flutter/material.dart';

/// Says at the top of the news that [count] feeds could not be read, and
/// where to see why.

class FeedErrorsNote extends StatelessWidget {
  const FeedErrorsNote({super.key, required this.count});

  /// How many feeds failed.

  final int count;

  @override
  Widget build(BuildContext context) {
    final colours = Theme.of(context).colorScheme;

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
