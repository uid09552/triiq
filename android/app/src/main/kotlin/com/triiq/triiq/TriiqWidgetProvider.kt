package com.triiq.triiq

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget: today's planned sessions and current form. Flutter
 * writes the strings (see lib/data/home_widget_data.dart); this only lays
 * them out and opens the app on tap.
 */
class TriiqWidgetProvider : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = RemoteViews(context.packageName, R.layout.triiq_widget)

            val s1 = widgetData.getString("w_session1", "") ?: ""
            val s2 = widgetData.getString("w_session2", "") ?: ""
            val extra = widgetData.getString("w_extra", "") ?: ""
            val done = widgetData.getString("w_done", "") ?: ""
            val form = widgetData.getString("w_form", "") ?: ""
            val fitness = widgetData.getString("w_fitness", "") ?: ""
            val updated = widgetData.getString("w_updated", "") ?: ""

            views.setTextViewText(
                R.id.widget_session1,
                if (s1.isEmpty()) context.getString(R.string.widget_no_session) else s1,
            )
            views.setViewVisibility(R.id.widget_session2, if (s2.isEmpty()) View.GONE else View.VISIBLE)
            views.setTextViewText(R.id.widget_session2, s2)
            views.setViewVisibility(R.id.widget_extra, if (extra.isEmpty()) View.GONE else View.VISIBLE)
            views.setTextViewText(R.id.widget_extra, extra)
            views.setViewVisibility(R.id.widget_done, if (done.isEmpty()) View.GONE else View.VISIBLE)
            views.setTextViewText(R.id.widget_done, context.getString(R.string.widget_done, done))
            views.setTextViewText(R.id.widget_form, if (form.isEmpty()) "–" else form)
            views.setTextViewText(R.id.widget_fitness, fitness)
            views.setTextViewText(R.id.widget_updated, updated)

            bindRing(views, widgetData, "swim", R.id.ring_swim_box, R.id.ring_swim, R.id.ring_swim_pct, R.id.ring_swim_val)
            bindRing(views, widgetData, "cycle", R.id.ring_cycle_box, R.id.ring_cycle, R.id.ring_cycle_pct, R.id.ring_cycle_val)
            bindRing(views, widgetData, "run", R.id.ring_run_box, R.id.ring_run, R.id.ring_run_pct, R.id.ring_run_val)
            val anyRing = listOf("swim", "cycle", "run").any { !widgetData.getString("w_${it}_pct", "").isNullOrEmpty() }
            views.setViewVisibility(R.id.widget_rings, if (anyRing) View.VISIBLE else View.GONE)

            val launch = context.packageManager.getLaunchIntentForPackage(context.packageName)
            if (launch != null) {
                val pending = PendingIntent.getActivity(
                    context,
                    0,
                    launch,
                    PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE,
                )
                views.setOnClickPendingIntent(R.id.widget_root, pending)
            }
            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    /** One weekly-target ring: hidden when that sport has no target. */
    private fun bindRing(
        views: RemoteViews,
        data: SharedPreferences,
        sport: String,
        box: Int,
        ring: Int,
        pctView: Int,
        valView: Int,
    ) {
        val pct = (data.getString("w_${sport}_pct", "") ?: "").toIntOrNull()
        if (pct == null) {
            views.setViewVisibility(box, View.GONE)
            return
        }
        views.setViewVisibility(box, View.VISIBLE)
        views.setProgressBar(ring, 100, pct.coerceIn(0, 100), false)
        views.setTextViewText(pctView, "$pct%")
        views.setTextViewText(valView, data.getString("w_${sport}_val", "") ?: "")
    }
}
