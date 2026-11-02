/// The stories dismissed from the news, kept on the device and the Pod.
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

import 'package:newspod/services/synced_list.dart';

/// The links of the stories swiped out of the news, kept on this device and,
/// when logged in, in dismissed.ttl on the Pod, so that they stay out on
/// every device.

class DismissedLinks extends SyncedList<String> {
  DismissedLinks({super.connected, super.read, super.write})
    : super(
        key: 'newspod_dismissed_links',
        file: 'dismissed.ttl',
        keep: keep,
        keyOf: (link) => link,
        toJson: (link) => link,
        fromJson: (json) => json as String,
      );

  /// How many links are kept, the latest. A feed drops a story long before
  /// this many more have been dismissed.

  static const keep = 1000;

  /// Whether the story at [link] was dismissed.

  bool contains(String link) => containsKey(link);

  /// Bring back the story at [link].

  Future<void> remove(String link) => removeKey(link);
}
