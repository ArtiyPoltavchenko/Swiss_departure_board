import 'package:flutter/material.dart';

import '../models/stop.dart';

/// Dropdown for selecting among [stops].
///
/// Only rendered when there are 2 or more stops. Calls [onStopSelected]
/// whenever the user picks a different stop.
class StopSelector extends StatelessWidget {
  final List<Stop> stops;
  final Stop selectedStop;
  final ValueChanged<Stop> onStopSelected;

  const StopSelector({
    super.key,
    required this.stops,
    required this.selectedStop,
    required this.onStopSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (stops.length < 2) return const SizedBox.shrink();

    return DropdownButton<Stop>(
      value: selectedStop,
      isExpanded: true,
      underline: const SizedBox.shrink(),
      items: stops.map((stop) {
        final label = stop.distance != null
            ? '${stop.name} (${stop.distance} m)'
            : stop.name;
        return DropdownMenuItem<Stop>(
          value: stop,
          child: Text(
            label,
            overflow: TextOverflow.ellipsis,
          ),
        );
      }).toList(),
      onChanged: (stop) {
        if (stop != null && stop != selectedStop) {
          onStopSelected(stop);
        }
      },
    );
  }
}
