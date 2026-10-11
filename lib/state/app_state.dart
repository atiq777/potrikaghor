import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import '../models/paper.dart';
import '../models/news_item.dart';
import '../data/papers.dart';
import '../utils/rss_service.dart';
import '../utils/notification_service.dart';

class AppState extends ChangeNotifier {
  static const _uuid = Uuid();

  List<Paper> _papers = [];
  List<NewsItem> _bookmarks = [];
  List<NewsItem> _favorites = [];
  List<NewsItem> _offlineArticles = [];
  List<NewsItem> _homeNews = [];
  String _selectedCategory = 'সব';
  String _searchQuery = '';
  bool _isDarkMode = false;
  bool _isLoading = false;
  Set<String> _followedPaperIds = {};
  bool _notificationsEnabled = true;

  // Getters
  List<Paper> get papers => _papers;
  List<NewsItem> get bookmarks => _bookmarks;
  List<NewsItem> get favorites => _favorites;
  List<NewsItem> get offlineArticles => _offlineArticles;
  List<NewsItem> get homeNews => _filteredHomeNews;
  String get selectedCategory => _selectedCategory;
  String get searchQuery => _searchQuery;
  bool get isDarkMode => _isDarkMode;
  bool get isLoading => _isLoading;
  Set<String> get followedPaperIds => _followedPaperIds;
  bool get notificationsEnabled => _notificationsEnabled;

  List<NewsItem> get _filteredHomeNews {
    var list = _homeNews;
    if (_selectedCategory != 'সব') {
      list = list
          .where((n) => n.categories.contains(_selectedCategory))
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((n) =>
              n.title.toLowerCase().contains(q) ||
              n.paperNameBn.toLowerCase().contains(q) ||
              (n.description?.toLowerCase().contains(q) ?? false))
          .toList();
    }
    return list;
  }

  List<Paper> get filteredPapers {
    var list = _papers;
    if (_selectedCategory != 'সব') {
      list = list
          .where((p) => p.categories.contains(_selectedCategory))
          .toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list
          .where((p) =>
              p.name.toLowerCase().contains(q) ||
              p.nameBn.toLowerCase().contains(q))
          .toList();
    }
    return list;
  }

  Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox('offline_articles');
    await Hive.openBox('bookmarks');
    await Hive.openBox('favorites');
    await Hive.openBox('settings');

    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool('isDarkMode') ?? false;
    _notificationsEnabled = prefs.getBool('notificationsEnabled') ?? true;
    _followedPaperIds = (prefs.getStringList('followedPapers') ?? []).toSet();

    // Load papers
    _papers = List.from(PapersData.defaultPapers);
    final customJson = prefs.getString('customPapers');
    if (customJson != null) {
      try {
        final list = jsonDecode(customJson) as List;
        for (final item in list) {
          _papers.add(Paper.fromJson(item));
        }
      } catch (_) {}
    }

    // Load offline, bookmarks, favorites
    await _loadFromHive();

    // Initial news load
    await refreshHomeNews();
    notifyListeners();
  }

  Future<void> _loadFromHive() async {
    final offlineBox = Hive.box('offline_articles');
    _offlineArticles = offlineBox.values
        .map((e) => NewsItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final bookmarkBox = Hive.box('bookmarks');
    _bookmarks = bookmarkBox.values
        .map((e) => NewsItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();

    final favBox = Hive.box('favorites');
    _favorites = favBox.values
        .map((e) => NewsItem.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  Future<void> refreshHomeNews() async {
    _isLoading = true;
    notifyListeners();

    final List<NewsItem> allNews = [];
    final papersToFetch = _papers.take(8).toList(); // limit for performance

    for (final paper in papersToFetch) {
      try {
        final items = await RssService.fetchNews(paper);
        allNews.addAll(items);
      } catch (_) {}
    }

    allNews.sort((a, b) {
      if (a.publishedAt == null) return 1;
      if (b.publishedAt == null) return -1;
      return b.publishedAt!.compareTo(a.publishedAt!);
    });

    _homeNews = allNews;
    _isLoading = false;
    notifyListeners();

    // Check for notifications
    if (_notificationsEnabled && _followedPaperIds.isNotEmpty) {
      _checkAndNotify();
    }
  }

  Future<void> _checkAndNotify() async {
    for (final paperId in _followedPaperIds) {
      final paper = _papers.where((p) => p.id == paperId).firstOrNull;
      if (paper == null) continue;
      final latest = _homeNews.where((n) => n.paperId == paperId).take(1);
      for (final news in latest) {
        await NotificationService.showNewsNotification(
          title: paper.nameBn,
          body: news.title,
          payload: news.link,
        );
      }
    }
  }

  void setCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> toggleDarkMode() async {
    _isDarkMode = !_isDarkMode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', _isDarkMode);
    notifyListeners();
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationsEnabled', value);
    notifyListeners();
  }

  Future<void> toggleFollowPaper(String paperId) async {
    if (_followedPaperIds.contains(paperId)) {
      _followedPaperIds.remove(paperId);
    } else {
      _followedPaperIds.add(paperId);
    }
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList('followedPapers', _followedPaperIds.toList());
    notifyListeners();
  }

  // Bookmark
  Future<void> toggleBookmark(NewsItem item) async {
    final box = Hive.box('bookmarks');
    final exists = _bookmarks.any((b) => b.id == item.id);
    if (exists) {
      _bookmarks.removeWhere((b) => b.id == item.id);
      await box.delete(item.id);
    } else {
      _bookmarks.add(item);
      await box.put(item.id, item.toJson());
    }
    notifyListeners();
  }

  bool isBookmarked(String id) => _bookmarks.any((b) => b.id == id);

  // Favorite
  Future<void> toggleFavorite(NewsItem item) async {
    final box = Hive.box('favorites');
    final exists = _favorites.any((f) => f.id == item.id);
    if (exists) {
      _favorites.removeWhere((f) => f.id == item.id);
      await box.delete(item.id);
    } else {
      _favorites.add(item);
      await box.put(item.id, item.toJson());
    }
    notifyListeners();
  }

  bool isFavorite(String id) => _favorites.any((f) => f.id == id);

  // Offline
  Future<void> saveOffline(NewsItem item, {String? content}) async {
    final offlineItem = item.copyWith(
      isOffline: true,
      offlineContent: content ?? item.description,
    );
    final box = Hive.box('offline_articles');
    await box.put(item.id, offlineItem.toJson());
    if (!_offlineArticles.any((o) => o.id == item.id)) {
      _offlineArticles.add(offlineItem);
    }
    notifyListeners();
  }

  Future<void> removeOffline(String id) async {
    final box = Hive.box('offline_articles');
    await box.delete(id);
    _offlineArticles.removeWhere((o) => o.id == id);
    notifyListeners();
  }

  bool isOffline(String id) => _offlineArticles.any((o) => o.id == id);

  // Custom paper
  Future<void> addCustomPaper(Paper paper) async {
    final newPaper = paper.copyWith(id: _uuid.v4(), isCustom: true);
    _papers.add(newPaper);
    await _saveCustomPapers();
    notifyListeners();
  }

  Future<void> removeCustomPaper(String id) async {
    _papers.removeWhere((p) => p.id == id && p.isCustom);
    await _saveCustomPapers();
    notifyListeners();
  }

  Future<void> _saveCustomPapers() async {
    final custom = _papers.where((p) => p.isCustom).map((p) => p.toJson()).toList();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('customPapers', jsonEncode(custom));
  }

  Future<List<NewsItem>> fetchPaperNews(Paper paper) async {
    return await RssService.fetchNews(paper);
  }
}
