package com.example.trim_flow.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.os.Build
import android.os.SystemClock
import android.view.View
import android.widget.RemoteViews
import com.example.trim_flow.MainActivity
import com.example.trim_flow.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class ClientCountdownWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_client_countdown)
            val time = widgetData.getString("client_time", null)
            val target = widgetData.getString("client_target_ms", "0")?.toLongOrNull() ?: 0L

            if (time.isNullOrEmpty() || target <= 0L) {
                views.setTextViewText(R.id.client_b_time, "Sin cita")
                views.setTextViewText(R.id.client_b_sub, "Reserva tu próximo corte")
                views.setViewVisibility(R.id.client_b_text, View.GONE)
                views.setViewVisibility(R.id.client_b_chrono, View.GONE)
            } else {
                views.setTextViewText(R.id.client_b_time, time)
                views.setTextViewText(R.id.client_b_sub, widgetData.getString("client_line1", "") ?: "")
                val remaining = target - System.currentTimeMillis()
                if (remaining in 1 until 3_600_000L) {
                    views.setViewVisibility(R.id.client_b_text, View.GONE)
                    views.setViewVisibility(R.id.client_b_chrono, View.VISIBLE)
                    views.setChronometer(
                        R.id.client_b_chrono,
                        SystemClock.elapsedRealtime() + remaining,
                        "%s",
                        true,
                    )
                    if (Build.VERSION.SDK_INT >= 24) {
                        views.setChronometerCountDown(R.id.client_b_chrono, true)
                    }
                } else {
                    views.setViewVisibility(R.id.client_b_chrono, View.GONE)
                    views.setViewVisibility(R.id.client_b_text, View.VISIBLE)
                    views.setTextViewText(R.id.client_b_text, formatRemaining(remaining))
                }
            }

            val pending = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("trimflow://widget/next-appointment"),
            )
            views.setOnClickPendingIntent(R.id.client_b_root, pending)
            appWidgetManager.updateAppWidget(id, views)
        }
    }

    private fun formatRemaining(ms: Long): String {
        if (ms <= 0L) return "Es ahora"
        val totalMin = ms / 60000L
        val days = totalMin / 1440L
        val hours = (totalMin % 1440L) / 60L
        val mins = totalMin % 60L
        return when {
            days >= 1L -> "Faltan $days día" + if (days > 1L) "s" else ""
            hours >= 1L -> "En $hours h $mins m"
            else -> "En $mins min"
        }
    }
}
