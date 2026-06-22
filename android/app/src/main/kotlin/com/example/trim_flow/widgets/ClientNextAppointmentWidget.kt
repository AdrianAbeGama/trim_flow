package com.example.trim_flow.widgets

import android.appwidget.AppWidgetManager
import android.content.Context
import android.content.SharedPreferences
import android.net.Uri
import android.view.View
import android.widget.RemoteViews
import com.example.trim_flow.MainActivity
import com.example.trim_flow.R
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetProvider

class ClientNextAppointmentWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_client_next_appointment)
            val time = widgetData.getString("client_time", null)

            if (time.isNullOrEmpty()) {
                views.setViewVisibility(R.id.client_empty, View.VISIBLE)
                views.setViewVisibility(R.id.client_time, View.GONE)
                views.setViewVisibility(R.id.client_line1, View.GONE)
                views.setViewVisibility(R.id.client_line2, View.GONE)
            } else {
                views.setViewVisibility(R.id.client_empty, View.GONE)
                views.setViewVisibility(R.id.client_time, View.VISIBLE)
                views.setViewVisibility(R.id.client_line1, View.VISIBLE)
                views.setViewVisibility(R.id.client_line2, View.VISIBLE)
                views.setTextViewText(R.id.client_time, time)
                views.setTextViewText(R.id.client_line1, widgetData.getString("client_line1", "") ?: "")
                views.setTextViewText(R.id.client_line2, widgetData.getString("client_line2", "") ?: "")
            }

            val pending = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("trimflow://widget/next-appointment"),
            )
            views.setOnClickPendingIntent(R.id.client_root, pending)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
