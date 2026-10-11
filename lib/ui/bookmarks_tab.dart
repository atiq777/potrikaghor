import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'widgets.dart';
import 'reader_page.dart';

class BookmarksTab extends StatelessWidget {
  const BookmarksTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.bookmarks;

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bookmark_border, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('কোনো বুকমার্ক নেই'),
            SizedBox(height: 8),
            Text(
              'খবর পড়ার সময় বুকমার্ক আইকনে ট্যাপ করুন',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final news = items[index];
        return NewsCard(
          news: news,
          isBookmarked: true,
          isFavorite: state.isFavorite(news.id),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => ReaderPage(news: news)),
            );
          },
          onBookmark: () => state.toggleBookmark(news),
          onFavorite: () => state.toggleFavorite(news),
        );
      },
    );
  }
}
