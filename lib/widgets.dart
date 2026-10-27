import 'package:flutter/material.dart';

import 'app_state.dart';
import 'models.dart';
import 'screens/guide_detail_screen.dart';
import 'theme.dart';

void openGuide(BuildContext context, Guide guide) {
  Navigator.of(context).push(
    MaterialPageRoute(builder: (_) => GuideDetailScreen(guideId: guide.id)),
  );
}

class VerifiedLabel extends StatelessWidget {
  final String? date;

  const VerifiedLabel({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).s;
    final verified = date != null;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          verified ? Icons.verified_outlined : Icons.info_outline,
          size: 14,
          color: verified ? AppColors.primary : AppColors.warning,
        ),
        const SizedBox(width: 4),
        Flexible(
          child: Text(
            s.lastVerified(date),
            style: const TextStyle(fontSize: 12, color: AppColors.muted),
          ),
        ),
      ],
    );
  }
}

class GuideCard extends StatelessWidget {
  final Guide guide;

  const GuideCard({super.key, required this.guide});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final t = guide.text(state.lang);
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => openGuide(context, guide),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  categoryIcon(guide.category),
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t.title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      t.summary,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.muted,
                      ),
                    ),
                    const SizedBox(height: 6),
                    VerifiedLabel(date: guide.lastVerified),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.muted),
            ],
          ),
        ),
      ),
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;

  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 24, bottom: 10),
    child: Text(
      text,
      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
    ),
  );
}
