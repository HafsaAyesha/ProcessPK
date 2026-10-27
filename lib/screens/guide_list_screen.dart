import 'package:flutter/material.dart';

import '../ads.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Guides filtered by [category] or matching [query]; all guides if neither.
class GuideListScreen extends StatelessWidget {
  final String? category;
  final String? query;

  const GuideListScreen({super.key, this.category, this.query});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = state.s;
    final guides = category != null
        ? state.byCategory(category!)
        : state.search(query ?? '');
    final title = category != null
        ? s.category(category!)
        : query != null
        ? s.searchResults
        : s.allGuides;
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: guides.isEmpty
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  s.noResults,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.muted),
                ),
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: guides.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (_, i) => GuideCard(guide: guides[i]),
            ),
      bottomNavigationBar: const SafeArea(
        child: Center(heightFactor: 1, child: BannerAdBox()),
      ),
    );
  }
}
