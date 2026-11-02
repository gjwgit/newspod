/// The date of a story, as feeds write it.
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

// RFC 822 dates as RSS writes them, such as "Mon, 02 Nov 2026 01:18:23 +0000".
// The weekday and the seconds are optional, and the year may be two digits.

final _rfc822 = RegExp(
  r'^(?:[A-Za-z]{3},?\s*)?(\d{1,2})\s+([A-Za-z]{3})[a-z]*\s+(\d{2,4})\s+'
  r'(\d{1,2}):(\d{2})(?::(\d{2}))?\s*([A-Za-z]+|[+-]\d{4})?$',
);

const _months = [
  'jan',
  'feb',
  'mar',
  'apr',
  'may',
  'jun',
  'jul',
  'aug',
  'sep',
  'oct',
  'nov',
  'dec',
];

// The named zones RFC 822 allows, as hours from UTC.

const _zones = {
  'EST': -5,
  'EDT': -4,
  'CST': -6,
  'CDT': -5,
  'MST': -7,
  'MDT': -6,
  'PST': -8,
  'PDT': -7,
};

/// The UTC time [text] gives, in RFC 822 as RSS writes it or ISO 8601 as
/// Atom does, or null when it is neither.

DateTime? parseFeedDate(String? text) {
  final value = text?.trim() ?? '';
  if (value.isEmpty) return null;

  final iso = DateTime.tryParse(value);
  if (iso != null) return iso.toUtc();

  final m = _rfc822.firstMatch(value);
  if (m == null) return null;

  final month = _months.indexOf(m[2]!.toLowerCase()) + 1;
  if (month == 0) return null;

  var year = int.parse(m[3]!);
  if (year < 100) year += year < 50 ? 2000 : 1900;

  final local = DateTime.utc(
    year,
    month,
    int.parse(m[1]!),
    int.parse(m[4]!),
    int.parse(m[5]!),
    int.parse(m[6] ?? '0'),
  );

  return local.subtract(_offset(m[7]));
}

// How far the zone is ahead of UTC. GMT, UT, Z and any zone not known are
// taken as UTC.

Duration _offset(String? zone) {
  if (zone == null) return Duration.zero;

  if (zone.startsWith('+') || zone.startsWith('-')) {
    final sign = zone.startsWith('-') ? -1 : 1;
    final hours = int.parse(zone.substring(1, 3));
    final minutes = int.parse(zone.substring(3, 5));
    return Duration(minutes: sign * (hours * 60 + minutes));
  }

  return Duration(hours: _zones[zone.toUpperCase()] ?? 0);
}
