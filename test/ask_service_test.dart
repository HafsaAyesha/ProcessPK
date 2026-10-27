import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:processpk/ask_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AskService> makeService(MockClient client, {int limit = 2}) async {
  SharedPreferences.setMockInitialValues({});
  return AskService(
    prefs: await SharedPreferences.getInstance(),
    client: client,
    endpoint: 'https://ask.example.dev',
    dailyLimit: limit,
  );
}

void main() {
  test(
    'sends the guide id and question, and counts towards the limit',
    () async {
      late Map<String, dynamic> sent;
      final service = await makeService(
        MockClient((req) async {
          expect(req.url.toString(), 'https://ask.example.dev/ask');
          sent = jsonDecode(req.body) as Map<String, dynamic>;
          return http.Response.bytes(
            utf8.encode(
              jsonEncode({
                'answer': 'فیس مفت ہے',
                'guideTitle': 'CNIC',
                'lastVerified': null,
                'sources': [
                  {'name': 'NADRA', 'url': 'https://www.nadra.gov.pk'},
                ],
              }),
            ),
            200,
            headers: {'content-type': 'application/json'},
          );
        }),
      );

      final r = await service.ask(
        guideId: 'first-cnic',
        question: 'fee?',
        lang: 'ur',
      );
      expect(sent, {'guideId': 'first-cnic', 'question': 'fee?', 'lang': 'ur'});
      expect(r.answer, 'فیس مفت ہے');
      expect(r.sources.single.name, 'NADRA');
      expect(service.remainingToday, 1);

      await service.ask(guideId: 'first-cnic', question: 'again', lang: 'en');
      expect(
        () => service.ask(guideId: 'first-cnic', question: 'x', lang: 'en'),
        throwsA(
          isA<AskException>().having(
            (e) => e.error,
            'error',
            AskError.limitReached,
          ),
        ),
      );
    },
  );

  test('maps server errors and does not use up a question', () async {
    final busy = await makeService(
      MockClient((_) async => http.Response('', 429)),
    );
    await expectLater(
      busy.ask(guideId: 'g', question: 'q', lang: 'en'),
      throwsA(
        isA<AskException>().having((e) => e.error, 'error', AskError.busy),
      ),
    );
    expect(busy.remainingToday, 2);

    final down = await makeService(
      MockClient((_) async => http.Response('', 502)),
    );
    await expectLater(
      down.ask(guideId: 'g', question: 'q', lang: 'en'),
      throwsA(
        isA<AskException>().having((e) => e.error, 'error', AskError.failed),
      ),
    );
  });
}
