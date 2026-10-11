import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../models/paper.dart';
import '../models/news_item.dart';

class RssService {
  static const _uuid = Uuid();

  static Future<List<NewsItem>> fetchNews(Paper paper) async {
    try {
      final response = await http.get(
        Uri.parse(paper.rssUrl),
        headers: {
          'User-Agent':
              'Mozilla/5.0 (Linux; Android 13) AppleWebKit/537.36 Chrome/120.0.0.0 Mobile Safari/537.36',
          'Accept': 'application/rss+xml, application/xml, text/xml, */*',
        },
      ).timeout(const Duration(seconds: 12));

      if (response.statusCode != 200) return [];

      return _parseRss(response.body, paper);
    } catch (e) {
      // Fallback demo data if RSS fails (for offline testing)
      return _demoNews(paper);
    }
  }

  static List<NewsItem> _parseRss(String xml, Paper paper) {
    final items = <NewsItem>[];
    final itemRegex = RegExp(r'<item[^>]*>(.*?)</item>', dotAll: true);
    final matches = itemRegex.allMatches(xml);

    for (final match in matches.take(15)) {
      final itemXml = match.group(1) ?? '';
      final title = _extractTag(itemXml, 'title');
      final link = _extractTag(itemXml, 'link');
      final description = _extractTag(itemXml, 'description');
      final pubDate = _extractTag(itemXml, 'pubDate');
      final image = _extractImage(itemXml, description);

      if (title.isEmpty || link.isEmpty) continue;

      items.add(NewsItem(
        id: _uuid.v5(Uuid.NAMESPACE_URL, link),
        title: _cleanText(title),
        description: _cleanText(description),
        link: link.trim(),
        imageUrl: image,
        publishedAt: _parseDate(pubDate),
        paperId: paper.id,
        paperName: paper.name,
        paperNameBn: paper.nameBn,
        categories: paper.categories,
      ));
    }
    return items;
  }

  static String _extractTag(String xml, String tag) {
    final regex = RegExp('<$tag[^>]*><!\\[CDATA\\[(.*?)\\]\\]></$tag>',
        dotAll: true, caseSensitive: false);
    var match = regex.firstMatch(xml);
    if (match != null) return match.group(1)?.trim() ?? '';

    final regex2 =
        RegExp('<$tag[^>]*>(.*?)</$tag>', dotAll: true, caseSensitive: false);
    match = regex2.firstMatch(xml);
    return match?.group(1)?.trim() ?? '';
  }

  static String? _extractImage(String itemXml, String description) {
    // media:content or enclosure
    final media =
        RegExp(r'<media:content[^>]+url="([^"]+)"', caseSensitive: false)
            .firstMatch(itemXml);
    if (media != null) return media.group(1);

    final enclosure =
        RegExp(r'<enclosure[^>]+url="([^"]+)"', caseSensitive: false)
            .firstMatch(itemXml);
    if (enclosure != null) return enclosure.group(1);

    // img in description
    final img = RegExp(r'<img[^>]+src="([^"]+)"', caseSensitive: false)
        .firstMatch(description);
    return img?.group(1);
  }

  static String _cleanText(String text) {
    return text
        .replaceAll(RegExp(r'<[^>]+>'), '')
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&nbsp;', ' ')
        .trim();
  }

  static DateTime? _parseDate(String dateStr) {
    if (dateStr.isEmpty) return null;
    try {
      return DateTime.parse(dateStr);
    } catch (_) {
      try {
        // RFC 822 style
        return DateTime.tryParse(dateStr.replaceAll(RegExp(r' \+\d{4}'), 'Z'));
      } catch (_) {
        return null;
      }
    }
  }

  // Demo news when RSS fails (so app always has content)
  static List<NewsItem> _demoNews(Paper paper) {
    final now = DateTime.now();
    return [
      NewsItem(
        id: '${paper.id}_demo_1',
        title: '${paper.nameBn} থেকে আজকের শীর্ষ খবর',
        description:
            'এটি একটি ডেমো নিউজ। আসল RSS লোড না হলে এই কনটেন্ট দেখানো হয়। অ্যাপটি সঠিকভাবে কাজ করছে।',
        link: paper.website,
        imageUrl: null,
        publishedAt: now.subtract(const Duration(minutes: 30)),
        paperId: paper.id,
        paperName: paper.name,
        paperNameBn: paper.nameBn,
        categories: paper.categories,
      ),
      NewsItem(
        id: '${paper.id}_demo_2',
        title: '${paper.nameBn}: গুরুত্বপূর্ণ আপডেট',
        description: 'দ্বিতীয় ডেমো নিউজ আইটেম।',
        link: paper.website,
        publishedAt: now.subtract(const Duration(hours: 2)),
        paperId: paper.id,
        paperName: paper.name,
        paperNameBn: paper.nameBn,
        categories: paper.categories,
      ),
    ];
  }
}
