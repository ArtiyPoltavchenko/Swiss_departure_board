import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/departure.dart';
import 'countdown_chip.dart';
import 'disruption_badge.dart';

/// A single flat row in the departure board.
///
/// ```
/// [Line badge]  [Destination ...]        [⚠]  [Countdown]
/// ```
class DepartureTile extends StatelessWidget {
  final Departure departure;

  const DepartureTile({super.key, required this.departure});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              _LineBadge(departure: departure),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      departure.destination,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    ),
                    if (departure.platform != null)
                      Text(
                        'Pl. ${departure.platform}',
                        style: TextStyle(
                          color: Colors.white.withAlpha(128),
                          fontSize: 11,
                        ),
                      ),
                  ],
                ),
              ),
              if (departure.hasDisruption)
                DisruptionBadge(key: ValueKey('dis_${departure.line}')),
              const SizedBox(width: 8),
              CountdownChip(departure: departure),
            ],
          ),
        ),
        Divider(
          height: 1,
          color: Colors.white.withAlpha(20),
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }
}

class _LineBadge extends StatelessWidget {
  final Departure departure;

  const _LineBadge({required this.departure});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 44),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        color: _categoryColor(departure.category),
        borderRadius: BorderRadius.circular(5),
      ),
      child: Text(
        departure.line,
        style: GoogleFonts.robotoMono(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  static Color _categoryColor(String category) {
    switch (category) {
      case 'tram':
        return const Color(0xFFe20000); // SBB red
      case 'bus':
        return const Color(0xFF0063b6); // blue
      case 'train':
        return const Color(0xFF333333); // dark grey
      case 'ship':
        return const Color(0xFF00857c); // teal
      case 'cableway':
        return const Color(0xFF8b5e3c); // brown
      default:
        return const Color(0xFF666666);
    }
  }
}
