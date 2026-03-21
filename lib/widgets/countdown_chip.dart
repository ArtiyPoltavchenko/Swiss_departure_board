import 'package:flutter/material.dart';

import '../models/departure.dart';

/// Displays the minutes remaining until a departure, or a "departing now"
/// icon when [Departure.isDeparting] is true.
class CountdownChip extends StatelessWidget {
  final Departure departure;

  const CountdownChip({super.key, required this.departure});

  @override
  Widget build(BuildContext context) {
    if (departure.isDeparting) {
      return const Icon(
        Icons.directions_walk,
        semanticLabel: 'Departing now',
      );
    }

    return Text(
      '${departure.minutesUntil} min',
      style: const TextStyle(fontWeight: FontWeight.bold),
      textAlign: TextAlign.right,
    );
  }
}
