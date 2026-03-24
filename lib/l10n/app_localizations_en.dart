// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Departure Board';

  @override
  String get loading => 'Loading...';

  @override
  String get noConnection => 'No internet connection';

  @override
  String get locationDenied => 'Location access denied';

  @override
  String get locationDisabled => 'Location services disabled';

  @override
  String get locationTimeout =>
      'Could not determine your location. Please try again.';

  @override
  String get noStopsFound => 'No stops found near your location.';

  @override
  String get retry => 'Retry';

  @override
  String get openSettings => 'Open Settings';

  @override
  String get openLocationSettings => 'Open Location Settings';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get departureCount => 'Number of departures';

  @override
  String get language => 'Language';

  @override
  String get refreshInterval => 'Auto-refresh';

  @override
  String seconds(int n) {
    return '$n seconds';
  }

  @override
  String minutes(int n) {
    return '$n min';
  }

  @override
  String get departingNow => 'Now';

  @override
  String updatedAgo(int n) {
    return 'Updated ${n}s ago';
  }

  @override
  String get nearbyStops => 'Nearby stops';

  @override
  String get noDepartures => 'No departures available.';

  @override
  String get disruption => 'Disruption';

  @override
  String get checkSbb => 'Check SBB app for details';

  @override
  String get about => 'About';

  @override
  String get dataSource => 'Data: transport.opendata.ch';

  @override
  String get platform => 'Platform';

  @override
  String get langDe => 'Deutsch';

  @override
  String get langFr => 'Français';

  @override
  String get langIt => 'Italiano';

  @override
  String get langEn => 'English';

  @override
  String offlineDataFrom(String time) {
    return 'Offline — last data from $time';
  }

  @override
  String get searchStopTitle => 'Search for a stop';

  @override
  String get searchStopHint => 'Search...';

  @override
  String get noSearchResults => 'No stops found';

  @override
  String get usingLastLocation => 'Using last known location';
}
