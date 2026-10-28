import 'package:flutter/material.dart';

import '../ads.dart';
import '../app_state.dart';
import '../reminders.dart';
import '../theme.dart';
import '../widgets.dart';
import 'guide_list_screen.dart';
import 'offices_screen.dart';
import 'shell.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = state.s;
    final active = state.activeChecklists;
    final upcoming = state.upcomingReminders;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          Text(
            s.appName,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w700),
          ),
          Text(
            s.tagline,
            style: const TextStyle(fontSize: 14, color: AppColors.muted),
          ),
          const SizedBox(height: 16),
          TextField(
            textInputAction: TextInputAction.search,
            decoration: InputDecoration(
              hintText: s.searchHint,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFFE4E9E7)),
              ),
            ),
            onSubmitted: (q) {
              if (q.trim().isEmpty) return;
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => GuideListScreen(query: q)),
              );
            },
          ),
          if (upcoming.isNotEmpty) ...[
            SectionTitle(s.upcoming),
            ReminderTile(reminder: upcoming.first),
          ],
          if (active.isNotEmpty) ...[
            SectionTitle(s.continueWhereLeft),
            _ContinueCard(),
          ],
          SectionTitle(s.categories),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 1.7,
            children: [
              for (final c in categoryIds)
                Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => GuideListScreen(category: c),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(categoryIcon(c), color: AppColors.primary),
                          Text(
                            s.category(c),
                            maxLines: 2,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Card(
            color: AppColors.mint,
            child: ListTile(
              leading: const Icon(Icons.place, color: AppColors.primary),
              title: Text(
                s.findOffices,
                style: const TextStyle(fontWeight: FontWeight.w600),
              ),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const OfficesScreen())),
            ),
          ),
          if (state.savedGuides.isNotEmpty) ...[
            SectionTitle(s.savedGuides),
            for (final g in state.savedGuides) ...[
              GuideCard(guide: g),
              const SizedBox(height: 10),
            ],
          ],
          const SizedBox(height: 16),
          const Center(child: BannerAdBox()),
          SectionTitle(s.popular),
          for (final g in state.popular) ...[
            GuideCard(guide: g),
            const SizedBox(height: 10),
          ],
          TextButton(
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const GuideListScreen())),
            child: Text(s.allGuides),
          ),
        ],
      ),
    );
  }
}

class _ContinueCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = state.s;
    final entry = state.activeChecklists.first;
    final pct = (entry.value.fraction(entry.key) * 100).round();
    return Card(
      color: AppColors.mint,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.findAncestorStateOfType<ShellState>()?.goTo(1),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.key.text(state.lang).title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              LinearProgressIndicator(
                value: pct / 100,
                minHeight: 8,
                borderRadius: BorderRadius.circular(8),
                backgroundColor: Colors.white,
              ),
              const SizedBox(height: 6),
              Text(
                s.percentDone(pct),
                style: const TextStyle(color: AppColors.muted),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
