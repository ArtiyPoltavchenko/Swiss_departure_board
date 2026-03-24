import 'package:flutter/material.dart';
import 'package:swiss_departure_board/l10n/app_localizations.dart';
import 'package:google_fonts/google_fonts.dart';

import '../models/departure.dart';

/// Displays the minutes remaining until departure, or a pulsing "Now" label
/// when [Departure.isDeparting] is true.
class CountdownChip extends StatefulWidget {
  final Departure departure;

  const CountdownChip({super.key, required this.departure});

  @override
  State<CountdownChip> createState() => _CountdownChipState();
}

class _CountdownChipState extends State<CountdownChip>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  late final Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _opacity = Tween<double>(begin: 0.35, end: 1.0).animate(
      CurvedAnimation(parent: _pulse, curve: Curves.easeInOut),
    );
    if (widget.departure.isDeparting) _pulse.repeat(reverse: true);
  }

  @override
  void didUpdateWidget(CountdownChip old) {
    super.didUpdateWidget(old);
    if (widget.departure.isDeparting && !_pulse.isAnimating) {
      _pulse.repeat(reverse: true);
    } else if (!widget.departure.isDeparting && _pulse.isAnimating) {
      _pulse.stop();
      _pulse.value = 1.0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    if (widget.departure.isDeparting) {
      return FadeTransition(
        opacity: _opacity,
        child: Text(
          l10n?.departingNow ?? 'Now',
          style: GoogleFonts.robotoMono(
            color: Colors.greenAccent,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      );
    }

    return Text(
      l10n?.minutes(widget.departure.minutesUntil) ??
          '${widget.departure.minutesUntil} min',
      style: GoogleFonts.robotoMono(
        color: const Color(0xFFffd700),
        fontWeight: FontWeight.bold,
        fontSize: 14,
      ),
      textAlign: TextAlign.right,
    );
  }
}
