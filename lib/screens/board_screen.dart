import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:swiss_departure_board/l10n/app_localizations.dart';
import 'package:geolocator/geolocator.dart'
    hide LocationServiceDisabledException;
import 'package:shared_preferences/shared_preferences.dart';

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

  /// True when the search overlay is shown over the main board.
  bool _showingSearch = false;

  /// True when displaying stale departures from disk cache (no network).
  bool _isOffline = false;

  DateTime? _lastUpdated;
  Timer? _refreshTimer;
  Timer? _clockTimer;

  /// Changed on every [_loadDepartures] call so that a stale result received
  /// after a stop switch is silently discarded.
  Object _departureToken = Object();

  int _listVersion = 0;

  // ---------------------------------------------------------------------------
  // SharedPreferences keys for offline departure cache
  // ---------------------------------------------------------------------------

  static String _cacheKey(String stopId) => 'dep_cache_$stopId';
  static String _cacheTimeKey(String stopId) => 'dep_cache_time_$stopId';

  // ---------------------------------------------------------------------------
  // Lifecycle
  // ---------------------------------------------------------------------------

  @override
  void initState() {
    super.initState();
    _initialLoad();
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Loading — initial
  // ---------------------------------------------------------------------------

  Future<void> _initialLoad() async {
    setState(() {
      _loading = true;
      _errorMessage = null;
      _isPermissionError = false;
      _isLocationError = false;
      _isOffline = false;
    });

    try {
      final location = ref.read(locationServiceProvider);
      final (lat, lng) = await location.getCurrentPosition();
      await _loadStopsAndDepartures(lat, lng);
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
      // 1. Try OS-cached GPS position (usually available even indoors).
      final location = ref.read(locationServiceProvider);
      final lastPos = await location.getLastKnownPosition();
      if (lastPos != null) {
        _showSnackBar(
          AppLocalizations.of(context)?.usingLastLocation ??
              'Using last known location',
        );
        await _loadStopsAndDepartures(lastPos.$1, lastPos.$2);
        return;
      }
      // 2. Fall back to last saved stop.
      final lastStop = await ref.read(stopProvider.notifier).loadLastStop();
      if (lastStop != null && mounted) {
        _showSnackBar(
          AppLocalizations.of(context)?.usingLastLocation ??
              'Using last known location',
        );
        setState(() {
          _nearbyStops = [lastStop];
          _selectedStop = lastStop;
          _loading = false;
        });
        await _loadDepartures();
        _startAutoRefresh();
        return;
      }
      // 3. Completely stuck.
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() {
          _loading = false;
          _errorMessage =
              l10n?.locationTimeout ?? 'Could not determine your location.';
        });
      }
    } on AppException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _errorMessage = e.message;
      });
    }
  }

  /// Shared helper: given a GPS fix, find nearby stops and smart-select the
  /// nearest one that has upcoming departures.
  Future<void> _loadStopsAndDepartures(double lat, double lng) async {
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

    // Check all stops in parallel for upcoming departures (limit=1 peek).
    final peekResults = await Future.wait(
      stops.map(
        (s) => api.hasUpcomingDepartures(s.id).catchError((_) => false),
      ),
    );

    if (!mounted) return;

    // Prefer last saved stop if it has departures, else first stop with
    // departures, else fall back to the nearest stop.
    final lastStop = await ref.read(stopProvider.notifier).loadLastStop();

    Stop initial;
    if (lastStop != null) {
      final savedIdx = stops.indexWhere((s) => s.id == lastStop.id);
      if (savedIdx >= 0 && peekResults[savedIdx]) {
        initial = stops[savedIdx];
      } else {
        final activeIdx = peekResults.indexWhere((has) => has);
        initial = activeIdx >= 0 ? stops[activeIdx] : stops.first;
      }
    } else {
      final activeIdx = peekResults.indexWhere((has) => has);
      initial = activeIdx >= 0 ? stops[activeIdx] : stops.first;
    }

    if (!mounted) return;
    setState(() {
      _nearbyStops = stops;
      _selectedStop = initial;
      _loading = false;
    });

    // Force-refresh so the full board is fetched (peek only cached limit=1).
    await _loadDepartures(forceRefresh: true);
    _startAutoRefresh();
  }

  // ---------------------------------------------------------------------------
  // Loading — departures
  // ---------------------------------------------------------------------------

  Future<void> _loadDepartures({bool forceRefresh = false}) async {
    final stop = _selectedStop;
    if (stop == null) return;

    // Token prevents stale results from being applied after a stop switch.
    final token = Object();
    _departureToken = token;

    final settings = ref.read(settingsProvider).valueOrNull;
    final limit = settings?.departureCount ?? 10;

    try {
      final api = ref.read(transportApiProvider);
      final disruptionApi = ref.read(disruptionApiProvider);

      final (departures, disruptions) = await (
        api.getDepartures(stop.id, limit: limit, forceRefresh: forceRefresh),
        disruptionApi.getDisruptions().catchError((_) => <Disruption>[]),
      ).wait;

      if (!mounted || token != _departureToken) return;

      final merged = _mergeDisruptions(departures, disruptions);
      await _saveDepartureCache(stop.id, departures);

      setState(() {
        _departures = merged;
        _lastUpdated = DateTime.now();
        _errorMessage = null;
        _isOffline = false;
        _listVersion++;
      });
    } on NoNetworkException {
      if (!mounted || token != _departureToken) return;
      // Show stale cached data with an offline banner.
      final cached = await _loadDepartureCache(stop.id);
      if (cached != null && mounted) {
        final merged = _mergeDisruptions(cached.$1, []);
        setState(() {
          _departures = merged;
          _lastUpdated = cached.$2;
          _isOffline = true;
          _errorMessage = null;
          _listVersion++;
        });
      } else if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() => _errorMessage =
            l10n?.noConnection ?? 'No internet connection');
      }
    } on AppException catch (e) {
      if (mounted && token == _departureToken) {
        setState(() => _errorMessage = e.message);
      }
    }
  }

  // ---------------------------------------------------------------------------
  // Departure cache — disk (SharedPreferences)
  // ---------------------------------------------------------------------------

  Future<void> _saveDepartureCache(
      String stopId, List<Departure> departures) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final data = departures
          .map((d) => {
                'line': d.line,
                'destination': d.destination,
                'category': d.category,
                'platform': d.platform,
                'scheduled': d.scheduledTime.toIso8601String(),
                'estimated': d.estimatedTime?.toIso8601String(),
              })
          .toList();
      await prefs.setString(_cacheKey(stopId), jsonEncode(data));
      await prefs.setString(
          _cacheTimeKey(stopId), DateTime.now().toIso8601String());
    } catch (_) {}
  }

  Future<(List<Departure>, DateTime)?> _loadDepartureCache(
      String stopId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey(stopId));
      final timeStr = prefs.getString(_cacheTimeKey(stopId));
      if (raw == null || timeStr == null) return null;
      final time = DateTime.parse(timeStr);
      final list = (jsonDecode(raw) as List).map((e) {
        final m = e as Map<String, dynamic>;
        final estimatedStr = m['estimated'] as String?;
        return Departure(
          line: m['line'] as String? ?? '',
          destination: m['destination'] as String? ?? '',
          scheduledTime: DateTime.parse(m['scheduled'] as String),
          estimatedTime:
              estimatedStr != null ? DateTime.parse(estimatedStr) : null,
          category: m['category'] as String? ?? '',
          platform: m['platform'] as String?,
        );
      }).toList();
      return (list, time);
    } catch (_) {
      return null;
    }
  }

  // ---------------------------------------------------------------------------
  // Disruption merge
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Auto-refresh
  // ---------------------------------------------------------------------------

  void _startAutoRefresh() {
    _refreshTimer?.cancel();
    final interval =
        ref.read(settingsProvider).valueOrNull?.refreshIntervalSeconds ?? 30;
    _refreshTimer = Timer.periodic(
      Duration(seconds: interval),
      (_) => _loadDepartures(),
    );
  }

  // ---------------------------------------------------------------------------
  // User actions
  // ---------------------------------------------------------------------------

  Future<void> _onStopSelected(Stop stop) async {
    setState(() {
      _selectedStop = stop;
      _isOffline = false;
    });
    await ref.read(stopProvider.notifier).saveLastStop(stop);
    await _loadDepartures();
  }

  /// Called by pull-to-refresh — bypasses in-memory cache.
  Future<void> _onRefresh() async {
    setState(() => _isOffline = false);
    await _loadDepartures(forceRefresh: true);
  }

  Future<void> _openSettings() async {
    await Navigator.push<void>(
      context,
      MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
    );
    if (mounted) _startAutoRefresh();
  }

  void _showSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
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

    // Search overlay — shown when user taps the search button.
    if (_showingSearch) {
      return _StopSearchView(
        message: '',
        api: ref.read(transportApiProvider),
        showPermissionSection: false,
        onClose: () => setState(() => _showingSearch = false),
        onStopSelected: (stop) {
          // Add the searched stop to the list if not already present.
          final updated = List<Stop>.from(_nearbyStops);
          if (!updated.any((s) => s.id == stop.id)) updated.insert(0, stop);
          setState(() {
            _nearbyStops = updated;
            _selectedStop = stop;
            _showingSearch = false;
            _isOffline = false;
          });
          ref.read(stopProvider.notifier).saveLastStop(stop);
          _loadDepartures(forceRefresh: true);
          _startAutoRefresh();
        },
      );
    }

    if (_isPermissionError) {
      // Offer both "Open Settings" and a manual stop search as fallback.
      return _StopSearchView(
        message: _errorMessage ?? '',
        api: ref.read(transportApiProvider),
        showPermissionSection: true,
        onStopSelected: (stop) {
          setState(() {
            _nearbyStops = [stop];
            _selectedStop = stop;
            _isPermissionError = false;
            _errorMessage = null;
          });
          ref.read(stopProvider.notifier).saveLastStop(stop);
          _loadDepartures();
          _startAutoRefresh();
        },
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
        // Offline banner — shown instead of a dismissable error so the user
        // still sees the (stale) departure board below.
        if (_isOffline)
          _OfflineBanner(lastUpdated: _lastUpdated, l10n: l10n),
        if (!_isOffline && _errorMessage != null)
          Container(
            width: double.infinity,
            color: Colors.red.shade900.withAlpha(180),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              _errorMessage!,
              style:
                  const TextStyle(color: Colors.white70, fontSize: 13),
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
      padding: const EdgeInsets.fromLTRB(16, 10, 8, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          StopSelector(
            stops: _nearbyStops,
            selectedStop: stop,
            onStopSelected: _onStopSelected,
            onSearchPressed: () => setState(() => _showingSearch = true),
          ),
          if (secondsAgo != null)
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                l10n?.updatedAgo(secondsAgo) ??
                    'Updated ${secondsAgo}s ago',
                style:
                    const TextStyle(color: Colors.white38, fontSize: 11),
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
            padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 32),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 48,
                    color: Colors.white24,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n?.noUpcomingDepartures ?? 'No upcoming departures',
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white54),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
    }

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      child: ListView.builder(
        key: ValueKey(_listVersion),
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: _departures.length,
        itemBuilder: (context, index) {
          final departure = _departures[index];
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
// Offline banner
// ---------------------------------------------------------------------------

class _OfflineBanner extends StatelessWidget {
  final DateTime? lastUpdated;
  final AppLocalizations? l10n;

  const _OfflineBanner({this.lastUpdated, this.l10n});

  @override
  Widget build(BuildContext context) {
    final timeStr = lastUpdated == null
        ? '—'
        : '${lastUpdated!.hour.toString().padLeft(2, '0')}:'
            '${lastUpdated!.minute.toString().padLeft(2, '0')}';

    final message = l10n?.offlineDataFrom(timeStr) ??
        'Offline — last data from $timeStr';

    return Container(
      width: double.infinity,
      color: const Color(0xFF7a5700),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.wifi_off, size: 14, color: Colors.amber),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.amber, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Stop search view
// ---------------------------------------------------------------------------

class _StopSearchView extends StatefulWidget {
  /// Error/info message shown at the top when [showPermissionSection] is true.
  final String message;
  final TransportApi api;
  final void Function(Stop stop) onStopSelected;

  /// When true, shows the location-permission error section with an
  /// "Open Settings" button. Set to false when used as a search overlay.
  final bool showPermissionSection;

  /// Called when the user taps the back/close button. When null, no close
  /// button is shown (e.g. permission-denied flow where there is no board
  /// to return to).
  final VoidCallback? onClose;

  const _StopSearchView({
    required this.message,
    required this.api,
    required this.onStopSelected,
    this.showPermissionSection = true,
    this.onClose,
  });

  @override
  State<_StopSearchView> createState() => _StopSearchViewState();
}

class _StopSearchViewState extends State<_StopSearchView> {
  final _controller = TextEditingController();
  List<Stop> _results = [];
  bool _searching = false;
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String query) {
    _debounce?.cancel();
    if (query.trim().length < 2) {
      setState(() => _results = []);
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      setState(() => _searching = true);
      try {
        final results = await widget.api.searchStops(query.trim());
        if (mounted) setState(() => _results = results);
      } catch (_) {
        // Silent — empty list is shown
      } finally {
        if (mounted) setState(() => _searching = false);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        Container(
          color: const Color(0xFF16213e),
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 16),
          child: Column(
            children: [
              // Close button row — shown when an onClose callback is provided.
              if (widget.onClose != null)
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white70),
                    onPressed: widget.onClose,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ),
              // Permission error section — only for the location-denied flow.
              if (widget.showPermissionSection) ...[
                const SizedBox(height: 8),
                const Icon(
                  Icons.location_off_outlined,
                  size: 40,
                  color: Colors.white38,
                ),
                const SizedBox(height: 12),
                Text(
                  widget.message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                ),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: Geolocator.openAppSettings,
                  icon: const Icon(Icons.settings_outlined, size: 16),
                  label: Text(l10n?.openSettings ?? 'Open Settings'),
                ),
                const Divider(color: Colors.white24, height: 28),
                Text(
                  l10n?.searchStopTitle ?? 'Search for a stop',
                  style: const TextStyle(color: Colors.white54, fontSize: 13),
                ),
                const SizedBox(height: 8),
              ] else
                const SizedBox(height: 4),
              TextField(
                controller: _controller,
                onChanged: _onQueryChanged,
                autofocus: true,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: l10n?.searchStopHint ?? 'Search...',
                  hintStyle: const TextStyle(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search, color: Colors.white38),
                  filled: true,
                  fillColor: const Color(0xFF0f3460),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 10),
                ),
              ),
            ],
          ),
        ),
        if (_searching) const LinearProgressIndicator(minHeight: 2),
        // Search results
        Expanded(
          child: _results.isEmpty
              ? Center(
                  child: Text(
                    _controller.text.length >= 2
                        ? (l10n?.noSearchResults ?? 'No stops found')
                        : '',
                    style: const TextStyle(color: Colors.white38),
                  ),
                )
              : ListView.builder(
                  itemCount: _results.length,
                  itemBuilder: (context, i) {
                    final stop = _results[i];
                    return ListTile(
                      leading: const Icon(
                        Icons.train_outlined,
                        color: Colors.white54,
                      ),
                      title: Text(
                        stop.name,
                        style: const TextStyle(color: Colors.white),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      onTap: () => widget.onStopSelected(stop),
                    );
                  },
                ),
        ),
      ],
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
