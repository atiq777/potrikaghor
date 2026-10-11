import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/news_item.dart';
import '../state/app_state.dart';
import 'share_card.dart';

class ReaderPage extends StatefulWidget {
  final NewsItem news;

  const ReaderPage({super.key, required this.news});

  @override
  State<ReaderPage> createState() => _ReaderPageState();
}

class _ReaderPageState extends State<ReaderPage> {
  WebViewController? _controller;
  bool _isLoading = true;
  double _progress = 0;
  bool _useOfflineView = false;

  @override
  void initState() {
    super.initState();
    // If this item already has offline content, show offline view first
    final state = context.read<AppState>();
    final offlineItem = state.offlineArticles
        .where((o) => o.id == widget.news.id)
        .firstOrNull;

    if (offlineItem != null &&
        (offlineItem.offlineContent?.isNotEmpty ?? false)) {
      _useOfflineView = true;
      _isLoading = false;
    } else {
      _initWebView();
    }
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onProgress: (p) {
          if (mounted) setState(() => _progress = p / 100);
        },
        onPageStarted: (_) {
          if (mounted) setState(() => _isLoading = true);
        },
        onPageFinished: (_) {
          if (mounted) setState(() => _isLoading = false);
        },
        onWebResourceError: (_) {
          // Network error → try offline if available
          final state = context.read<AppState>();
          if (state.isOffline(widget.news.id)) {
            if (mounted) setState(() => _useOfflineView = true);
          }
        },
      ))
      ..loadRequest(Uri.parse(widget.news.link));
  }

  Future<void> _saveOffline() async {
    final state = context.read<AppState>();
    final content = widget.news.description ??
        widget.news.title +
            '\n\n(অফলাইনে সেভ করা হয়েছে। পূর্ণ আর্টিকেল দেখতে ইন্টারনেট লাগবে।)';

    await state.saveOffline(widget.news, content: content);

    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('অফলাইনে সেভ করা হয়েছে ✓\nঅফলাইন ট্যাব থেকে পড়তে পারবেন'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  Future<void> _removeOffline() async {
    final state = context.read<AppState>();
    await state.removeOffline(widget.news.id);
    if (mounted) {
      setState(() => _useOfflineView = false);
      if (_controller == null) _initWebView();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('অফলাইন থেকে মুছে ফেলা হয়েছে')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final news = widget.news;
    final isBookmarked = state.isBookmarked(news.id);
    final isFavorite = state.isFavorite(news.id);
    final isOffline = state.isOffline(news.id);

    // Get offline content if available
    final offlineItem = state.offlineArticles
        .where((o) => o.id == news.id)
        .firstOrNull;
    final offlineContent = offlineItem?.offlineContent ?? news.description;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          news.paperNameBn,
          style: const TextStyle(fontSize: 16),
        ),
        actions: [
          IconButton(
            icon: Icon(isBookmarked ? Icons.bookmark : Icons.bookmark_border),
            tooltip: 'বুকমার্ক',
            onPressed: () => state.toggleBookmark(news),
          ),
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? Colors.red : null,
            ),
            tooltip: 'ফেভারিট',
            onPressed: () => state.toggleFavorite(news),
          ),
          IconButton(
            icon: Icon(
              isOffline
                  ? Icons.offline_pin
                  : Icons.download_for_offline_outlined,
              color: isOffline ? Colors.green : null,
            ),
            tooltip: isOffline ? 'অফলাইন থেকে মুছুন' : 'অফলাইনে সেভ করুন',
            onPressed: isOffline ? _removeOffline : _saveOffline,
          ),
          IconButton(
            icon: const Icon(Icons.share),
            tooltip: 'শেয়ার',
            onPressed: () => ShareCard.showSharePreview(context, news),
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              if (value == 'browser') {
                final uri = Uri.parse(news.link);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              } else if (value == 'toggle_view') {
                setState(() {
                  _useOfflineView = !_useOfflineView;
                  if (!_useOfflineView && _controller == null) {
                    _initWebView();
                  }
                });
              }
            },
            itemBuilder: (_) => [
              const PopupMenuItem(
                value: 'browser',
                child: Text('ব্রাউজারে খুলুন'),
              ),
              if (isOffline)
                PopupMenuItem(
                  value: 'toggle_view',
                  child: Text(_useOfflineView
                      ? 'অনলাইন ভিউ দেখুন'
                      : 'অফলাইন ভিউ দেখুন'),
                ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading && !_useOfflineView)
            LinearProgressIndicator(value: _progress > 0 ? _progress : null),
          Expanded(
            child: _useOfflineView
                ? _buildOfflineView(news, offlineContent)
                : (_controller != null
                    ? WebViewWidget(controller: _controller!)
                    : const Center(child: CircularProgressIndicator())),
          ),
        ],
      ),
    );
  }

  Widget _buildOfflineView(NewsItem news, String? content) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.offline_pin, size: 18, color: Colors.green),
                SizedBox(width: 6),
                Text(
                  'অফলাইন মোড',
                  style: TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            news.title,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  height: 1.3,
                ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                news.paperNameBn,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (news.publishedAt != null) ...[
                const Text('  •  '),
                Text(
                  _formatDate(news.publishedAt!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ],
          ),
          const Divider(height: 32),
          Text(
            content?.isNotEmpty == true
                ? content!
                : 'কনটেন্ট সেভ করা নেই। ইন্টারনেট চালু করে আবার সেভ করুন।',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  height: 1.7,
                  fontSize: 16,
                ),
          ),
          const SizedBox(height: 32),
          if (content?.isNotEmpty == true)
            Center(
              child: OutlinedButton.icon(
                onPressed: () {
                  setState(() {
                    _useOfflineView = false;
                    if (_controller == null) _initWebView();
                  });
                },
                icon: const Icon(Icons.language),
                label: const Text('অনলাইন ভার্সন দেখুন'),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
