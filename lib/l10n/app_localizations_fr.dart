// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTitle => 'Tableau des départs';

  @override
  String get loading => 'Chargement...';

  @override
  String get noConnection => 'Pas de connexion internet';

  @override
  String get locationDenied => 'Accès à la localisation refusé';

  @override
  String get locationDisabled => 'Services de localisation désactivés';

  @override
  String get locationTimeout =>
      'Impossible de déterminer votre position. Veuillez réessayer.';

  @override
  String get noStopsFound => 'Aucun arrêt trouvé à proximité.';

  @override
  String get retry => 'Réessayer';

  @override
  String get openSettings => 'Ouvrir les paramètres';

  @override
  String get openLocationSettings => 'Ouvrir les paramètres de localisation';

  @override
  String get settingsTitle => 'Paramètres';

  @override
  String get departureCount => 'Nombre de départs';

  @override
  String get language => 'Langue';

  @override
  String get refreshInterval => 'Mise à jour automatique';

  @override
  String seconds(int n) {
    return '$n secondes';
  }

  @override
  String minutes(int n) {
    return '$n min';
  }

  @override
  String get departingNow => 'Maintenant';

  @override
  String updatedAgo(int n) {
    return 'Mis à jour il y a ${n}s';
  }

  @override
  String get nearbyStops => 'Arrêts à proximité';

  @override
  String get noDepartures => 'Aucun départ disponible.';

  @override
  String get disruption => 'Perturbation';

  @override
  String get checkSbb => 'Voir l\'app CFF pour les détails';

  @override
  String get about => 'À propos';

  @override
  String get dataSource => 'Données : transport.opendata.ch';

  @override
  String get platform => 'Voie';

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
    return 'Hors ligne — dernières données de $time';
  }

  @override
  String get searchStopTitle => 'Rechercher un arrêt';

  @override
  String get searchStopHint => 'Rechercher...';

  @override
  String get noSearchResults => 'Aucun arrêt trouvé';

  @override
  String get usingLastLocation => 'Utilisation de la dernière position connue';
}
