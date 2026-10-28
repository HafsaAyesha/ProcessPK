import 'package:flutter/material.dart';

import '../app_state.dart';
import '../links.dart';
import '../theme.dart';

/// Every kind of office the guides send people to, each opening Google Maps
/// with the nearest ones. No location permission is needed.
class OfficesScreen extends StatelessWidget {
  const OfficesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = AppScope.of(context);
    final s = state.s;
    final offices = state.offices;
    return Scaffold(
      appBar: AppBar(title: Text(s.findOffices)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            s.officesIntro,
            style: const TextStyle(fontSize: 13, color: AppColors.muted),
          ),
          const SizedBox(height: 12),
          for (final e in offices)
            Card(
              margin: const EdgeInsets.only(bottom: 10),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.place, color: AppColors.primary),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            e.key.label(state.lang),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      s.usedFor(
                        e.value.map((g) => g.text(state.lang).title).join(', '),
                      ),
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.muted,
                      ),
                    ),
                    Wrap(
                      spacing: 4,
                      children: [
                        TextButton.icon(
                          icon: const Icon(Icons.map_outlined, size: 18),
                          label: Text(s.openInMaps),
                          onPressed: () => openLink(context, e.key.mapsUrl),
                        ),
                        if (e.key.locator != null)
                          TextButton.icon(
                            icon: const Icon(Icons.list_alt, size: 18),
                            label: Text(s.officialList),
                            onPressed: () => openLink(context, e.key.locator!),
                          ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
