import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:swiss_departure_board/l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'providers/settings_provider.dart';
import 'screens/board_screen.dart';

/// Root application widget.
///
/// Watches [settingsProvider] so that the locale updates immediately when the
/// user changes the language in Settings.
class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    // Use saved locale, fall back to device locale while loading.
    final locale = settingsAsync.valueOrNull?.locale != null
        ? Locale(settingsAsync.valueOrNull!.locale)
        : null;

    return MaterialApp(
      title: 'Swiss Departure Board',
      locale: locale,
      theme: _buildTheme(),
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('de'),
        Locale('fr'),
        Locale('it'),
        Locale('en'),
      ],
      home: const BoardScreen(),
    );
  }

  static ThemeData _buildTheme() {
    const bgColor = Color(0xFF1a1a2e);
    const surfaceColor = Color(0xFF16213e);
    const primaryColor = Color(0xFFffd700);

    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: bgColor,
      colorScheme: const ColorScheme.dark(
        primary: primaryColor,
        surface: surfaceColor,
        onSurface: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: bgColor,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2a2a4a),
        thickness: 1,
      ),
      listTileTheme: const ListTileThemeData(
        tileColor: Colors.transparent,
        textColor: Colors.white,
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: surfaceColor,
      ),
      iconTheme: const IconThemeData(color: Colors.white70),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
      ),
    );
  }
}
