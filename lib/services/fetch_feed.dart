/// Fetch a feed from the web and read it.
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

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:http/http.dart' as http;

import 'package:newspod/utils/feed_parser.dart';

/// Fetch the feed at [url] and read its stories, crediting them to [source].

Future<ParsedFeed> fetchFeed(String url, {String source = ''}) async =>
    parseFeed(await fetchText(url), source: source);

/// Fetch the text at [url], a feed, a web page or a search's answer.

Future<String> fetchText(String url) async {
  final response = await http
      .get(
        Uri.parse(url),

        // A browser will not let a page set its own User-Agent.
        headers: kIsWeb
            ? null
            : {'User-Agent': 'NewsPod (+https://github.com/gjwgit/newspod)'},
      )
      .timeout(const Duration(seconds: 20));

  if (response.statusCode != 200) {
    throw FormatException(
      'The site answered with error ${response.statusCode}.',
    );
  }

  return utf8.decode(response.bodyBytes, allowMalformed: true);
}

/// Why a feed could not be read, as a sentence to show.

String feedError(Object error) => switch (error) {
  TimeoutException() => 'The site took too long to answer.',
  FormatException(:final message) => message,

  // 20261102 gjw In a browser almost every feed fails here, since the sites
  // do not allow pages from other sites to read them (CORS).
  _ when kIsWeb =>
    'The browser would not fetch it. Most sites only allow their own pages '
        'to read their feeds, so use NewsPod on a desktop or phone.',
  _ => 'Could not reach the site.',
};
