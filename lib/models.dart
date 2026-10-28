class GuideSource {
  final String name;
  final String url;

  const GuideSource({required this.name, required this.url});

  factory GuideSource.fromJson(Map<String, dynamic> json) =>
      GuideSource(name: json['name'] as String, url: json['url'] as String);

  Map<String, dynamic> toJson() => {'name': name, 'url': url};
}

/// An official helpline, email, website or office to contact.
class GuideContact {
  final String name;
  final String nameUr;
  final String? phone;
  final String? email;
  final String? url;
  final String? note;
  final String? noteUr;

  const GuideContact({
    required this.name,
    required this.nameUr,
    this.phone,
    this.email,
    this.url,
    this.note,
    this.noteUr,
  });

  String label(String lang) => lang == 'ur' ? nameUr : name;
  String? noteFor(String lang) => lang == 'ur' ? (noteUr ?? note) : note;

  factory GuideContact.fromJson(Map<String, dynamic> json) => GuideContact(
    name: json['name'] as String,
    nameUr: json['nameUr'] as String? ?? json['name'] as String,
    phone: json['phone'] as String?,
    email: json['email'] as String?,
    url: json['url'] as String?,
    note: json['note'] as String?,
    noteUr: json['noteUr'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'nameUr': nameUr,
    if (phone != null) 'phone': phone,
    if (email != null) 'email': email,
    if (url != null) 'url': url,
    if (note != null) 'note': note,
    if (noteUr != null) 'noteUr': noteUr,
  };
}

/// A problem people commonly run into, and how to get past it.
class GuideProblem {
  final String problem;
  final String solution;

  const GuideProblem({required this.problem, required this.solution});

  factory GuideProblem.fromJson(Map<String, dynamic> json) => GuideProblem(
    problem: json['problem'] as String,
    solution: json['solution'] as String,
  );

  Map<String, dynamic> toJson() => {'problem': problem, 'solution': solution};
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
  final List<GuideProblem> problems;

  /// Key dates and deadlines, written as short lines.
  final List<String> dates;

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
    this.problems = const [],
    this.dates = const [],
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
      problems: (json['problems'] as List? ?? const [])
          .map((e) => GuideProblem.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
      dates: list('dates'),
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
    'problems': problems.map((p) => p.toJson()).toList(),
    'dates': dates,
  };
}

/// The kind of office people visit for a guide, used to search Maps for the
/// nearest one.
class GuideOffice {
  final String query;
  final String name;
  final String nameUr;
  final String? locator;

  const GuideOffice({
    required this.query,
    required this.name,
    required this.nameUr,
    this.locator,
  });

  String label(String lang) => lang == 'ur' ? nameUr : name;

  String get mapsUrl => Uri.https('www.google.com', '/maps/search/', {
    'api': '1',
    'query': '$query near me',
  }).toString();

  factory GuideOffice.fromJson(Map<String, dynamic> json) => GuideOffice(
    query: json['query'] as String,
    name: json['name'] as String,
    nameUr: json['nameUr'] as String? ?? json['name'] as String,
    locator: json['locator'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'query': query,
    'name': name,
    'nameUr': nameUr,
    if (locator != null) 'locator': locator,
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
  final List<GuideContact> contacts;
  final GuideOffice? office;
  final GuideText en;
  final GuideText ur;

  const Guide({
    required this.id,
    required this.category,
    required this.popular,
    required this.keywords,
    required this.lastVerified,
    required this.sources,
    this.contacts = const [],
    this.office,
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
    contacts: (json['contacts'] as List? ?? const [])
        .map((e) => GuideContact.fromJson(Map<String, dynamic>.from(e)))
        .toList(),
    office: json['office'] == null
        ? null
        : GuideOffice.fromJson(Map<String, dynamic>.from(json['office'])),
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
    'contacts': contacts.map((c) => c.toJson()).toList(),
    if (office != null) 'office': office!.toJson(),
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
      ...en.problems.map((p) => p.problem),
      ...ur.problems.map((p) => p.problem),
    ].join(' ').toLowerCase();
    return q.split(RegExp(r'\s+')).every(haystack.contains);
  }
}

/// What the user has ticked off for one guide. Stored on the device only.
class GuideProgress {
  final Set<int> documents;
  final Set<int> steps;

  /// The user's own notes, e.g. tracking number or appointment date.
  final String notes;
  final DateTime updatedAt;

  GuideProgress({
    Set<int>? documents,
    Set<int>? steps,
    this.notes = '',
    DateTime? updatedAt,
  }) : documents = documents ?? <int>{},
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
    notes: json['notes'] as String? ?? '',
    updatedAt: DateTime.parse(json['updatedAt'] as String),
  );

  Map<String, dynamic> toJson() => {
    'documents': documents.toList(),
    'steps': steps.toList(),
    'notes': notes,
    'updatedAt': updatedAt.toIso8601String(),
  };
}

/// A date the user wants to remember, such as a deadline or appointment.
/// Stored on the device only.
class Reminder {
  final String id;
  final String title;
  final DateTime date;
  final String? guideId;

  const Reminder({
    required this.id,
    required this.title,
    required this.date,
    this.guideId,
  });

  /// Whole days from [today] until the reminder; negative once it has passed.
  int daysLeft([DateTime? today]) {
    final now = today ?? DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return DateTime(date.year, date.month, date.day).difference(start).inDays;
  }

  /// A Google Calendar link that creates an all-day event, so the phone's
  /// calendar sends the actual notification.
  String calendarUrl({String details = ''}) {
    String fmt(DateTime d) =>
        '${d.year.toString().padLeft(4, '0')}${d.month.toString().padLeft(2, '0')}${d.day.toString().padLeft(2, '0')}';
    final end = date.add(const Duration(days: 1));
    return Uri.https('calendar.google.com', '/calendar/render', {
      'action': 'TEMPLATE',
      'text': title,
      'dates': '${fmt(date)}/${fmt(end)}',
      'details': details,
    }).toString();
  }

  factory Reminder.fromJson(Map<String, dynamic> json) => Reminder(
    id: json['id'] as String,
    title: json['title'] as String,
    date: DateTime.parse(json['date'] as String),
    guideId: json['guideId'] as String?,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'date': date.toIso8601String(),
    if (guideId != null) 'guideId': guideId,
  };
}
