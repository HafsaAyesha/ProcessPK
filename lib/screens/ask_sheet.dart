import 'package:flutter/material.dart';

import '../app_state.dart';
import '../ask_service.dart';
import '../links.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

/// Bottom sheet for asking questions about the guide that is open.
class AskSheet extends StatefulWidget {
  final Guide guide;

  const AskSheet({super.key, required this.guide});

  static Future<void> show(BuildContext context, Guide guide) =>
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (_) => AskSheet(guide: guide),
      );

  @override
  State<AskSheet> createState() => _AskSheetState();
}

class _AskSheetState extends State<AskSheet> {
  final _controller = TextEditingController();
  bool _loading = false;
  AskResult? _result;
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final state = AppScope.of(context);
    final s = state.s;
    final question = _controller.text.trim();
    if (question.isEmpty || _loading) return;
    setState(() {
      _loading = true;
      _error = null;
      _result = null;
    });
    try {
      final result = await state.ask.ask(
        guideId: widget.guide.id,
        question: question,
        lang: state.lang,
      );
      if (mounted) setState(() => _result = result);
    } on AskException catch (e) {
      if (mounted) {
        setState(
          () => _error = switch (e.error) {
            AskError.limitReached => s.askLimitReached,
            AskError.busy => s.askBusy,
            AskError.failed => s.askFailed,
          },
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = state.s;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
          children: [
            Row(
              children: [
                const Icon(Icons.auto_awesome, color: AppColors.primary),
                const SizedBox(width: 8),
                Text(
                  s.askProcessPK,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              s.askIntro,
              style: const TextStyle(fontSize: 13, color: AppColors.muted),
            ),
            const SizedBox(height: 14),
            TextField(
              controller: _controller,
              minLines: 1,
              maxLines: 4,
              maxLength: 500,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _send(),
              decoration: InputDecoration(
                hintText: s.askHint,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.send, color: AppColors.primary),
                  onPressed: _send,
                ),
              ),
            ),
            Text(
              s.questionsLeft(state.ask.remainingToday),
              style: const TextStyle(fontSize: 12, color: AppColors.muted),
            ),
            const SizedBox(height: 12),
            if (_loading) const Center(child: CircularProgressIndicator()),
            if (_error != null)
              Text(_error!, style: const TextStyle(color: Color(0xFFB42318))),
            if (_result != null) ...[
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Text(
                  _result!.answer,
                  style: TextStyle(
                    fontSize: 15,
                    height: bodyLineHeight(context),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                s.basedOn(_result!.guideTitle),
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              VerifiedLabel(date: _result!.lastVerified),
              for (final src in _result!.sources)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    alignment: AlignmentDirectional.centerStart,
                  ),
                  icon: const Icon(Icons.open_in_new, size: 16),
                  label: Text(src.name),
                  onPressed: () => openLink(context, src.url),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
