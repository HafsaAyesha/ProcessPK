import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../app_state.dart';
import '../ask_service.dart';
import '../links.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets.dart';

/// Bottom sheet for chatting about the guide that is open. Earlier turns are
/// sent along so follow-up questions ("and the fee?") make sense.
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
  final _scroll = ScrollController();
  final _turns = <AskTurn>[];
  bool _loading = false;
  String? _pending;
  String? _error;
  AskResult? _last;

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  Future<void> _send([String? preset]) async {
    final state = AppScope.of(context);
    final s = state.s;
    final question = (preset ?? _controller.text).trim();
    if (question.isEmpty || _loading) return;
    _controller.clear();
    setState(() {
      _loading = true;
      _error = null;
      _pending = question;
    });
    _scrollToEnd();
    try {
      final result = await state.ask.ask(
        guideId: widget.guide.id,
        question: question,
        lang: state.lang,
        history: List.of(_turns),
      );
      if (mounted) {
        setState(() {
          _turns.add(AskTurn(question, result.answer));
          _last = result;
        });
      }
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
      if (mounted) {
        setState(() {
          _loading = false;
          _pending = null;
        });
        _scrollToEnd();
      }
    }
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
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
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  const Icon(Icons.auto_awesome, color: AppColors.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      s.askProcessPK,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (_turns.isNotEmpty)
                    TextButton(
                      onPressed: _loading
                          ? null
                          : () => setState(() {
                              _turns.clear();
                              _last = null;
                              _error = null;
                            }),
                      child: Text(s.newChat),
                    ),
                ],
              ),
            ),
            Flexible(
              child: ListView(
                controller: _scroll,
                shrinkWrap: true,
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
                children: [
                  Text(
                    s.askIntro,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.muted,
                    ),
                  ),
                  if (_turns.isEmpty && !_loading) ...[
                    const SizedBox(height: 14),
                    Text(
                      s.suggestedQuestions,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        for (final q in s.askSuggestions)
                          ActionChip(label: Text(q), onPressed: () => _send(q)),
                      ],
                    ),
                  ],
                  for (final t in _turns) ...[
                    _Bubble(text: t.question, mine: true),
                    _Bubble(text: t.answer, mine: false),
                  ],
                  if (_pending != null) _Bubble(text: _pending!, mine: true),
                  if (_loading)
                    const Padding(
                      padding: EdgeInsets.all(12),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                  if (_error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        _error!,
                        style: const TextStyle(color: Color(0xFFB42318)),
                      ),
                    ),
                  if (_last != null && !_loading) ...[
                    const SizedBox(height: 4),
                    Text(
                      s.basedOn(_last!.guideTitle),
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    VerifiedLabel(date: _last!.lastVerified),
                    for (final src in _last!.sources)
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
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: _controller,
                    minLines: 1,
                    maxLines: 4,
                    maxLength: 500,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                    decoration: InputDecoration(
                      hintText: _turns.isEmpty ? s.askHint : s.askFollowUpHint,
                      filled: true,
                      fillColor: Colors.white,
                      counterText: '',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: AppColors.primary),
                        onPressed: _send,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    s.questionsLeft(state.ask.remainingToday),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.muted,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Bubble extends StatelessWidget {
  final String text;
  final bool mine;

  const _Bubble({required this.text, required this.mine});

  @override
  Widget build(BuildContext context) {
    final s = AppScope.of(context).s;
    return Align(
      alignment: mine
          ? AlignmentDirectional.centerEnd
          : AlignmentDirectional.centerStart,
      child: Container(
        margin: const EdgeInsets.only(top: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * (mine ? 0.75 : 0.9),
        ),
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        decoration: BoxDecoration(
          color: mine ? AppColors.primary : AppColors.mint,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              text,
              style: TextStyle(
                fontSize: 15,
                height: bodyLineHeight(context),
                color: mine ? Colors.white : null,
              ),
            ),
            if (!mine)
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  visualDensity: VisualDensity.compact,
                  tooltip: s.copied,
                  icon: const Icon(Icons.copy, size: 16),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: text));
                    ScaffoldMessenger.of(context)
                        .showSnackBar(SnackBar(content: Text(s.copied)));
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
