package ch.swissdeparture.swiss_departure_board

import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.graphics.Color
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetBackgroundIntent
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Android AppWidgetProvider for the Swiss Departure Board home screen widget.
 *
 * Data is written from Dart via [WidgetService.updateWidgetData] using the
 * home_widget package, which stores values in SharedPreferences under the
 * key file "HomeWidgetPlugin".
 *
 * Keys read:
 *   widget_stop_name            String  — stop display name
 *   widget_departure_count      Int     — number of valid departure rows (0–4)
 *   widget_departure_N_line     String  — line number/label
 *   widget_departure_N_dest     String  — destination name
 *   widget_departure_N_time     String  — "4 min" or "Now"
 *   widget_departure_N_color    String  — hex color for badge, e.g. "#e20000"
 */
class HomeWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
    ) {
        for (id in appWidgetIds) {
            updateWidget(context, appWidgetManager, id)
        }
    }

    companion object {

        private val rowIds = intArrayOf(
            R.id.widget_row_0, R.id.widget_row_1,
            R.id.widget_row_2, R.id.widget_row_3,
        )
        private val lineIds = intArrayOf(
            R.id.widget_line_0, R.id.widget_line_1,
            R.id.widget_line_2, R.id.widget_line_3,
        )
        private val destIds = intArrayOf(
            R.id.widget_dest_0, R.id.widget_dest_1,
            R.id.widget_dest_2, R.id.widget_dest_3,
        )
        private val timeIds = intArrayOf(
            R.id.widget_time_0, R.id.widget_time_1,
            R.id.widget_time_2, R.id.widget_time_3,
        )

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int,
        ) {
            val data = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.widget_layout)

            // ── Stop name ────────────────────────────────────────────────────
            val stopName = data.getString("widget_stop_name", null)
                ?: context.getString(R.string.widget_stop_loading)
            views.setTextViewText(R.id.widget_stop_name, stopName)

            // ── Departure rows ───────────────────────────────────────────────
            val count = data.getInt("widget_departure_count", 0)

            for (i in 0..3) {
                if (i < count) {
                    val line = data.getString("widget_departure_${i}_line", "") ?: ""
                    val dest = data.getString("widget_departure_${i}_dest", "") ?: ""
                    val time = data.getString("widget_departure_${i}_time", "") ?: ""
                    val colorHex = data.getString("widget_departure_${i}_color", "#666666")
                        ?: "#666666"

                    views.setViewVisibility(rowIds[i], View.VISIBLE)
                    views.setTextViewText(lineIds[i], line)
                    views.setTextViewText(destIds[i], dest)
                    views.setTextViewText(timeIds[i], time)

                    // Apply category-specific badge color.
                    try {
                        views.setInt(lineIds[i], "setBackgroundColor", Color.parseColor(colorHex))
                    } catch (_: IllegalArgumentException) {
                        views.setInt(lineIds[i], "setBackgroundColor", Color.parseColor("#666666"))
                    }

                    // "Now" departures shown in green.
                    val timeColor = if (time == "Now") Color.parseColor("#66FF99")
                                    else Color.parseColor("#ffd700")
                    views.setTextColor(timeIds[i], timeColor)
                } else {
                    views.setViewVisibility(rowIds[i], View.GONE)
                }
            }

            // ── Tap widget → open app ────────────────────────────────────────
            val launchIntent = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
            )
            views.setOnClickPendingIntent(R.id.widget_root, launchIntent)

            // ── Tap refresh → Dart background callback ───────────────────────
            val refreshIntent = HomeWidgetBackgroundIntent.getBroadcast(
                context,
                Uri.parse("swissdepartureboard://refresh"),
            )
            views.setOnClickPendingIntent(R.id.widget_refresh_btn, refreshIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
