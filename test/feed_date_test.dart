/// Tests for reading the dates feeds write.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/utils/feed_date.dart';

void main() {
  test('RFC 822 dates with numeric and named zones', () {
    expect(
      parseFeedDate('Mon, 02 Nov 2026 01:18:23 +0000'),
      DateTime.utc(2026, 11, 2, 1, 18, 23),
    );
    expect(
      parseFeedDate('Mon, 02 Nov 2026 01:18:27 GMT'),
      DateTime.utc(2026, 11, 2, 1, 18, 27),
    );
    expect(
      parseFeedDate('Mon, 02 Nov 2026 12:00:00 +1100'),
      DateTime.utc(2026, 11, 2, 1),
    );
    expect(
      parseFeedDate('Sun, 01 Nov 2026 20:00:00 EST'),
      DateTime.utc(2026, 11, 2, 1),
    );
  });

  test('RFC 822 dates without the weekday or seconds, or a short year', () {
    expect(parseFeedDate('2 Nov 26 01:18 Z'), DateTime.utc(2026, 11, 2, 1, 18));
  });

  test('ISO 8601 dates as Atom writes them', () {
    expect(
      parseFeedDate('2026-11-02T01:08:49Z'),
      DateTime.utc(2026, 11, 2, 1, 8, 49),
    );
    expect(
      parseFeedDate('2026-11-02T12:08:49+11:00'),
      DateTime.utc(2026, 11, 2, 1, 8, 49),
    );
  });

  test('anything else is no date', () {
    expect(parseFeedDate(null), isNull);
    expect(parseFeedDate(''), isNull);
    expect(parseFeedDate('yesterday'), isNull);
    expect(parseFeedDate('Mon, 02 Foo 2026 01:18:23 GMT'), isNull);
  });
}
