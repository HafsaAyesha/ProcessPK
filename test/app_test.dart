import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:processpk/app_state.dart';
import 'package:processpk/guide_repository.dart';
import 'package:processpk/main.dart';
import 'package:processpk/models.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> makeState([Map<String, Object> prefs = const {}]) async {
  SharedPreferences.setMockInitialValues(prefs);
  final state = AppState(
    prefs: await SharedPreferences.getInstance(),
    repository: GuideRepository(firebaseReady: false),
  );
  await state.load();
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every guide has matching English and Urdu content', () {
    final data = jsonDecode(File('assets/guides.json').readAsStringSync());
    final guides = (data['guides'] as List)
        .map((g) => Guide.fromJson(g))
        .toList();
    expect(guides, isNotEmpty);
    expect(guides.map((g) => g.id).toSet().length, guides.length);
    for (final g in guides) {
      expect(g.ur.documents.length, g.en.documents.length, reason: g.id);
      expect(g.ur.steps.length, g.en.steps.length, reason: g.id);
      expect(g.ur.mistakes.length, g.en.mistakes.length, reason: g.id);
      expect(g.sources, isNotEmpty, reason: g.id);
      expect(g.en.problems, isNotEmpty, reason: g.id);
      expect(g.ur.problems.length, g.en.problems.length, reason: g.id);
      expect(g.contacts, isNotEmpty, reason: g.id);
      for (final c in g.contacts) {
        expect(c.phone ?? c.email ?? c.url ?? c.note, isNotNull, reason: g.id);
      }
    }
  });

  test('search works in English, Urdu and Roman Urdu', () async {
    final state = await makeState();
    expect(
      state.search('passport').map((g) => g.id),
      contains('first-passport'),
    );
    expect(state.search('شناختی').map((g) => g.id), contains('first-cnic'));
    expect(
      state.search('shanakhti card').map((g) => g.id),
      contains('first-cnic'),
    );
    expect(state.search('zzzz'), isEmpty);
  });

  test('checklist progress is saved and restored', () async {
    final state = await makeState();
    await state.startChecklist('first-cnic');
    await state.toggleDocument('first-cnic', 0);
    await state.toggleStep('first-cnic', 1);
    await state.setNotes('first-cnic', 'Tracking 1234');
    final saved = state.prefs.getString('progress_v1')!;

    final restored = await makeState({'progress_v1': saved});
    final p = restored.progress['first-cnic']!;
    expect(p.documents, {0});
    expect(p.steps, {1});
    expect(p.notes, 'Tracking 1234');
    expect(restored.activeChecklists.single.key.id, 'first-cnic');
  });

  testWidgets('intro, open a guide, start and tick a checklist', (
    tester,
  ) async {
    final state = (await tester.runAsync(makeState))!;
    await tester.pumpWidget(ProcessPKApp(state: state, useGoogleFonts: false));
    await tester.pumpAndSettle();

    expect(find.text('Continue'), findsOneWidget);
    await tester.tap(find.text('Continue'));
    await tester.pumpAndSettle();

    await tester.scrollUntilVisible(
      find.text('Get your first CNIC'),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.tap(find.text('Get your first CNIC'));
    await tester.pumpAndSettle();
    expect(find.text('Required documents'), findsOneWidget);

    await tester.tap(find.text('Start checklist'));
    await tester.pumpAndSettle();
    await tester.tap(find.byType(Checkbox).first);
    await tester.pumpAndSettle();
    expect(state.progress['first-cnic']!.documents, {0});
    expect(find.textContaining('% done'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('My notes'),
      300,
      scrollable: find.byType(Scrollable).first,
    );
    expect(find.text('My notes'), findsOneWidget);
  });

  testWidgets('Urdu switches text and layout direction', (tester) async {
    final state = (await tester.runAsync(
      () => makeState({'intro_seen': true, 'lang': 'ur'}),
    ))!;
    await tester.pumpWidget(ProcessPKApp(state: state, useGoogleFonts: false));
    await tester.pumpAndSettle();

    expect(find.text('زمرے'), findsOneWidget);
    final dir = Directionality.of(tester.element(find.text('زمرے')));
    expect(dir, TextDirection.rtl);
  });
}
