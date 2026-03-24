import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('de'),
    Locale('en'),
    Locale('fr'),
    Locale('it')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Departure Board'**
  String get appTitle;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading...'**
  String get loading;

  /// No description provided for @noConnection.
  ///
  /// In en, this message translates to:
  /// **'No internet connection'**
  String get noConnection;

  /// No description provided for @locationDenied.
  ///
  /// In en, this message translates to:
  /// **'Location access denied'**
  String get locationDenied;

  /// No description provided for @locationDisabled.
  ///
  /// In en, this message translates to:
  /// **'Location services disabled'**
  String get locationDisabled;

  /// No description provided for @locationTimeout.
  ///
  /// In en, this message translates to:
  /// **'Could not determine your location. Please try again.'**
  String get locationTimeout;

  /// No description provided for @noStopsFound.
  ///
  /// In en, this message translates to:
  /// **'No stops found near your location.'**
  String get noStopsFound;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @openSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Settings'**
  String get openSettings;

  /// No description provided for @openLocationSettings.
  ///
  /// In en, this message translates to:
  /// **'Open Location Settings'**
  String get openLocationSettings;

  /// No description provided for @settingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settingsTitle;

  /// No description provided for @departureCount.
  ///
  /// In en, this message translates to:
  /// **'Number of departures'**
  String get departureCount;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @refreshInterval.
  ///
  /// In en, this message translates to:
  /// **'Auto-refresh'**
  String get refreshInterval;

  /// No description provided for @seconds.
  ///
  /// In en, this message translates to:
  /// **'{n} seconds'**
  String seconds(int n);

  /// No description provided for @minutes.
  ///
  /// In en, this message translates to:
  /// **'{n} min'**
  String minutes(int n);

  /// No description provided for @departingNow.
  ///
  /// In en, this message translates to:
  /// **'Now'**
  String get departingNow;

  /// No description provided for @updatedAgo.
  ///
  /// In en, this message translates to:
  /// **'Updated {n}s ago'**
  String updatedAgo(int n);

  /// No description provided for @nearbyStops.
  ///
  /// In en, this message translates to:
  /// **'Nearby stops'**
  String get nearbyStops;

  /// No description provided for @noDepartures.
  ///
  /// In en, this message translates to:
  /// **'No departures available.'**
  String get noDepartures;

  /// No description provided for @disruption.
  ///
  /// In en, this message translates to:
  /// **'Disruption'**
  String get disruption;

  /// No description provided for @checkSbb.
  ///
  /// In en, this message translates to:
  /// **'Check SBB app for details'**
  String get checkSbb;

  /// No description provided for @about.
  ///
  /// In en, this message translates to:
  /// **'About'**
  String get about;

  /// No description provided for @dataSource.
  ///
  /// In en, this message translates to:
  /// **'Data: transport.opendata.ch'**
  String get dataSource;

  /// No description provided for @platform.
  ///
  /// In en, this message translates to:
  /// **'Platform'**
  String get platform;

  /// No description provided for @langDe.
  ///
  /// In en, this message translates to:
  /// **'Deutsch'**
  String get langDe;

  /// No description provided for @langFr.
  ///
  /// In en, this message translates to:
  /// **'Français'**
  String get langFr;

  /// No description provided for @langIt.
  ///
  /// In en, this message translates to:
  /// **'Italiano'**
  String get langIt;

  /// No description provided for @langEn.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get langEn;

  /// No description provided for @offlineDataFrom.
  ///
  /// In en, this message translates to:
  /// **'Offline — last data from {time}'**
  String offlineDataFrom(String time);

  /// No description provided for @searchStopTitle.
  ///
  /// In en, this message translates to:
  /// **'Search for a stop'**
  String get searchStopTitle;

  /// No description provided for @searchStopHint.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get searchStopHint;

  /// No description provided for @noSearchResults.
  ///
  /// In en, this message translates to:
  /// **'No stops found'**
  String get noSearchResults;

  /// No description provided for @usingLastLocation.
  ///
  /// In en, this message translates to:
  /// **'Using last known location'**
  String get usingLastLocation;

  /// No description provided for @noUpcomingDepartures.
  ///
  /// In en, this message translates to:
  /// **'No upcoming departures'**
  String get noUpcomingDepartures;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['de', 'en', 'fr', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
