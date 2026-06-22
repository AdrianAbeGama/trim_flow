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

class ClientLoyaltyWidget : HomeWidgetProvider() {
    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray,
        widgetData: SharedPreferences,
    ) {
        appWidgetIds.forEach { id ->
            val views = RemoteViews(context.packageName, R.layout.widget_client_loyalty)
            val have = widgetData.getString("client_loyalty_have", "0")?.toIntOrNull() ?: 0
            val need = widgetData.getString("client_loyalty_need", "0")?.toIntOrNull() ?: 0
            val left = widgetData.getString("client_loyalty_left", "0")?.toIntOrNull() ?: 0

            views.setProgressBar(R.id.loyalty_bar, if (need > 0) need else 1, have, false)

            if (need > 0 && left == 0) {
                views.setTextViewText(R.id.loyalty_title, "¡Corte gratis disponible!")
                views.setTextViewText(R.id.loyalty_sub, "Pídelo en tu próxima visita")
            } else {
                views.setTextViewText(R.id.loyalty_title, "Te falta $left corte" + if (left != 1) "s" else "")
                views.setTextViewText(R.id.loyalty_sub, "para tu corte gratis")
            }

            val time = widgetData.getString("client_time", null)
            val next = if (time.isNullOrEmpty()) {
                "Sin cita próxima"
            } else {
                "Próxima: $time · ${widgetData.getString("client_line1", "") ?: ""}"
            }
            views.setTextViewText(R.id.loyalty_next, next)

            val pending = HomeWidgetLaunchIntent.getActivity(
                context,
                MainActivity::class.java,
                Uri.parse("trimflow://widget/loyalty"),
            )
            views.setOnClickPendingIntent(R.id.loyalty_root, pending)
            appWidgetManager.updateAppWidget(id, views)
        }
    }
}
