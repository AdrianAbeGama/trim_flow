package com.example.trim_flow.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.widget.RemoteViews
import com.example.trim_flow.MainActivity
import com.example.trim_flow.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class BarberTodayWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_barber_today)
            views.setTextViewText(
                R.id.barber_summary,
                widgetData.getString("barber_summary", "Sin cortes hoy") ?: "Sin cortes hoy",
            )
            views.setTextViewText(
                R.id.barber_next,
                widgetData.getString("barber_next", "Sin próximas citas") ?: "Sin próximas citas",
            )

            // Abrir la app (al toque general y al boton de walk-in).
            val open = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("trimflow://widget/today-summary"),
            )
            val walkIn = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("trimflow://widget/walk-in"),
            )
            views.setOnClickPendingIntent(R.id.barber_root, open)
            views.setOnClickPendingIntent(R.id.barber_walkin, walkIn)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
