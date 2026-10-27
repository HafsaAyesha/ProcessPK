import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../app_state.dart';
import '../config.dart';
import '../links.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';
import 'checklist_screen.dart';

class GuideDetailScreen extends StatelessWidget {
  final String guideId;

  const GuideDetailScreen({super.key, required this.guideId});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = state.s;
    final guide = state.guideById(guideId);
    if (guide == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(s.noResults)),
      );
    }
    final t = guide.text(state.lang);
    final started = state.hasChecklist(guide.id);

    return Scaffold(
      appBar: AppBar(
        title: Text(s.category(guide.category)),
        actions: [
          IconButton(
            tooltip: s.share,
            icon: const Icon(Icons.share_outlined),
            onPressed: () => _share(guide, t),
          ),
          IconButton(
            tooltip: s.reportError,
            icon: const Icon(Icons.flag_outlined),
            onPressed: () => _report(context, guide),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text(
            t.title,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          VerifiedLabel(date: guide.lastVerified),
          SectionTitle(s.whatIsThis),
          Text(
            t.what,
            style: TextStyle(fontSize: 16, height: bodyLineHeight(context)),
          ),
          SectionTitle(s.whoNeedsIt),
          Text(
            t.who,
            style: TextStyle(fontSize: 16, height: bodyLineHeight(context)),
          ),
          SectionTitle(s.requiredDocuments),
          for (final d in t.documents)
            _Bullet(icon: Icons.description_outlined, text: d),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _InfoTile(
                  title: s.fees,
                  body: t.fees,
                  icon: Icons.payments_outlined,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _InfoTile(
                  title: s.processingTime,
                  body: t.time,
                  icon: Icons.schedule,
                ),
              ),
            ],
          ),
          SectionTitle(s.steps),
          for (var i = 0; i < t.steps.length; i++)
            _Step(number: i + 1, text: t.steps[i]),
          if (t.mistakes.isNotEmpty) ...[
            SectionTitle(s.commonMistakes),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppColors.warning.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  for (final m in t.mistakes)
                    _Bullet(
                      icon: Icons.warning_amber_rounded,
                      text: m,
                      color: const Color(0xFFB7791F),
                    ),
                ],
              ),
            ),
          ],
          if (t.problems.isNotEmpty) ...[
            SectionTitle(s.problemsAndFixes),
            for (final pr in t.problems)
              Card(
                margin: const EdgeInsets.only(bottom: 8),
                clipBehavior: Clip.antiAlias,
                child: ExpansionTile(
                  shape: const Border(),
                  leading: const Icon(
                    Icons.help_outline,
                    color: AppColors.primary,
                  ),
                  title: Text(
                    pr.problem,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.lightbulb_outline,
                          size: 18,
                          color: AppColors.primary,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            pr.solution,
                            style: TextStyle(
                              fontSize: 15,
                              height: bodyLineHeight(context),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
          ],
          if (guide.contacts.isNotEmpty) ...[
            SectionTitle(s.contactsAndHelp),
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: Text(
                s.contactsNote,
                style: const TextStyle(fontSize: 13, color: AppColors.muted),
              ),
            ),
            for (final c in guide.contacts) ContactTile(contact: c),
          ],
          SectionTitle(s.officialSources),
          for (final src in guide.sources)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.open_in_new, color: AppColors.primary),
              title: Text(src.name),
              subtitle: Text(src.url, style: const TextStyle(fontSize: 12)),
              onTap: () => openLink(context, src.url),
            ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: FilledButton.icon(
            icon: Icon(started ? Icons.task_alt : Icons.playlist_add_check),
            label: Text(started ? s.openChecklist : s.startChecklist),
            onPressed: () async {
              await state.startChecklist(guide.id);
              if (!context.mounted) return;
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ChecklistScreen(guideId: guide.id),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _share(Guide guide, GuideText t) {
    final buffer = StringBuffer()
      ..writeln(t.title)
      ..writeln()
      ..writeln(t.summary)
      ..writeln();
    for (var i = 0; i < t.steps.length; i++) {
      buffer.writeln('${i + 1}. ${t.steps[i]}');
    }
    if (guide.sources.isNotEmpty) {
      buffer
        ..writeln()
        ..writeln(guide.sources.first.url);
    }
    buffer
      ..writeln()
      ..writeln('Shared from ProcessPK');
    SharePlus.instance.share(ShareParams(text: buffer.toString()));
  }

  Future<void> _report(BuildContext context, Guide guide) async {
    final state = AppScope.of(context);
    final s = state.s;
    final controller = TextEditingController();
    final message = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.reportError),
        content: TextField(
          controller: controller,
          maxLines: 4,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: Text(MaterialLocalizations.of(ctx).okButtonLabel),
          ),
        ],
      ),
    );
    if (message == null || message.isEmpty) return;
    final sent = await state.repository.reportError(guide.id, message);
    if (sent) {
      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('✓')));
      }
      return;
    }
    await launchUrl(
      Uri(
        scheme: 'mailto',
        path: AppConfig.supportEmail,
        queryParameters: {'subject': 'ProcessPK: ${guide.id}', 'body': message},
      ),
    );
  }
}

class _Bullet extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Bullet({
    required this.icon,
    required this.text,
    this.color = AppColors.primary,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Icon(icon, size: 18, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15, height: bodyLineHeight(context)),
          ),
        ),
      ],
    ),
  );
}

class _Step extends StatelessWidget {
  final int number;
  final String text;

  const _Step({required this.number, required this.text});

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 13,
          backgroundColor: AppColors.primary,
          child: Text(
            '$number',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: TextStyle(fontSize: 15, height: bodyLineHeight(context)),
          ),
        ),
      ],
    ),
  );
}

class _InfoTile extends StatelessWidget {
  final String title;
  final String body;
  final IconData icon;

  const _InfoTile({
    required this.title,
    required this.body,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(top: 14),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: AppColors.mint,
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 18, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: TextStyle(fontSize: 13, height: bodyLineHeight(context)),
        ),
      ],
    ),
  );
}
