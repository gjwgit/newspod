/// Tests for how long ago a story was published.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/utils/time_ago.dart';

void main() {
  final now = DateTime(2026, 11, 2, 12);

  test('minutes, hours and days for the last week', () {
    expect(timeAgo(now.subtract(const Duration(seconds: 20)), now), 'now');
    expect(timeAgo(now.subtract(const Duration(minutes: 5)), now), '5m');
    expect(timeAgo(now.subtract(const Duration(hours: 3)), now), '3h');
    expect(timeAgo(now.subtract(const Duration(days: 2)), now), '2d');
  });

  test('the date after a week, with the year when it is another year', () {
    expect(timeAgo(DateTime(2026, 10, 1, 9), now), '1 Oct');
    expect(timeAgo(DateTime(2025, 10, 1, 9), now), '1 Oct 2025');
  });
}
