import 'package:flutter/material.dart';

import '../app_state.dart';
import '../config.dart';
import '../links.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = state.s;
    // Every official source used across all guides, without duplicates.
    final sources = {
      for (final g in state.guides)
        for (final src in g.sources) src.url: src.name,
    };
    // Every helpline across all guides, once each.
    final helplines = <String, GuideContact>{
      for (final g in state.guides)
        for (final c in g.contacts)
          if (c.phone != null) c.phone!: c,
    };
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            s.aboutTitle,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            s.aboutBody,
            style: TextStyle(fontSize: 16, height: bodyLineHeight(context)),
          ),
          SectionTitle(s.language),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'en', label: Text('English')),
              ButtonSegment(value: 'ur', label: Text('اردو')),
            ],
            selected: {state.lang},
            onSelectionChanged: (v) => state.setLang(v.first),
          ),
          SectionTitle(s.disclaimerTitle),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.mint,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(
              s.disclaimer,
              style: TextStyle(height: bodyLineHeight(context)),
            ),
          ),
          SectionTitle(s.privacyPolicy),
          Text(
            s.privacySummary,
            style: TextStyle(height: bodyLineHeight(context)),
          ),
          TextButton.icon(
            style: TextButton.styleFrom(
              alignment: AlignmentDirectional.centerStart,
            ),
            icon: const Icon(Icons.privacy_tip_outlined),
            label: Text(s.privacyPolicy),
            onPressed: () => openLink(context, AppConfig.privacyPolicyUrl),
          ),
          SectionTitle(s.helplines),
          for (final c in helplines.values) ContactTile(contact: c),
          SectionTitle(s.officialSources),
          for (final entry in sources.entries)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.open_in_new, color: AppColors.primary),
              title: Text(entry.value),
              subtitle: Text(entry.key, style: const TextStyle(fontSize: 12)),
              onTap: () => openLink(context, entry.key),
            ),
          const SizedBox(height: 16),
          Center(
            child: Text(
              s.version(AppConfig.version),
              style: const TextStyle(color: AppColors.muted),
            ),
          ),
        ],
      ),
    );
  }
}
