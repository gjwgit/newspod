/// The address of a feed as typed.
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

/// [text] as a feed address: trimmed, with https:// added when no scheme is
/// given, or null when it cannot be one.

String? feedUrl(String text) {
  final value = text.trim();
  if (value.isEmpty || value.contains(' ')) return null;

  final uri = Uri.tryParse(value.contains('://') ? value : 'https://$value');
  if (uri == null || !uri.isScheme('http') && !uri.isScheme('https')) {
    return null;
  }

  return uri.host.contains('.') ? uri.toString() : null;
}
