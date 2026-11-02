/// Tests for the JSON files kept on the Pod.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/services/pod_json.dart';

void main() {
  test('JSON written to a file reads back the same', () {
    const json = [
      {'url': 'https://example.com/rss', 'title': 'Say "hello"'},
      'https://www.bbc.co.uk/news/articles/one?at_medium=RSS&at_campaign=rss',
    ];

    expect(jsonFromTurtle(jsonTurtle('feeds.ttl', json)), json);
    expect(jsonFromTurtle(jsonTurtle('feeds.ttl', [])), isEmpty);
  });

  test('the file is Turtle in the newspod vocabulary', () {
    final ttl = jsonTurtle('feeds.ttl', []);

    expect(ttl, startsWith('@prefix newspod:'));
    expect(ttl, contains('newspod:feeds a newspod:Data'));
  });

  test('an empty file has nothing, and anything else is refused', () {
    expect(jsonFromTurtle('  \n'), isNull);
    expect(() => jsonFromTurtle('<html></html>'), throwsFormatException);
  });
}
