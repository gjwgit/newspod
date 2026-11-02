/// JSON kept in an encrypted file on the Pod.
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

import 'dart:convert';

import 'package:solidpod/solidpod.dart';
import 'package:solidui/solidui.dart';

// 20261102 gjw As todopod does, the JSON sits in a Turtle literal, and the
// file is encrypted by solidpod, so the feeds and the stories dismissed are
// the user's alone. The files are under newspod/data/ on the Pod.

final _data = RegExp(r'newspod:data\s+"""(.*?)"""', dotAll: true);

/// The JSON in [file] on the Pod, or null when the file is not there yet.
/// Throws when the Pod cannot be read, or the file is not as written here,
/// so that a failure is never taken for an empty list and written over.

Future<Object?> readPodJson(String file) async {
  try {
    return jsonFromTurtle(await readPod(file));
  } on ResourceNotExistException {
    return null;
  }
}

/// Write [json] to [file] on the Pod, encrypted, in place of what is there.

Future<void> writePodJson(String file, Object json) => SolidPendingWrites.track(
  writePod(file, jsonTurtle(file, json), overwrite: true),
);

/// [json] as the Turtle content of [file].
///
/// 20261102 gjw The vocabulary address is split, as todopod's is, so the link
/// checker does not take it for a page: it names the terms and serves nothing.

String jsonTurtle(String file, Object json) =>
    '@prefix newspod: <https://'
    'newspod.solidcommunity.au/ont/> .\n\n'
    'newspod:${file.split('.').first} a newspod:Data ;\n'
    '  newspod:data """${jsonEncode(json)}""" .\n';

/// The JSON in [ttl], written by [jsonTurtle], or null for an empty file.
/// Throws a [FormatException] for anything else.

Object? jsonFromTurtle(String ttl) {
  if (ttl.trim().isEmpty) return null;

  final json = _data.firstMatch(ttl)?.group(1);
  if (json == null) throw const FormatException('Not a NewsPod file.');

  return jsonDecode(json);
}
