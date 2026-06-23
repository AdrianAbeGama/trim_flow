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

class ClientDateBlockWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_client_date_block)
            val time = widgetData.getString("client_time", null)

            if (time.isNullOrEmpty()) {
                views.setTextViewText(R.id.date_day, "—")
                views.setTextViewText(R.id.date_weekday, "")
                views.setTextViewText(R.id.date_time, "Sin cita")
                views.setTextViewText(R.id.date_line1, "Reserva tu próximo corte")
            } else {
                views.setTextViewText(R.id.date_day, widgetData.getString("client_day", "") ?: "")
                views.setTextViewText(R.id.date_weekday, widgetData.getString("client_weekday", "") ?: "")
                views.setTextViewText(R.id.date_time, time)
                views.setTextViewText(R.id.date_line1, widgetData.getString("client_line1", "") ?: "")
            }

            val pending = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("trimflow://widget/next-appointment"),
            )
            views.setOnClickPendingIntent(R.id.date_root, pending)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
