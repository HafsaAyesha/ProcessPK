import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'models.dart';

/// Loads guides. The bundled asset is always available offline; when
/// Firebase is configured, guides from the `guides` Firestore collection
/// replace it and are cached so they still work offline next time.
class GuideRepository {
  static const _cacheKey = 'guides_cache_v1';

  final bool firebaseReady;

  GuideRepository({required this.firebaseReady});

  Future<List<Guide>> loadLocal(SharedPreferences prefs) async {
    final cached = prefs.getString(_cacheKey);
    if (cached != null) {
      try {
        return _parse(jsonDecode(cached) as List);
      } catch (_) {
        // A broken cache falls through to the bundled guides.
      }
    }
    final raw = await rootBundle.loadString('assets/guides.json');
    return _parse((jsonDecode(raw) as Map<String, dynamic>)['guides'] as List);
  }

  /// Returns fresh guides from Firestore, or null if Firebase is not set up,
  /// the device is offline, or the collection is empty.
  Future<List<Guide>?> fetchRemote(SharedPreferences prefs) async {
    if (!firebaseReady) return null;
    try {
      final snap = await FirebaseFirestore.instance
          .collection('guides')
          .get()
          .timeout(const Duration(seconds: 8));
      if (snap.docs.isEmpty) return null;
      final guides = _parse(
        snap.docs.map((d) => {'id': d.id, ...d.data()}).toList(),
      );
      await prefs.setString(
        _cacheKey,
        jsonEncode(guides.map((g) => g.toJson()).toList()),
      );
      return guides;
    } catch (_) {
      return null;
    }
  }

  /// Sends a "this guide is wrong" note to Firestore. Returns false when
  /// Firebase is not available so the caller can fall back to email.
  Future<bool> reportError(String guideId, String message) async {
    if (!firebaseReady) return false;
    try {
      await FirebaseFirestore.instance.collection('reports').add({
        'guideId': guideId,
        'message': message,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  List<Guide> _parse(List list) => list
      .map((e) => Guide.fromJson(Map<String, dynamic>.from(e as Map)))
      .toList();
}
