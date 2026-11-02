/// Open a story on its own site.
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

import 'package:url_launcher/url_launcher.dart';

/// Open [link] in the browser, or say in a dialog that it could not be.
/// Answers whether it opened.

Future<bool> openLink(BuildContext context, String link) async {
  final uri = Uri.tryParse(link);
  final opened =
      uri != null && await launchUrl(uri, mode: LaunchMode.externalApplication);

  if (opened || !context.mounted) return opened;

  await showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Could Not Open the Story'),
      content: Text('No browser would open $link'),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK'),
        ),
      ],
    ),
  );

  return false;
}
