import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'config.dart';
import 'models.dart';

class AskResult {
  final String answer;
  final String guideTitle;
  final String? lastVerified;
  final List<GuideSource> sources;

  const AskResult({
    required this.answer,
    required this.guideTitle,
    required this.lastVerified,
    required this.sources,
  });
}

/// One earlier question and answer, sent so follow-ups make sense.
class AskTurn {
  final String question;
  final String answer;

  const AskTurn(this.question, this.answer);

  Map<String, String> toJson() => {'q': question, 'a': answer};
}

enum AskError { limitReached, busy, failed }

class AskException implements Exception {
  final AskError error;
  const AskException(this.error);
}

/// Sends questions to the ProcessPK Worker, which answers from the guide's
/// own content with Gemini. Keeps a per-day question count on the phone.
class AskService {
  final SharedPreferences prefs;
  final http.Client client;
  final String endpoint;
  final int dailyLimit;

  AskService({
    required this.prefs,
    http.Client? client,
    this.endpoint = AppConfig.aiEndpoint,
    this.dailyLimit = AppConfig.aiDailyLimit,
  }) : client = client ?? http.Client();

  bool get enabled => endpoint.isNotEmpty;

  String get _todayKey {
    final now = DateTime.now();
    return 'ai_count_${now.year}-${now.month}-${now.day}';
  }

  int get remainingToday =>
      (dailyLimit - (prefs.getInt(_todayKey) ?? 0)).clamp(0, dailyLimit);

  Future<AskResult> ask({
    required String guideId,
    required String question,
    required String lang,
    List<AskTurn> history = const [],
  }) async {
    if (remainingToday <= 0) throw const AskException(AskError.limitReached);
    final http.Response res;
    try {
      res = await client
          .post(
            Uri.parse('$endpoint/ask'),
            headers: {'Content-Type': 'application/json'},
            body: jsonEncode({
              'guideId': guideId,
              'question': question,
              'lang': lang,
              if (history.isNotEmpty)
                'history': [for (final t in history) t.toJson()],
            }),
          )
          .timeout(const Duration(seconds: 30));
    } catch (_) {
      throw const AskException(AskError.failed);
    }
    if (res.statusCode == 429) throw const AskException(AskError.busy);
    if (res.statusCode != 200) throw const AskException(AskError.failed);

    final body = jsonDecode(utf8.decode(res.bodyBytes)) as Map<String, dynamic>;
    await prefs.setInt(_todayKey, (prefs.getInt(_todayKey) ?? 0) + 1);
    return AskResult(
      answer: body['answer'] as String,
      guideTitle: body['guideTitle'] as String? ?? '',
      lastVerified: body['lastVerified'] as String?,
      sources: (body['sources'] as List? ?? const [])
          .map((e) => GuideSource.fromJson(Map<String, dynamic>.from(e)))
          .toList(),
    );
  }
}
