import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/paper.dart';
import '../models/news_item.dart';
import '../state/app_state.dart';
import 'reader_page.dart';
import 'widgets.dart';

class CompareTab extends StatefulWidget {
  const CompareTab({super.key});

  @override
  State<CompareTab> createState() => _CompareTabState();
}

class _CompareTabState extends State<CompareTab> {
  Paper? _paper1;
  Paper? _paper2;
  List<NewsItem> _news1 = [];
  List<NewsItem> _news2 = [];
  bool _loading1 = false;
  bool _loading2 = false;

  Future<void> _loadPaper(int which, Paper paper) async {
    setState(() {
      if (which == 1) {
        _paper1 = paper;
        _loading1 = true;
        _news1 = [];
      } else {
        _paper2 = paper;
        _loading2 = true;
        _news2 = [];
      }
    });

    final state = context.read<AppState>();
    final news = await state.fetchPaperNews(paper);

    if (!mounted) return;
    setState(() {
      if (which == 1) {
        _news1 = news.take(10).toList();
        _loading1 = false;
      } else {
        _news2 = news.take(10).toList();
        _loading2 = false;
      }
    });
  }

  void _selectPaper(int which) async {
    final state = context.read<AppState>();
    final papers = state.papers;

    final selected = await showModalBottomSheet<Paper>(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (_, controller) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                which == 1 ? 'প্রথম পত্রিকা বাছুন' : 'দ্বিতীয় পত্রিকা বাছুন',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            Expanded(
              child: ListView.builder(
                controller: controller,
                itemCount: papers.length,
                itemBuilder: (_, i) {
                  final p = papers[i];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Color(
                        int.parse(p.color.replaceFirst('#', '0xFF')),
                      ).withOpacity(0.2),
                      child: Text(
                        p.nameBn.isNotEmpty ? p.nameBn[0] : '?',
                        style: TextStyle(
                          color: Color(
                            int.parse(p.color.replaceFirst('#', '0xFF')),
                          ),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(p.nameBn),
                    subtitle: Text(p.name),
                    onTap: () => Navigator.pop(ctx, p),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );

    if (selected != null) {
      await _loadPaper(which, selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
          child: Text(
            'দুটো পত্রিকার খবর পাশাপাশি তুলনা করুন',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),

        // Paper selectors
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: [
              Expanded(
                child: _PaperSelector(
                  label: _paper1?.nameBn ?? 'পত্রিকা ১ বাছুন',
                  color: _paper1 != null
                      ? Color(int.parse(_paper1!.color.replaceFirst('#', '0xFF')))
                      : null,
                  onTap: () => _selectPaper(1),
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                child: Icon(Icons.compare_arrows, size: 28),
              ),
              Expanded(
                child: _PaperSelector(
                  label: _paper2?.nameBn ?? 'পত্রিকা ২ বাছুন',
                  color: _paper2 != null
                      ? Color(int.parse(_paper2!.color.replaceFirst('#', '0xFF')))
                      : null,
                  onTap: () => _selectPaper(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),

        // News comparison
        Expanded(
          child: (_paper1 == null && _paper2 == null)
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.compare_arrows,
                          size: 64, color: theme.colorScheme.outline),
                      const SizedBox(height: 16),
                      const Text('উপরে থেকে দুটো পত্রিকা বাছুন'),
                      const SizedBox(height: 8),
                      Text(
                        'তাদের শীর্ষ খবর পাশাপাশি দেখতে পারবেন',
                        style: TextStyle(color: theme.colorScheme.outline),
                      ),
                    ],
                  ),
                )
              : Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Left column
                    Expanded(
                      child: _NewsColumn(
                        paper: _paper1,
                        news: _news1,
                        loading: _loading1,
                        onTapNews: (n) => _openNews(n),
                      ),
                    ),
                    Container(
                      width: 1,
                      color: theme.dividerColor,
                    ),
                    // Right column
                    Expanded(
                      child: _NewsColumn(
                        paper: _paper2,
                        news: _news2,
                        loading: _loading2,
                        onTapNews: (n) => _openNews(n),
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }

  void _openNews(NewsItem news) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => ReaderPage(news: news)),
    );
  }
}

class _PaperSelector extends StatelessWidget {
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _PaperSelector({
    required this.label,
    this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: (color ?? Theme.of(context).colorScheme.primaryContainer)
          .withOpacity(0.3),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          child: Row(
            children: [
              Icon(Icons.newspaper,
                  size: 18, color: color ?? Theme.of(context).colorScheme.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: color ?? Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
              Icon(Icons.arrow_drop_down,
                  color: color ?? Theme.of(context).colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}

class _NewsColumn extends StatelessWidget {
  final Paper? paper;
  final List<NewsItem> news;
  final bool loading;
  final ValueChanged<NewsItem> onTapNews;

  const _NewsColumn({
    this.paper,
    required this.news,
    required this.loading,
    required this.onTapNews,
  });

  @override
  Widget build(BuildContext context) {
    if (paper == null) {
      return Center(
        child: Text(
          'পত্রিকা\nবাছুন',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (news.isEmpty) {
      return Center(
        child: Text(
          'খবর\nপাওয়া\nযায়নি',
          textAlign: TextAlign.center,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(8),
      itemCount: news.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = news[index];
        return InkWell(
          onTap: () => onTapNews(item),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${index + 1}. ${item.title}',
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w500,
                        height: 1.35,
                      ),
                ),
                if (item.publishedAt != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    _timeAgo(item.publishedAt!),
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return '${diff.inMinutes} মি আগে';
    if (diff.inHours < 24) return '${diff.inHours} ঘণ্টা আগে';
    return '${diff.inDays} দিন আগে';
  }
}
