import 'package:flutter/material.dart';

import '../models/stop.dart';

/// Shows the current stop name (or a dropdown when multiple stops are
/// available) together with a persistent search button on the right.
///
/// Unlike the original widget this always renders — even when only one stop
/// is available — so that the search button is always visible.
class StopSelector extends StatelessWidget {
  final List<Stop> stops;
  final Stop selectedStop;
  final ValueChanged<Stop> onStopSelected;

  /// Called when the user taps the search icon. Must not be null.
  final VoidCallback onSearchPressed;

  const StopSelector({
    super.key,
    required this.stops,
    required this.selectedStop,
    required this.onStopSelected,
    required this.onSearchPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: stops.length >= 2
              ? DropdownButton<Stop>(
                  value: selectedStop,
                  isExpanded: true,
                  underline: const SizedBox.shrink(),
                  dropdownColor: const Color(0xFF16213e),
                  iconEnabledColor: Colors.white54,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                  items: stops.map((stop) {
                    final label = stop.distance != null
                        ? '${stop.name} (${stop.distance} m)'
                        : stop.name;
                    return DropdownMenuItem<Stop>(
                      value: stop,
                      child: Text(
                        label,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  }).toList(),
                  onChanged: (stop) {
                    if (stop != null && stop != selectedStop) {
                      onStopSelected(stop);
                    }
                  },
                )
              : Tooltip(
                  message: selectedStop.name,
                  child: Text(
                    selectedStop.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
        ),
        IconButton(
          icon: const Icon(Icons.search, color: Colors.white54),
          tooltip: 'Search stop',
          onPressed: onSearchPressed,
        ),
      ],
    );
  }
}
