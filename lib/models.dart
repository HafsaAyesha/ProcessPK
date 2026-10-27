class GuideSource {
  final String name;
  final String url;

  const GuideSource({required this.name, required this.url});

  factory GuideSource.fromJson(Map<String, dynamic> json) =>
      GuideSource(name: json['name'] as String, url: json['url'] as String);

  Map<String, dynamic> toJson() => {'name': name, 'url': url};
}

/// The text of a guide in one language.
class GuideText {
  final String title;
  final String summary;
  final String what;
  final String who;
  final List<String> documents;
  final String fees;
  final String time;
  final List<String> steps;
  final List<String> mistakes;

  const GuideText({
    required this.title,
    required this.summary,
    required this.what,
    required this.who,
    required this.documents,
    required this.fees,
    required this.time,
    required this.steps,
    required this.mistakes,
  });

  factory GuideText.fromJson(Map<String, dynamic> json) {
    List<String> list(String key) =>
        (json[key] as List? ?? const []).map((e) => e.toString()).toList();
    return GuideText(
      title: json['title'] as String,
      summary: json['summary'] as String? ?? '',
      what: json['what'] as String? ?? '',
      who: json['who'] as String? ?? '',
      documents: list('documents'),
      fees: json['fees'] as String? ?? '',
      time: json['time'] as String? ?? '',
      steps: list('steps'),
      mistakes: list('mistakes'),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'summary': summary,
    'what': what,
    'who': who,
    'documents': documents,
    'fees': fees,
    'time': time,
    'steps': steps,
    'mistakes': mistakes,
  };
}

class Guide {
  final String id;
  final String category;
  final bool popular;
  final List<String> keywords;

  /// ISO date (yyyy-mm-dd) the guide was last checked against official
  /// sources, or null if it has not been verified yet.
  final String? lastVerified;
  final List<GuideSource> sources;
  final GuideText en;
  final GuideText ur;

  const Guide({
    required this.id,
    required this.category,
    required this.popular,
    required this.keywords,
    required this.lastVerified,
    required this.sources,
    required this.en,
    required this.ur,
  });

  GuideText text(String lang) => lang == 'ur' ? ur : en;

  factory Guide.fromJson(Map<String, dynamic> json) => Guide(
    id: json['id'] as String,
    category: json['category'] as String,
    popular: json['popular'] as bool? ?? false,
    keywords: (json['keywords'] as List? ?? const [])
        .map((e) => e.toString())
        .toList(),
    lastVerified: json['lastVerified'] as String?,
    sources: (json['sources'] as List? ?? const [])
        .map((e) => GuideSource.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    en: GuideText.fromJson(Map<String, dynamic>.from(json['en'])),
    ur: GuideText.fromJson(Map<String, dynamic>.from(json['ur'])),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'category': category,
    'popular': popular,
    'keywords': keywords,
    'lastVerified': lastVerified,
    'sources': sources.map((s) => s.toJson()).toList(),
    'en': en.toJson(),
    'ur': ur.toJson(),
  };

  /// True when [query] matches the title, summary or keywords in either
  /// language, so Urdu, English and Roman Urdu searches all work.
  bool matches(String query) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return true;
    final haystack = [
      en.title,
      en.summary,
      ur.title,
      ur.summary,
      ...keywords,
    ].join(' ').toLowerCase();
    return q.split(RegExp(r'\s+')).every(haystack.contains);
  }
}

/// What the user has ticked off for one guide. Stored on the device only.
class GuideProgress {
  final Set<int> documents;
  final Set<int> steps;
  final DateTime updatedAt;

  GuideProgress({Set<int>? documents, Set<int>? steps, DateTime? updatedAt})
    : documents = documents ?? <int>{},
      steps = steps ?? <int>{},
      updatedAt = updatedAt ?? DateTime.now();

  double fraction(Guide guide) {
    final total = guide.en.documents.length + guide.en.steps.length;
    if (total == 0) return 0;
    return (documents.length + steps.length) / total;
  }

  factory GuideProgress.fromJson(Map<String, dynamic> json) => GuideProgress(
    documents: (json['documents'] as List).cast<int>().toSet(),
    steps: (json['steps'] as List).cast<int>().toSet(),
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'documents': documents.toList(),
    'steps': steps.toList(),
    'updatedAt': updatedAt.toIso8601String(),
  };
}
