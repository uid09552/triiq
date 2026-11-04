package com.triiq.triiq

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.os.Bundle
import android.view.View
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetPlugin
import es.antonborri.home_widget.HomeWidgetProvider

/**
 * Home-screen widget: today's planned sessions, current form and weekly
 * target rings. Flutter writes the strings (see lib/data/home_widget_data.dart);
 * this lays them out — in one of four layouts chosen by the widget's size
 * (4×1 row, 2×2, 4×2, 4×3+) — and opens the app on tap.
 */
class TriiqWidgetProvider : HomeWidgetProvider() {
    /** Which layout fits the widget's current size (dp). */
    private enum class Size { WIDE, SMALL, MEDIUM, LARGE }

    private fun sizeOf(manager: AppWidgetManager, id: Int): Size {
        val options = manager.getAppWidgetOptions(id)
        val w = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_WIDTH, 250)
        val h = options.getInt(AppWidgetManager.OPTION_APPWIDGET_MIN_HEIGHT, 190)
        return when {
            h < 80 -> Size.WIDE          // one row: 4×1
            w < 180 -> Size.SMALL        // narrow: 2×2
            h < 150 -> Size.MEDIUM       // 4×2: no rings
            else -> Size.LARGE           // 4×3 and up: with the target rings
        }
    }

    override fun onAppWidgetOptionsChanged(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetId: Int,
        newOptions: Bundle,
    ) {
        super.onAppWidgetOptionsChanged(context, appWidgetManager, appWidgetId, newOptions)
        // Resized: pick the layout for the new size.
        onUpdate(context, appWidgetManager, intArrayOf(appWidgetId), HomeWidgetPlugin.getData(context))
    }

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { widgetId ->
            val views = when (sizeOf(appWidgetManager, widgetId)) {
                Size.WIDE -> wide(context, widgetData)
                Size.SMALL -> small(context, widgetData)
                Size.MEDIUM -> full(context, widgetData, rings = false)
                Size.LARGE -> full(context, widgetData, rings = true)
            }
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

    private fun str(data: SharedPreferences, key: String): String = data.getString(key, "") ?: ""

    /** "Easy run · 45 min · 40 TSS", or the no-session text. */
    private fun session(context: Context, data: SharedPreferences): String {
        val s1 = str(data, "w_session1")
        return if (s1.isEmpty()) context.getString(R.string.widget_no_session) else s1
    }

    private fun wide(context: Context, data: SharedPreferences): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.triiq_widget_wide)
        val extra = str(data, "w_extra")
        views.setTextViewText(
            R.id.wide_session,
            if (extra.isEmpty()) session(context, data) else "${session(context, data)} $extra",
        )
        views.setTextViewText(R.id.wide_form, str(data, "w_form").ifEmpty { "–" })
        return views
    }

    private fun small(context: Context, data: SharedPreferences): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.triiq_widget_small)
        val s2 = str(data, "w_session2")
        val extra = str(data, "w_extra")
        val text = buildString {
            append(session(context, data))
            if (s2.isNotEmpty()) append("\n").append(s2)
            if (extra.isNotEmpty()) append(" ").append(extra)
        }
        views.setTextViewText(R.id.small_session, text)
        views.setTextViewText(R.id.small_form, str(data, "w_form").ifEmpty { "–" })
        return views
    }

    private fun full(context: Context, widgetData: SharedPreferences, rings: Boolean): RemoteViews {
        val views = RemoteViews(context.packageName, R.layout.triiq_widget)
        val s2 = str(widgetData, "w_session2")
        val extra = str(widgetData, "w_extra")
        val done = str(widgetData, "w_done")
        val form = str(widgetData, "w_form")

        views.setTextViewText(R.id.widget_session1, session(context, widgetData))
        views.setViewVisibility(R.id.widget_session2, if (s2.isEmpty()) View.GONE else View.VISIBLE)
        views.setTextViewText(R.id.widget_session2, s2)
        views.setViewVisibility(R.id.widget_extra, if (extra.isEmpty()) View.GONE else View.VISIBLE)
        views.setTextViewText(R.id.widget_extra, extra)
        views.setViewVisibility(R.id.widget_done, if (done.isEmpty()) View.GONE else View.VISIBLE)
        views.setTextViewText(R.id.widget_done, context.getString(R.string.widget_done, done))
        views.setTextViewText(R.id.widget_form, if (form.isEmpty()) "–" else form)
        views.setTextViewText(R.id.widget_fitness, str(widgetData, "w_fitness"))
        views.setTextViewText(R.id.widget_updated, str(widgetData, "w_updated"))

        bindRing(views, widgetData, "swim", R.id.ring_swim_box, R.id.ring_swim, R.id.ring_swim_pct, R.id.ring_swim_val)
        bindRing(views, widgetData, "cycle", R.id.ring_cycle_box, R.id.ring_cycle, R.id.ring_cycle_pct, R.id.ring_cycle_val)
        bindRing(views, widgetData, "run", R.id.ring_run_box, R.id.ring_run, R.id.ring_run_pct, R.id.ring_run_val)
        val anyRing = listOf("swim", "cycle", "run").any { str(widgetData, "w_${it}_pct").isNotEmpty() }
        views.setViewVisibility(R.id.widget_rings, if (rings && anyRing) View.VISIBLE else View.GONE)
        return views
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
