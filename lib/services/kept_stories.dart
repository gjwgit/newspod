/// Stories kept whole, for later or as viewed.
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

import 'package:newspod/models/story.dart';
import 'package:newspod/services/synced_list.dart';

/// The stories kept under [name], those swiped right to read later or those
/// viewed, kept whole, so they stay after their feeds drop them, on this
/// device and, when logged in, in `<name>.ttl` on the Pod, so that every
/// device has them. Only the latest [keep] are kept, when given.

class KeptStories extends SyncedList<Story> {
  KeptStories({
    required String name,
    super.keep,
    super.connected,
    super.read,
    super.write,
  }) : super(
         key: 'newspod_$name',
         file: '$name.ttl',
         keyOf: (story) => story.link,
         toJson: (story) => story.toJson(),
         fromJson: (json) => Story.fromJson(json as Map<String, dynamic>),
       );

  /// Whether the story at [link] is kept here.

  bool contains(String link) => containsKey(link);

  /// Stop keeping the story at [link].

  Future<void> remove(String link) => removeKey(link);
}
