import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart';

import '../models/departure.dart';
import '../models/disruption.dart';
import '../models/stop.dart';
import '../providers/settings_provider.dart';
import '../providers/stop_provider.dart';
import '../screens/settings_screen.dart';
import '../services/disruption_api.dart';
import '../services/exceptions.dart';
import '../services/location_service.dart';
import '../services/transport_api.dart';
import '../widgets/departure_tile.dart';
import '../widgets/stop_selector.dart';

class BoardScreen extends ConsumerStatefulWidget {
  const BoardScreen({super.key});

  @override
  ConsumerState<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends ConsumerState<BoardScreen> {
  Stop? _selectedStop;
  List<Stop> _nearbyStops = [];
  List<Departure> _departures = [];

  bool _loading = true;
  String? _errorMessage;
  bool _isPermissionError = false;
  bool _isLocationError = false;

  DateTime? _lastUpdated;
  Timer? _refreshTimer;
  Timer? _clockTimer;

  // Key that changes on each refresh, driving AnimatedSwitcher.
  int _listVersion = 0;

  @override
  void initState() {
    super.initState();
    _initialLoad();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) { if (mounted) setState(() {}); },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Loading
  // ---------------------------------------------------------------------------

  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _isPermissionError = false;
      _isLocationError = false;
    });

    try {
      final location = ref.read(locationServiceProvider);
      final (lat, lng) = await location.getCurrentPosition();

      final api = ref.read(transportApiProvider);
      final stops = await api.getNearbyStops(lat, lng);

      if (!mounted) return;

      if (stops.isEmpty) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _loading = false;
          _errorMessage = l10n?.noStopsFound ?? 'No stops found.';
        });
        return;
      }

      final lastStop = await ref.read(stopProvider.notifier).loadLastStop();
      final initial =
          (lastStop != null && stops.any((s) => s.id == lastStop.id))
              ? stops.firstWhere((s) => s.id == lastStop.id)
              : stops.first;

      setState(() {
        _nearbyStops = stops;
        _selectedStop = initial;
        _loading = false;
      });

      await _loadDepartures();
      _startAutoRefresh();
    } on LocationPermissionDeniedException {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _loading = false;
        _isPermissionError = true;
        _errorMessage = l10n?.locationDenied ?? 'Location permission denied.';
      });
    } on LocationServiceDisabledException {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _loading = false;
        _isLocationError = true;
        _errorMessage =
            l10n?.locationDisabled ?? 'Location services disabled.';
      });
    } on LocationTimeoutException {
      if (!mounted) return;
      final l10n = AppLocalizations.of(context);
      setState(() {
        _loading = false;
        _errorMessage =
            l10n?.locationTimeout ?? 'Could not determine location.';
      });
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.message;
      });
    }
  }

  Future<void> _loadDepartures() async {
    final stop = _selectedStop;
    if (stop == null) return;

    final settings = ref.read(settingsProvider).valueOrNull;
    final limit = settings?.departureCount ?? 10;

    try {
      final api = ref.read(transportApiProvider);
      final disruptionApi = ref.read(disruptionApiProvider);

      // Fetch departures and disruptions concurrently.
      final (departures, disruptions) = await (
        api.getDepartures(stop.id, limit: limit),
        disruptionApi
            .getDisruptions()
            .catchError((_) => <Disruption>[]),
      ).wait;

      final merged = _mergeDisruptions(departures, disruptions);

      if (mounted) {
        setState(() {
          _departures = merged;
          _lastUpdated = DateTime.now();
          _errorMessage = null;
          _listVersion++;
        });
      }
    } on AppException catch (e) {
      if (mounted) setState(() => _errorMessage = e.message);
    }
  }

  List<Departure> _mergeDisruptions(
    List<Departure> departures,
    List<Disruption> disruptions,
  ) {
    if (disruptions.isEmpty) return departures;
    return departures.map((d) {
      final hit = disruptions.any(
        (dis) => dis.affectedLine == null || dis.affectedLine == d.line,
      );
      return hit ? d.withDisruption(true) : d;
    }).toList();
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    final interval =
        ref.read(settingsProvider).valueOrNull?.refreshIntervalSeconds ?? 30;
    _refreshTimer = Timer.periodic(
      Duration(seconds: interval),
      (_) => _loadDepartures(),
    );
  }

  Future<void> _onStopSelected(Stop stop) async {
    setState(() => _selectedStop = stop);
    await ref.read(stopProvider.notifier).saveLastStop(stop);
    await _loadDepartures();
  }

  Future<void> _onRefresh() async => _loadDepartures();

  Future<void> _openSettings() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
    // Restart timer in case the interval changed.
    if (mounted) _startAutoRefresh();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.appTitle ?? 'Departure Board'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            tooltip: l10n?.settingsTitle ?? 'Settings',
            onPressed: _openSettings,
          ),
        ],
      ),
      body: _buildBody(l10n),
    );
  }

  Widget _buildBody(AppLocalizations? l10n) {
    if (_loading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Color(0xFFffd700)),
            const SizedBox(height: 16),
            Text(l10n?.loading ?? 'Loading...'),
          ],
        ),
      );
    }

    if (_isPermissionError) {
      return _ErrorView(
        message: _errorMessage ?? '',
        actionLabel: l10n?.openSettings ?? 'Open Settings',
        onAction: Geolocator.openAppSettings,
      );
    }

    if (_isLocationError) {
      return _ErrorView(
        message: _errorMessage ?? '',
        actionLabel: l10n?.openLocationSettings ?? 'Open Location Settings',
        onAction: Geolocator.openLocationSettings,
      );
    }

    if (_selectedStop == null) {
      return _ErrorView(
        message: _errorMessage ?? '',
        actionLabel: l10n?.retry ?? 'Retry',
        onAction: _initialLoad,
      );
    }

    return Column(
      children: [
        _buildHeader(l10n),
        if (_errorMessage != null)
          Container(
            width: double.infinity,
            color: Colors.red.shade900.withAlpha(180),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _errorMessage!,
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ),
        Expanded(
          child: RefreshIndicator(
            color: const Color(0xFFffd700),
            backgroundColor: const Color(0xFF16213e),
            onRefresh: _onRefresh,
            child: _buildDepartureList(l10n),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(AppLocalizations? l10n) {
    final stop = _selectedStop!;
    final secondsAgo = _lastUpdated == null
        ? null
        : DateTime.now().difference(_lastUpdated!).inSeconds;

    return Container(
      color: const Color(0xFF16213e),
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StopSelector(
            stops: _nearbyStops,
            selectedStop: stop,
            onStopSelected: _onStopSelected,
          ),
          if (_nearbyStops.length < 2)
            Text(
              stop.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          if (secondsAgo != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l10n?.updatedAgo(secondsAgo) ?? 'Updated ${secondsAgo}s ago',
                style: const TextStyle(color: Colors.white38, fontSize: 11),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDepartureList(AppLocalizations? l10n) {
    if (_departures.isEmpty) {
      return ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          Padding(
            padding: const EdgeInsets.all(32),
            child: Center(
              child: Text(
                l10n?.noDepartures ?? 'No departures available.',
                style: const TextStyle(color: Colors.white54),
              ),
            ),
          ),
        ],
      );
    }

    // AnimatedSwitcher fades between old and new list on each refresh.
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        key: ValueKey(_listVersion),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _departures.length,
        itemBuilder: (context, index) {
          final departure = _departures[index];
          // Staggered slide-up + fade-in on first render of this list version.
          return TweenAnimationBuilder<double>(
            key: ValueKey('${_listVersion}_$index'),
            tween: Tween(begin: 0.0, end: 1.0),
            duration: Duration(milliseconds: 180 + index * 40),
            curve: Curves.easeOut,
            builder: (context, value, child) => Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(0, 14 * (1 - value)),
                child: child,
              ),
            ),
            child: DepartureTile(departure: departure),
          );
        },
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Shared error view
// ---------------------------------------------------------------------------

class _ErrorView extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _ErrorView({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.location_off_outlined,
              size: 48,
              color: Colors.white38,
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onAction,
              child: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
