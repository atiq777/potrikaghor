import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import 'widgets.dart';
import 'reader_page.dart';

class OfflineTab extends StatelessWidget {
  const OfflineTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final items = state.offlineArticles;

    if (items.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.offline_pin_outlined, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('কোনো অফলাইন আর্টিকেল নেই'),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'খবর পড়ার সময় ডাউনলোড আইকনে ট্যাপ করে অফলাইনে সেভ করুন',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final news = items[index];
        return Dismissible(
          key: Key(news.id),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            child: const Icon(Icons.delete, color: Colors.white),
          ),
          onDismissed: (_) => state.removeOffline(news.id),
          child: NewsCard(
            news: news,
            isBookmarked: state.isBookmarked(news.id),
            isFavorite: state.isFavorite(news.id),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReaderPage(news: news)),
              );
            },
            onBookmark: () => state.toggleBookmark(news),
            onFavorite: () => state.toggleFavorite(news),
          ),
        );
      },
    );
  }
}
