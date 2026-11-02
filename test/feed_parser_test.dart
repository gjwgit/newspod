/// Tests for reading the stories from RSS and Atom feeds.

library;

import 'package:flutter_test/flutter_test.dart';

import 'package:newspod/utils/feed_parser.dart';

const _rss = """<?xml version="1.0" encoding="UTF-8"?>
<rss version="2.0" xmlns:media="http://search.yahoo.com/mrss/">
  <channel>
    <title>BBC News</title>
    <item>
      <title><![CDATA[Air raid app hacked]]></title>
      <description><![CDATA[<p>Hours later &amp; more.</p>]]></description>
      <link>https://www.bbc.co.uk/news/articles/one</link>
      <pubDate>Mon, 02 Nov 2026 01:18:27 GMT</pubDate>
      <media:thumbnail width="240" url="https://ichef.bbci.co.uk/one.jpg"/>
    </item>
    <item>
      <title>From the guid</title>
      <guid isPermaLink="true">https://example.com/two</guid>
      <media:group>
        <media:content url="https://example.com/two.jpg" medium="image"/>
      </media:group>
    </item>
    <item>
      <title>An enclosure</title>
      <link>https://example.com/three</link>
      <enclosure url="https://example.com/three.mp3" type="audio/mpeg"/>
      <enclosure url="https://example.com/three.jpg" type="image/jpeg"/>
    </item>
    <item>
      <title>No link and a guid that is not one</title>
      <guid isPermaLink="false">000001a0</guid>
    </item>
  </channel>
</rss>""";

const _atom = """<?xml version="1.0" encoding="UTF-8"?>
<feed xmlns="http://www.w3.org/2005/Atom">
  <title type="text">The Conversation</title>
  <entry>
    <published>2026-11-02T01:08:49Z</published>
    <updated>2026-11-03T01:08:49Z</updated>
    <link rel="self" href="https://example.com/self"/>
    <link rel="alternate" type="text/html" href="https://example.com/poll"/>
    <title>Labor returns to low vote</title>
    <content type="html">&lt;p&gt;Labor&#8217;s vote dropped.&lt;/p&gt;</content>
  </entry>
</feed>""";

const _rdf = """<?xml version="1.0"?>
<rdf:RDF xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns="http://purl.org/rss/1.0/" xmlns:dc="http://purl.org/dc/elements/1.1/">
  <channel><title>Old Style</title></channel>
  <item>
    <title>RDF story</title>
    <link>https://example.com/rdf</link>
    <dc:date>2026-11-02T00:00:00Z</dc:date>
  </item>
</rdf:RDF>""";

void main() {
  test('RSS 2.0: title, stories, dates and pictures', () {
    final feed = parseFeed(_rss, source: 'BBC World');

    expect(feed.title, 'BBC News');
    expect(feed.stories.map((s) => s.title), [
      'Air raid app hacked',
      'From the guid',
      'An enclosure',
    ]);

    final first = feed.stories.first;
    expect(first.source, 'BBC World');
    expect(first.summary, 'Hours later & more.');
    expect(first.published, DateTime.utc(2026, 11, 2, 1, 18, 27));
    expect(first.imageUrl, 'https://ichef.bbci.co.uk/one.jpg');

    expect(feed.stories[1].link, 'https://example.com/two');
    expect(feed.stories[1].imageUrl, 'https://example.com/two.jpg');
    expect(feed.stories[1].published, isNull);
    expect(feed.stories[2].imageUrl, 'https://example.com/three.jpg');
  });

  test('Atom: the alternate link, the content and the published date', () {
    final feed = parseFeed(_atom);
    final story = feed.stories.single;

    expect(feed.title, 'The Conversation');
    expect(story.link, 'https://example.com/poll');
    expect(story.summary, 'Labor’s vote dropped.');
    expect(story.published, DateTime.utc(2026, 11, 2, 1, 8, 49));
    expect(story.imageUrl, isNull);
  });

  test('RSS 1.0 (RDF): stories beside the channel and the dc:date', () {
    final feed = parseFeed(_rdf);

    expect(feed.title, 'Old Style');
    expect(feed.stories.single.link, 'https://example.com/rdf');
    expect(feed.stories.single.published, DateTime.utc(2026, 11, 2));
  });

  test('a web page or broken XML is not a feed', () {
    expect(
      () => parseFeed('<html><body>Hello</body></html>'),
      throwsFormatException,
    );
    expect(() => parseFeed('<rss><channel>'), throwsFormatException);
    expect(() => parseFeed(''), throwsFormatException);
  });
}
