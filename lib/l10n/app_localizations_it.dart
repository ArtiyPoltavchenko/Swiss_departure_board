// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'Tabella delle partenze';

  @override
  String get loading => 'Caricamento...';

  @override
  String get noConnection => 'Nessuna connessione internet';

  @override
  String get locationDenied => 'Accesso alla posizione negato';

  @override
  String get locationDisabled => 'Servizi di localizzazione disattivati';

  @override
  String get locationTimeout =>
      'Impossibile determinare la posizione. Riprovare.';

  @override
  String get noStopsFound => 'Nessuna fermata trovata nelle vicinanze.';

  @override
  String get retry => 'Riprova';

  @override
  String get openSettings => 'Apri impostazioni';

  @override
  String get openLocationSettings => 'Apri impostazioni di posizione';

  @override
  String get settingsTitle => 'Impostazioni';

  @override
  String get departureCount => 'Numero di partenze';

  @override
  String get language => 'Lingua';

  @override
  String get refreshInterval => 'Aggiornamento automatico';

  @override
  String seconds(int n) {
    return '$n secondi';
  }

  @override
  String minutes(int n) {
    return '$n min';
  }

  @override
  String get departingNow => 'Ora';

  @override
  String updatedAgo(int n) {
    return 'Aggiornato ${n}s fa';
  }

  @override
  String get nearbyStops => 'Fermate vicine';

  @override
  String get noDepartures => 'Nessuna partenza disponibile.';

  @override
  String get disruption => 'Perturbazione';

  @override
  String get checkSbb => 'Controlla l\'app FFS per i dettagli';

  @override
  String get about => 'Informazioni';

  @override
  String get dataSource => 'Dati: transport.opendata.ch';

  @override
  String get platform => 'Binario';

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
    return 'Offline — ultimi dati delle $time';
  }

  @override
  String get searchStopTitle => 'Cerca una fermata';

  @override
  String get searchStopHint => 'Cerca...';

  @override
  String get noSearchResults => 'Nessuna fermata trovata';

  @override
  String get usingLastLocation => 'Utilizzo dell\'ultima posizione nota';
}
