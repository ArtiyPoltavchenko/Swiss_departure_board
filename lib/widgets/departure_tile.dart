import 'package:flutter/material.dart';

import '../models/departure.dart';
import 'countdown_chip.dart';

/// A single row in the departure board.
///
/// Layout:
/// ```
/// [Line badge]  [Destination ...]          [Countdown]
/// ```
class DepartureTile extends StatelessWidget {
  final Departure departure;

  const DepartureTile({super.key, required this.departure});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          _LineBadge(departure: departure),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              departure.destination,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          CountdownChip(departure: departure),
        ],
      ),
    );
  }
}

class _LineBadge extends StatelessWidget {
  final Departure departure;

  const _LineBadge({required this.departure});

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 40),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _categoryColor(departure.category),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        departure.line,
        style: const TextStyle(
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
        return Colors.red.shade700;
      case 'bus':
        return Colors.blue.shade700;
      case 'train':
        return Colors.grey.shade800;
      case 'ship':
        return Colors.teal.shade600;
      case 'cableway':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade600;
    }
  }
}
