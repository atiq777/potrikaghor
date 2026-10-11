import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../data/papers.dart';
import '../models/news_item.dart';
import '../state/app_state.dart';
import 'widgets.dart';
import 'reader_page.dart';
import 'papers_tab.dart';
import 'bookmarks_tab.dart';
import 'favorites_tab.dart';
import 'offline_tab.dart';
import 'compare_tab.dart';
import 'settings_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  final _searchController = TextEditingController();

  final _pages = const [
    _HomeNewsTab(),
    PapersTab(),
    CompareTab(),
    BookmarksTab(),
    OfflineTab(),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('পত্রিকাঘর'),
        actions: [
          if (_currentIndex == 3)
            IconButton(
              icon: const Icon(Icons.favorite),
              tooltip: 'ফেভারিট',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => Scaffold(
                      appBar: AppBar(title: const Text('ফেভারিট')),
                      body: const FavoritesTab(),
                    ),
                  ),
                );
              },
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'রিফ্রেশ',
            onPressed: () => context.read<AppState>().refreshHomeNews(),
          ),
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          if (_currentIndex == 0 || _currentIndex == 1) ...[
            SearchBarWidget(
              controller: _searchController,
              onChanged: (q) => context.read<AppState>().setSearchQuery(q),
            ),
            CategoryChips(
              categories: PapersData.allCategories,
              selected: context.watch<AppState>().selectedCategory,
              onSelected: (c) => context.read<AppState>().setCategory(c),
            ),
            const SizedBox(height: 4),
          ],
          Expanded(child: _pages[_currentIndex]),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (i) => setState(() => _currentIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'হোম',
          ),
          NavigationDestination(
            icon: Icon(Icons.newspaper_outlined),
            selectedIcon: Icon(Icons.newspaper),
            label: 'পত্রিকা',
          ),
          NavigationDestination(
            icon: Icon(Icons.compare_arrows_outlined),
            selectedIcon: Icon(Icons.compare_arrows),
            label: 'তুলনা',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_border),
            selectedIcon: Icon(Icons.bookmark),
            label: 'বুকমার্ক',
          ),
          NavigationDestination(
            icon: Icon(Icons.offline_pin_outlined),
            selectedIcon: Icon(Icons.offline_pin),
            label: 'অফলাইন',
          ),
        ],
      ),
    );
  }
}

class _HomeNewsTab extends StatelessWidget {
  const _HomeNewsTab();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.isLoading && state.homeNews.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.homeNews.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.newspaper, size: 64, color: Colors.grey),
            const SizedBox(height: 16),
            const Text('কোনো খবর পাওয়া যায়নি'),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: () => state.refreshHomeNews(),
              icon: const Icon(Icons.refresh),
              label: const Text('আবার চেষ্টা করুন'),
            ),
          ],
        ),
      );
    }

    // আজকের শীর্ষ খবর = প্রথম ৫–৮টা সবচেয়ে নতুন খবর
    final topNews = state.homeNews.take(6).toList();
    final restNews = state.homeNews.length > 6
        ? state.homeNews.sublist(6)
        : <NewsItem>[];

    return RefreshIndicator(
      onRefresh: () => state.refreshHomeNews(),
      child: ListView(
        children: [
          // ===== আজকের শীর্ষ খবর =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Row(
              children: [
                Icon(Icons.local_fire_department,
                    color: Colors.orange.shade700, size: 22),
                const SizedBox(width: 6),
                Text(
                  'আজকের শীর্ষ খবর',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: topNews.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (context, index) {
                final news = topNews[index];
                return _TopNewsCard(
                  news: news,
                  rank: index + 1,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ReaderPage(news: news)),
                    );
                  },
                );
              },
            ),
          ),

          // ===== সব খবর =====
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'সব খবর',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...topNews.map((news) => NewsCard(
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
              )),
          ...restNews.map((news) => NewsCard(
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
              )),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _TopNewsCard extends StatelessWidget {
  final NewsItem news;
  final int rank;
  final VoidCallback onTap;

  const _TopNewsCard({
    required this.news,
    required this.rank,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: 260,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Rank + paper badge
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.primary.withOpacity(0.75),
                    ],
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.25),
                        shape: BoxShape.circle,
                      ),
                      child: Text(
                        '$rank',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        news.paperNameBn,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Title
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    news.title,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      height: 1.35,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
