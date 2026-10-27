import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import 'checklist_screen.dart';

class ProgressScreen extends StatelessWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = state.s;
    final entries = state.activeChecklists;
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            s.navProgress,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 16),
          if (entries.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 48),
              child: Column(
                children: [
                  const Icon(Icons.task_alt, size: 56, color: AppColors.mint),
                  const SizedBox(height: 12),
                  Text(
                    s.noProgress,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.muted),
                  ),
                ],
              ),
            ),
          for (final e in entries) ...[
            Card(
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => ChecklistScreen(guideId: e.key.id),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        e.key.text(state.lang).title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 10),
                      LinearProgressIndicator(
                        value: e.value.fraction(e.key),
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(8),
                        backgroundColor: AppColors.mint,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${s.percentDone((e.value.fraction(e.key) * 100).round())}  ·  '
                        '${s.documentsReady}: ${e.value.documents.length}/${e.key.en.documents.length}  ·  '
                        '${s.stepsDone}: ${e.value.steps.length}/${e.key.en.steps.length}',
                        style: const TextStyle(
                          fontSize: 13,
                          color: AppColors.muted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ],
      ),
    );
  }
}
