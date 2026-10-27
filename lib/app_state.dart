import 'dart:convert';

import 'package:flutter/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'ask_service.dart';
import 'guide_repository.dart';
import 'models.dart';
import 'strings.dart';

class AppState extends ChangeNotifier {
  static const _langKey = 'lang';
  static const _introKey = 'intro_seen';
  static const _progressKey = 'progress_v1';

  final SharedPreferences prefs;
  final GuideRepository repository;

  AppState({required this.prefs, required this.repository, AskService? ask})
    : ask = ask ?? AskService(prefs: prefs);

  final AskService ask;

  List<Guide> guides = [];
  String lang = 'en';
  bool introSeen = false;
  final Map<String, GuideProgress> progress = {};

  S get s => S(lang);

  Future<void> load() async {
    lang = prefs.getString(_langKey) ?? 'en';
    introSeen = prefs.getBool(_introKey) ?? false;
    final raw = prefs.getString(_progressKey);
    if (raw != null) {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      map.forEach((id, value) {
        progress[id] = GuideProgress.fromJson(Map<String, dynamic>.from(value));
      });
    }
    guides = await repository.loadLocal(prefs);
    notifyListeners();
    // Refresh from Firestore in the background without blocking startup.
    repository.fetchRemote(prefs).then((fresh) {
      if (fresh != null) {
        guides = fresh;
        notifyListeners();
      }
    });
  }

  Guide? guideById(String id) {
    for (final g in guides) {
      if (g.id == id) return g;
    }
    return null;
  }

  List<Guide> search(String query) =>
      guides.where((g) => g.matches(query)).toList();

  List<Guide> byCategory(String category) =>
      guides.where((g) => g.category == category).toList();

  List<Guide> get popular => guides.where((g) => g.popular).toList();

  /// Active checklists, most recently updated first, skipping any whose
  /// guide has been removed.
  List<MapEntry<Guide, GuideProgress>> get activeChecklists {
    final entries = <MapEntry<Guide, GuideProgress>>[];
    progress.forEach((id, p) {
      final g = guideById(id);
      if (g != null) entries.add(MapEntry(g, p));
    });
    entries.sort((a, b) => b.value.updatedAt.compareTo(a.value.updatedAt));
    return entries;
  }

  Future<void> setLang(String value) async {
    lang = value;
    await prefs.setString(_langKey, value);
    notifyListeners();
  }

  Future<void> finishIntro() async {
    introSeen = true;
    await prefs.setBool(_introKey, true);
    notifyListeners();
  }

  bool hasChecklist(String guideId) => progress.containsKey(guideId);

  Future<void> startChecklist(String guideId) async {
    progress.putIfAbsent(guideId, () => GuideProgress());
    await _saveProgress();
  }

  Future<void> removeChecklist(String guideId) async {
    progress.remove(guideId);
    await _saveProgress();
  }

  Future<void> toggleDocument(String guideId, int index) async {
    final p = progress[guideId];
    if (p == null) return;
    p.documents.contains(index)
        ? p.documents.remove(index)
        : p.documents.add(index);
    progress[guideId] = GuideProgress(
      documents: p.documents,
      steps: p.steps,
      notes: p.notes,
    );
    await _saveProgress();
  }

  Future<void> setNotes(String guideId, String notes) async {
    final p = progress[guideId];
    if (p == null) return;
    progress[guideId] = GuideProgress(
      documents: p.documents,
      steps: p.steps,
      notes: notes,
    );
    await _saveProgress();
  }

  Future<void> toggleStep(String guideId, int index) async {
    final p = progress[guideId];
    if (p == null) return;
    p.steps.contains(index) ? p.steps.remove(index) : p.steps.add(index);
    progress[guideId] = GuideProgress(
      documents: p.documents,
      steps: p.steps,
      notes: p.notes,
    );
    await _saveProgress();
  }

  Future<void> _saveProgress() async {
    notifyListeners();
    await prefs.setString(
      _progressKey,
      jsonEncode(progress.map((k, v) => MapEntry(k, v.toJson()))),
    );
  }
}

/// Makes [AppState] available to every screen without extra packages.
class AppScope extends InheritedNotifier<AppState> {
  const AppScope({super.key, required AppState state, required super.child})
    : super(notifier: state);

  static AppState of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<AppScope>()!.notifier!;
}
