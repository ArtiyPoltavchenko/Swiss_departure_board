// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTitle => 'Abfahrtstafel';

  @override
  String get loading => 'Laden...';

  @override
  String get noConnection => 'Keine Internetverbindung';

  @override
  String get locationDenied => 'Standortzugriff verweigert';

  @override
  String get locationDisabled => 'Ortungsdienste deaktiviert';

  @override
  String get locationTimeout =>
      'Standort konnte nicht ermittelt werden. Bitte erneut versuchen.';

  @override
  String get noStopsFound => 'Keine Haltestellen in der Nähe gefunden.';

  @override
  String get retry => 'Wiederholen';

  @override
  String get openSettings => 'Einstellungen öffnen';

  @override
  String get openLocationSettings => 'Ortungseinstellungen öffnen';

  @override
  String get settingsTitle => 'Einstellungen';

  @override
  String get departureCount => 'Anzahl Abfahrten';

  @override
  String get language => 'Sprache';

  @override
  String get refreshInterval => 'Automatische Aktualisierung';

  @override
  String seconds(int n) {
    return '$n Sekunden';
  }

  @override
  String minutes(int n) {
    return '$n Min.';
  }

  @override
  String get departingNow => 'Jetzt';

  @override
  String updatedAgo(int n) {
    return 'Aktualisiert vor ${n}s';
  }

  @override
  String get nearbyStops => 'Nahe Haltestellen';

  @override
  String get noDepartures => 'Keine Abfahrten verfügbar.';

  @override
  String get disruption => 'Störung';

  @override
  String get checkSbb => 'Details in der SBB-App';

  @override
  String get about => 'Über die App';

  @override
  String get dataSource => 'Daten: transport.opendata.ch';

  @override
  String get platform => 'Gleis';

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
    return 'Offline — letzte Daten von $time';
  }

  @override
  String get searchStopTitle => 'Haltestelle suchen';

  @override
  String get searchStopHint => 'Suchen...';

  @override
  String get noSearchResults => 'Keine Haltestellen gefunden';

  @override
  String get usingLastLocation => 'Letzten bekannten Standort verwendet';
}
