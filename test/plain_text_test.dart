/// Tests for feed text without its HTML.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/utils/plain_text.dart';

void main() {
  test('tags go, entities decode and white space runs together', () {
    expect(
      plainText('<p>Fish &amp; chips</p>\n<p>  for <strong>two</strong></p>'),
      'Fish & chips for two',
    );
  });

  test('plain text is unchanged', () {
    expect(plainText('Nothing to strip.'), 'Nothing to strip.');
  });
}
