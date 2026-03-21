import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

import '../../version.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settingsAsync = ref.watch(settingsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.settingsTitle ?? 'Settings'),
      ),
      body: settingsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text(e.toString())),
        data: (settings) => _SettingsBody(settings: settings),
      ),
    );
  }
}

class _SettingsBody extends ConsumerWidget {
  final AppSettings settings;

  const _SettingsBody({required this.settings});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(settingsProvider.notifier);

    return ListView(
      children: [
        // ── Departure count ──────────────────────────────────────────────────
        _SettingsTile(
          label: l10n?.departureCount ?? 'Number of departures',
          trailing: _StyledDropdown<int>(
            value: settings.departureCount,
            items: const [5, 10, 15, 20],
            labelBuilder: (v) => '$v',
            onChanged: notifier.setDepartureCount,
          ),
        ),

        // ── Language ─────────────────────────────────────────────────────────
        _SettingsTile(
          label: l10n?.language ?? 'Language',
          trailing: _StyledDropdown<String>(
            value: settings.locale,
            items: const ['de', 'fr', 'it', 'en'],
            labelBuilder: (v) => _localeName(v, l10n),
            onChanged: notifier.setLocale,
          ),
        ),

        // ── Auto-refresh interval ─────────────────────────────────────────────
        _SettingsTile(
          label: l10n?.refreshInterval ?? 'Auto-refresh',
          trailing: _StyledDropdown<int>(
            value: settings.refreshIntervalSeconds,
            items: const [15, 30, 60, 120],
            labelBuilder: (v) => l10n?.seconds(v) ?? '$v s',
            onChanged: notifier.setRefreshInterval,
          ),
        ),

        const Divider(color: Colors.white12, height: 32),

        // ── About ─────────────────────────────────────────────────────────────
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Text(
            l10n?.about ?? 'About',
            style: const TextStyle(
              color: Colors.white54,
              fontSize: 12,
              letterSpacing: 1,
            ),
          ),
        ),
        _InfoTile(
          label: l10n?.appTitle ?? 'Departure Board',
          value: 'v$appVersion',
        ),
        _InfoTile(
          label: l10n?.dataSource ?? 'Data: transport.opendata.ch',
          value: '',
        ),
      ],
    );
  }

  static String _localeName(String code, AppLocalizations? l10n) {
    switch (code) {
      case 'de':
        return l10n?.langDe ?? 'Deutsch';
      case 'fr':
        return l10n?.langFr ?? 'Français';
      case 'it':
        return l10n?.langIt ?? 'Italiano';
      default:
        return l10n?.langEn ?? 'English';
    }
  }
}

// ── Shared tile layout ──────────────────────────────────────────────────────

class _SettingsTile extends StatelessWidget {
  final String label;
  final Widget trailing;

  const _SettingsTile({required this.label, required this.trailing});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;

  const _InfoTile({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          if (value.isNotEmpty)
            Text(value, style: const TextStyle(color: Colors.white54)),
        ],
      ),
    );
  }
}

// ── Styled dropdown shared component ────────────────────────────────────────

class _StyledDropdown<T> extends StatelessWidget {
  final T value;
  final List<T> items;
  final String Function(T) labelBuilder;
  final Future<void> Function(T) onChanged;

  const _StyledDropdown({
    required this.value,
    required this.items,
    required this.labelBuilder,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<T>(
      value: value,
      underline: const SizedBox.shrink(),
      dropdownColor: const Color(0xFF16213e),
      style: const TextStyle(color: Colors.white),
      iconEnabledColor: Colors.white54,
      items: items
          .map((item) => DropdownMenuItem<T>(
                value: item,
                child: Text(
                  labelBuilder(item),
                  style: const TextStyle(color: Colors.white),
                ),
              ))
          .toList(),
      onChanged: (v) {
        if (v != null) onChanged(v);
      },
    );
  }
}
