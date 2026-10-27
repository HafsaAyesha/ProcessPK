import 'package:flutter/material.dart';

import '../app_state.dart';
import '../theme.dart';
import '../widgets.dart';

/// Tick off documents and steps for one guide. No ads on this screen.
class ChecklistScreen extends StatelessWidget {
  final String guideId;

  const ChecklistScreen({super.key, required this.guideId});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = state.s;
    final guide = state.guideById(guideId);
    final progress = state.progress[guideId];
    if (guide == null || progress == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(s.noProgress)),
      );
    }
    final t = guide.text(state.lang);
    final pct = (progress.fraction(guide) * 100).round();
    return Scaffold(
      appBar: AppBar(
        title: Text(s.navProgress),
        actions: [
          PopupMenuButton<String>(
            onSelected: (_) async {
              await state.removeChecklist(guideId);
              if (context.mounted) Navigator.of(context).maybePop();
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'remove', child: Text(s.removeChecklist)),
            ],
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            t.title,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          LinearProgressIndicator(
            value: pct / 100,
            minHeight: 10,
            borderRadius: BorderRadius.circular(8),
            backgroundColor: AppColors.mint,
          ),
          const SizedBox(height: 6),
          Text(
            s.percentDone(pct),
            style: const TextStyle(color: AppColors.muted),
          ),
          SectionTitle(
            '${s.documentsReady} (${progress.documents.length}/${t.documents.length})',
          ),
          for (var i = 0; i < t.documents.length; i++)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: progress.documents.contains(i),
              title: Text(t.documents[i]),
              onChanged: (_) => state.toggleDocument(guideId, i),
            ),
          SectionTitle(
            '${s.stepsDone} (${progress.steps.length}/${t.steps.length})',
          ),
          for (var i = 0; i < t.steps.length; i++)
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              value: progress.steps.contains(i),
              title: Text('${i + 1}. ${t.steps[i]}'),
              onChanged: (_) => state.toggleStep(guideId, i),
            ),
          SectionTitle(s.myNotes),
          TextFormField(
            initialValue: progress.notes,
            minLines: 3,
            maxLines: 6,
            decoration: InputDecoration(
              hintText: s.notesHint,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
            onChanged: (v) => state.setNotes(guideId, v),
          ),
          const SizedBox(height: 16),
          OutlinedButton(
            onPressed: () => openGuide(context, guide),
            child: Text(s.viewFullGuide),
          ),
        ],
      ),
    );
  }
}
