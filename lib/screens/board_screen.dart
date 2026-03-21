import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../models/departure.dart';
import '../models/stop.dart';
import '../providers/departures_provider.dart';
import '../providers/stop_provider.dart';
import '../services/exceptions.dart';
import '../services/location_service.dart';
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
  bool _isLocationError = false;
  bool _isPermissionError = false;

  DateTime? _lastUpdated;
  Timer? _refreshTimer;
  Timer? _clockTimer;

  @override
  void initState() {
    super.initState();
    _initialLoad();

    // Update the "X seconds ago" label every second.
    _clockTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Data loading
  // ---------------------------------------------------------------------------

  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _isLocationError = false;
      _isPermissionError = false;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final (lat, lng) = await locationService.getCurrentPosition();

      final api = ref.read(transportApiProvider);
      final stops = await api.getNearbyStops(lat, lng);

      if (stops.isEmpty) {
        setState(() {
          _loading = false;
          _errorMessage = 'No stops found near your location.';
        });
        return;
      }

      // Restore last-used stop if it is in the nearby list.
      final lastStop = await ref.read(stopProvider.notifier).loadLastStop();
      final initial = (lastStop != null &&
              stops.any((s) => s.id == lastStop.id))
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
      setState(() {
        _loading = false;
        _isPermissionError = true;
        _errorMessage = 'Location permission is required to find nearby stops.';
      });
    } on LocationServiceDisabledException {
      setState(() {
        _loading = false;
        _isLocationError = true;
        _errorMessage = 'Please enable location services and try again.';
      });
    } on LocationTimeoutException {
      setState(() {
        _loading = false;
        _errorMessage = 'Could not determine your location. Please try again.';
      });
    } on AppException catch (e) {
      setState(() {
        _loading = false;
        _errorMessage = e.message;
      });
    }
  }

  Future<void> _loadDepartures() async {
    final stop = _selectedStop;
    if (stop == null) return;

    try {
      final api = ref.read(transportApiProvider);
      final departures = await api.getDepartures(stop.id);
      if (mounted) {
        setState(() {
          _departures = departures;
          _lastUpdated = DateTime.now();
          _errorMessage = null;
        });
      }
    } on AppException catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.message);
      }
    }
  }

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (_) {
      _loadDepartures();
    });
  }

  Future<void> _onStopSelected(Stop stop) async {
    setState(() => _selectedStop = stop);
    await ref.read(stopProvider.notifier).saveLastStop(stop);
    await _loadDepartures();
  }

  Future<void> _onRefresh() async {
    await _loadDepartures();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Swiss Departure Board'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_isPermissionError) {
      return _CenteredMessage(
        message: _errorMessage ?? 'Location permission denied.',
        actionLabel: 'Open Settings',
        onAction: Geolocator.openAppSettings,
      );
    }

    if (_isLocationError) {
      return _CenteredMessage(
        message: _errorMessage ?? 'Location services disabled.',
        actionLabel: 'Open Location Settings',
        onAction: Geolocator.openLocationSettings,
      );
    }

    if (_selectedStop == null) {
      return _CenteredMessage(
        message: _errorMessage ?? 'An error occurred.',
        actionLabel: 'Retry',
        onAction: _initialLoad,
      );
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          SliverToBoxAdapter(child: _buildHeader()),
          if (_errorMessage != null)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Text(
                  _errorMessage!,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          if (_departures.isEmpty && _errorMessage == null)
            const SliverFillRemaining(
              child: Center(child: Text('No departures available.')),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) =>
                    DepartureTile(departure: _departures[index]),
                childCount: _departures.length,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    final stop = _selectedStop!;
    final secondsAgo = _lastUpdated == null
        ? null
        : DateTime.now().difference(_lastUpdated!).inSeconds;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
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
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
          if (secondsAgo != null)
            Text(
              'Updated $secondsAgo s ago',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          const Divider(),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Helper widget
// ---------------------------------------------------------------------------

class _CenteredMessage extends StatelessWidget {
  final String message;
  final String actionLabel;
  final VoidCallback onAction;

  const _CenteredMessage({
    required this.message,
    required this.actionLabel,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
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
