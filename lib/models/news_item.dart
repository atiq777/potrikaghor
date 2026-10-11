class NewsItem {
  final String id;
  final String title;
  final String? description;
  final String link;
  final String? imageUrl;
  final DateTime? publishedAt;
  final String paperId;
  final String paperName;
  final String paperNameBn;
  final List<String> categories;
  final bool isOffline;
  final String? offlineContent;

  NewsItem({
    required this.id,
    required this.title,
    this.description,
    required this.link,
    this.imageUrl,
    this.publishedAt,
    required this.paperId,
    required this.paperName,
    required this.paperNameBn,
    this.categories = const [],
    this.isOffline = false,
    this.offlineContent,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'link': link,
        'imageUrl': imageUrl,
        'publishedAt': publishedAt?.toIso8601String(),
        'paperId': paperId,
        'paperName': paperName,
        'paperNameBn': paperNameBn,
        'categories': categories,
        'isOffline': isOffline,
        'offlineContent': offlineContent,
      };

  factory NewsItem.fromJson(Map<String, dynamic> json) => NewsItem(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'],
        link: json['link'] ?? '',
        imageUrl: json['imageUrl'],
        publishedAt: json['publishedAt'] != null
            ? DateTime.tryParse(json['publishedAt'])
            : null,
        paperId: json['paperId'] ?? '',
        paperName: json['paperName'] ?? '',
        paperNameBn: json['paperNameBn'] ?? '',
        categories: List<String>.from(json['categories'] ?? []),
        isOffline: json['isOffline'] ?? false,
        offlineContent: json['offlineContent'],
      );

  NewsItem copyWith({
    String? id,
    String? title,
    String? description,
    String? link,
    String? imageUrl,
    DateTime? publishedAt,
    String? paperId,
    String? paperName,
    String? paperNameBn,
    List<String>? categories,
    bool? isOffline,
    String? offlineContent,
  }) {
    return NewsItem(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      link: link ?? this.link,
      imageUrl: imageUrl ?? this.imageUrl,
      publishedAt: publishedAt ?? this.publishedAt,
      paperId: paperId ?? this.paperId,
      paperName: paperName ?? this.paperName,
      paperNameBn: paperNameBn ?? this.paperNameBn,
      categories: categories ?? this.categories,
      isOffline: isOffline ?? this.isOffline,
      offlineContent: offlineContent ?? this.offlineContent,
    );
  }
}
