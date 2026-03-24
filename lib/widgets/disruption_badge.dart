import 'package:flutter/material.dart';
import 'package:swiss_departure_board/l10n/app_localizations.dart';

/// A small ⚠️ icon shown next to a departure when [hasDisruption] is true.
///
/// Tapping opens a bottom sheet with the disruption [summary] and a link
/// to check the SBB app for details.
class DisruptionBadge extends StatelessWidget {
  final String? summary;

  const DisruptionBadge({super.key, this.summary});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showDetails(context),
      child: const Padding(
        padding: EdgeInsets.only(left: 6),
        child: Icon(
          Icons.warning_amber_rounded,
          color: Colors.amber,
          size: 18,
          semanticLabel: 'Disruption',
        ),
      ),
    );
  }

  void _showDetails(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final title = l10n?.disruption ?? 'Disruption';
    final checkSbb = l10n?.checkSbb ?? 'Check SBB app for details';
    final text = (summary?.isNotEmpty ?? false)
        ? summary!
        : checkSbb;

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: const Color(0xFF16213e),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: Colors.amber),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(text, style: const TextStyle(color: Colors.white70)),
            const SizedBox(height: 16),
            Text(
              checkSbb,
              style: const TextStyle(
                color: Colors.amber,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
