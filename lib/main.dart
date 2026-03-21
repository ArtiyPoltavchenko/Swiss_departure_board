import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

import 'app.dart';
import 'services/widget_service.dart';

// ---------------------------------------------------------------------------
// WorkManager background task entry point.
//
// @pragma('vm:entry-point') is required so the Dart tree-shaker keeps this
// function when building a release APK.
// ---------------------------------------------------------------------------

/// Called by WorkManager in a separate isolate — no Flutter UI context.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    await WidgetService.updateWidgetData();
    return true;
  });
}

/// Called by home_widget when the user taps the refresh button in the widget.
/// Runs in the background isolate triggered by [HomeWidgetBackgroundReceiver].
@pragma('vm:entry-point')
Future<void> backgroundCallback(Uri? uri) async {
  if (uri?.host == 'refresh') {
    await WidgetService.updateWidgetData();
  }
}

// ---------------------------------------------------------------------------
// App entry point
// ---------------------------------------------------------------------------

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Register WorkManager callback dispatcher before any other plugin calls.
  await Workmanager().initialize(callbackDispatcher);

  // Schedule a periodic background task that refreshes the widget every 15 min.
  // ExistingWorkPolicy.keep: don't reschedule if task already queued.
  await Workmanager().registerPeriodicTask(
    'widget-refresh',
    'widgetRefresh',
    frequency: const Duration(minutes: 15),
    constraints: Constraints(networkType: NetworkType.connected),
    existingWorkPolicy: ExistingWorkPolicy.keep,
  );

  // Register the Dart callback for widget button taps.
  HomeWidget.registerInteractivityCallback(backgroundCallback);

  runApp(
    const ProviderScope(
      child: App(),
    ),
  );
}
