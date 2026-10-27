import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import 'app_state.dart';

Future<void> openLink(BuildContext context, String url) async {
  final s = AppScope.of(context).s;
  final messenger = ScaffoldMessenger.of(context);
  final ok = await launchUrl(
    Uri.parse(url),
    mode: LaunchMode.externalApplication,
  );
  if (!ok) {
    messenger.showSnackBar(SnackBar(content: Text(s.couldNotOpen)));
  }
}
