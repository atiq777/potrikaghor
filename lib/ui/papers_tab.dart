import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/app_state.dart';
import '../models/paper.dart';
import 'widgets.dart';
import 'reader_page.dart';
import 'add_paper_sheet.dart';

class PapersTab extends StatelessWidget {
  const PapersTab({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final papers = state.filteredPapers;

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Row(
            children: [
              Text(
                '${papers.length} টি পত্রিকা',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const Spacer(),
              FilledButton.tonalIcon(
                onPressed: () => showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  builder: (_) => const AddPaperSheet(),
                ),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('যোগ করুন'),
              ),
            ],
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(12),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.85,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: papers.length,
            itemBuilder: (context, index) {
              final paper = papers[index];
              return PaperGridCard(
                paper: paper,
                isFollowed: state.followedPaperIds.contains(paper.id),
                onFollowToggle: () => state.toggleFollowPaper(paper.id),
                onTap: () => _openPaperNews(context, paper),
              );
            },
          ),
        ),
      ],
    );
  }

  void _openPaperNews(BuildContext context, Paper paper) async {
    final state = context.read<AppState>();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    final newsList = await state.fetchPaperNews(paper);
    if (!context.mounted) return;
    Navigator.pop(context); // close loading

    if (newsList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('এই পত্রিকার খবর লোড করা যায়নি')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.85,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                paper.nameBn,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: newsList.length,
                itemBuilder: (_, i) {
                  final news = newsList[i];
                  return NewsCard(
                    news: news,
                    showPaperName: false,
                    isBookmarked: state.isBookmarked(news.id),
                    isFavorite: state.isFavorite(news.id),
                    onTap: () {
                      Navigator.pop(ctx);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => ReaderPage(news: news)),
                      );
                    },
                    onBookmark: () => state.toggleBookmark(news),
                    onFavorite: () => state.toggleFavorite(news),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
