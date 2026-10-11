class Paper {
  final String id;
  final String name;
  final String nameBn;
  final String logoUrl;
  final String rssUrl;
  final String website;
  final List<String> categories;
  final String color;
  final bool isCustom;

  const Paper({
    required this.id,
    required this.name,
    required this.nameBn,
    required this.logoUrl,
    required this.rssUrl,
    required this.website,
    required this.categories,
    this.color = '#1565C0',
    this.isCustom = false,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'nameBn': nameBn,
        'logoUrl': logoUrl,
        'rssUrl': rssUrl,
        'website': website,
        'categories': categories,
        'color': color,
        'isCustom': isCustom,
      };

  factory Paper.fromJson(Map<String, dynamic> json) => Paper(
        id: json['id'] ?? '',
        name: json['name'] ?? '',
        nameBn: json['nameBn'] ?? '',
        logoUrl: json['logoUrl'] ?? '',
        rssUrl: json['rssUrl'] ?? '',
        website: json['website'] ?? '',
        categories: List<String>.from(json['categories'] ?? []),
        color: json['color'] ?? '#1565C0',
        isCustom: json['isCustom'] ?? false,
      );

  Paper copyWith({
    String? id,
    String? name,
    String? nameBn,
    String? logoUrl,
    String? rssUrl,
    String? website,
    List<String>? categories,
    String? color,
    bool? isCustom,
  }) {
    return Paper(
      id: id ?? this.id,
      name: name ?? this.name,
      nameBn: nameBn ?? this.nameBn,
      logoUrl: logoUrl ?? this.logoUrl,
      rssUrl: rssUrl ?? this.rssUrl,
      website: website ?? this.website,
      categories: categories ?? this.categories,
      color: color ?? this.color,
      isCustom: isCustom ?? this.isCustom,
    );
  }
}
