import 'package:flutter/material.dart';

import 'app_state.dart';
import 'links.dart';
import 'models.dart';
import 'theme.dart';

/// Asks for a title and a date, saves the reminder, and offers to add it to
/// the phone's calendar.
Future<void> showReminderDialog(BuildContext context, {Guide? guide}) async {
  final state = AppScope.of(context);
  final s = state.s;
  final controller = TextEditingController(
    text: guide == null ? '' : s.deadlineFor(guide.text(state.lang).title),
  );
  var date = DateTime.now().add(const Duration(days: 7));
  final ok = await showDialog<bool>(
    context: context,
    builder: (ctx) => StatefulBuilder(
      builder: (ctx, setState) => AlertDialog(
        title: Text(s.setReminder),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              maxLength: 80,
              decoration: InputDecoration(labelText: s.reminderTitle),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              icon: const Icon(Icons.event),
              label: Text(MaterialLocalizations.of(ctx).formatMediumDate(date)),
              onPressed: () async {
                final now = DateTime.now();
                final picked = await showDatePicker(
                  context: ctx,
                  initialDate: date,
                  firstDate: DateTime(now.year, now.month, now.day),
                  lastDate: DateTime(now.year + 10),
                  helpText: s.pickDate,
                );
                if (picked != null) setState(() => date = picked);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(MaterialLocalizations.of(ctx).cancelButtonLabel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(s.save),
          ),
        ],
      ),
    ),
  );
  final title = controller.text.trim();
  controller.dispose();
  if (ok != true || title.isEmpty || !context.mounted) return;
  final reminder = await state.addReminder(
    title: title,
    date: date,
    guideId: guide?.id,
  );
  if (!context.mounted) return;
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      duration: const Duration(seconds: 6),
      content: Text(s.reminderSaved),
      action: SnackBarAction(
        label: s.addToCalendar,
        onPressed: () => addToCalendar(context, reminder),
      ),
    ),
  );
}

Future<void> addToCalendar(BuildContext context, Reminder reminder) {
  final state = AppScope.of(context);
  final guide = reminder.guideId == null
      ? null
      : state.guideById(reminder.guideId!);
  final details = guide == null
      ? 'ProcessPK'
      : '${guide.text(state.lang).title}\n${guide.sources.isEmpty ? '' : guide.sources.first.url}\n\nProcessPK';
  return openLink(context, reminder.calendarUrl(details: details));
}

class ReminderTile extends StatelessWidget {
  final Reminder reminder;

  const ReminderTile({super.key, required this.reminder});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = state.s;
    final days = reminder.daysLeft();
    final soon = days <= 7;
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: soon
              ? AppColors.warning.withValues(alpha: 0.2)
              : AppColors.mint,
          child: Icon(
            Icons.alarm,
            color: soon ? const Color(0xFFB7791F) : AppColors.primary,
          ),
        ),
        title: Text(reminder.title),
        subtitle: Text(
          '${MaterialLocalizations.of(context).formatMediumDate(reminder.date)}  ·  ${s.daysLeft(days)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (v) {
            if (v == 'calendar') addToCalendar(context, reminder);
            if (v == 'delete') state.removeReminder(reminder.id);
          },
          itemBuilder: (_) => [
            PopupMenuItem(value: 'calendar', child: Text(s.addToCalendar)),
            PopupMenuItem(value: 'delete', child: Text(s.delete)),
          ],
        ),
      ),
    );
  }
}
