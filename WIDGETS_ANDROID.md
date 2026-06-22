# Widgets de pantalla de inicio (Android)

> **Estado: OCULTOS por ahora.** El código está completo y probado, pero los
> widgets están deshabilitados (`android:enabled="false"`) para no exponerlos
> todavía. No aparecen en el selector de widgets del sistema.

Paquete: **`home_widget: ^0.9.3`**. Solo Android (el mismo paquete sirve para iOS
si algún día se hace esa versión).

---

## Cómo REACTIVARLOS

Poner `android:enabled="true"` en los `<receiver>` de:
- `android/app/src/client/AndroidManifest.xml` (3 widgets del cliente)
- `android/app/src/business/AndroidManifest.xml` (1 widget del barbero)

Recompilar e instalar. Listo — vuelven a aparecer en el selector.

---

## Qué widgets hay

### App cliente (`com.trimflow.app`) — 3 estilos, misma data
| Widget | Muestra |
|---|---|
| **Cuenta regresiva** | Hora + servicio/barbero + **cronómetro en vivo** ("En 18 min" baja solo cuando falta < 1 h; "Faltan 2 días" cuando es lejano) |
| **Fidelidad** | Barra dorada de progreso + "Te falta X cortes" + próxima cita |
| **Bloque de fecha** | Tile dorado (día + día de semana) + hora + servicio |

Data: la **cita más cercana entre TODAS las barberías** del cliente (cross-tenant)
+ los puntos de fidelidad. La empuja `ProfileBloc._pushClientWidget`.

### App barbero (`com.trimflow.business`) — 1 widget
| Widget | Muestra |
|---|---|
| **Resumen de hoy** | Cortes + ingresos del día + próxima cita + botón **"Registrar walk-in"** (abre la app en la Agenda con el sheet de walk-in) |

Data: `fetchTodaySummary(barberId)`. La empuja la vista de agenda (`BlocListener`).

### Pendiente (tanda barbero, sin construir)
E · Lista de citas de hoy · F · Ingresos + contador de walk-in · K · Meta del día ·
L · Agenda visual del día.

---

## Arquitectura

**Nativo** (`android/app/src/main/`):
- `res/layout/widget_*.xml` — los layouts (RemoteViews).
- `kotlin/com/example/trim_flow/widgets/*.kt` — providers (extienden `HomeWidgetProvider`).
- `res/xml/*_info.xml` — el appwidget-provider de cada widget.
- `res/drawable/widget_*.xml` — fondos premium (negro, pill dorado, tile dorado, barra de progreso dorada, botón crema).
- **Manifests por flavor** (`src/client`, `src/business`) declaran los `<receiver>`,
  así **cada app muestra SOLO sus widgets** (si van en el `main`, el selector
  muestra los de ambas apps y confunde).

**Dart** (`lib/core/widgets/home_screen/`):
- `home_widget_keys.dart` — nombres calificados de los providers.
- `client_widget_service.dart` — arma y empuja la data del cliente (cross-tenant).
- `barber_widget_service.dart` — arma y empuja la data del barbero.
- `widget_launch.dart` — señal para abrir el walk-in desde el widget.

**Flujo:** la app guarda data con `HomeWidget.saveWidgetData(...)` → llama
`HomeWidget.updateWidget(qualifiedAndroidName: ...)` → el provider nativo lee la
data de `SharedPreferences("HomeWidgetPreferences")` y pinta el RemoteViews.

---

## Gotchas (aprendidos a la mala — IMPORTANTES)

1. **`<View>` simple NO está permitido en RemoteViews** → "Can't load widget".
   Usar `LinearLayout`/`TextView` para divisores. Vistas permitidas: FrameLayout,
   LinearLayout, RelativeLayout, GridLayout, TextView, ImageView, Button,
   ProgressBar, Chronometer, ImageButton, AnalogClock, ViewFlipper, ListView…
2. **`qualifiedAndroidName`** en `updateWidget` (NO `androidName`): el package
   Kotlin (`com.example.trim_flow`) ≠ applicationId (`com.trimflow.app`/`.business`).
3. **Barra dorada:** `progressTint` es poco fiable en MIUI → usar
   `progressDrawable` propio (`widget_progress_gold.xml`, layer-list con `<clip>`).
4. **Cronómetro en vivo:** `Chronometer` + `setChronometer(base,…)` +
   `setChronometerCountDown(true)` (API 24+, guardar con `Build.VERSION.SDK_INT`).
5. **Refresco:** se actualiza al abrir la app (cold start). En resume caliente
   NO re-empuja → puede salir viejo. Mejora pendiente: refrescar en `resumed` o
   con WorkManager en segundo plano.

---

## Testing

- El **Xiaomi** bloquea `adb input` (INJECT_EVENTS) y la pantalla se duerme
  (screencap negro) → no se pueden colocar/ver widgets por script ahí.
- En **emulador** sí hay input. Inyectar data demo sin login:
  `adb -s <emu> shell run-as com.trimflow.app tee /data/data/com.trimflow.app/shared_prefs/HomeWidgetPreferences.xml`
  (con `mkdir -p` antes). NO usar `sh -c 'cat > file'` por el quoting anidado de adb.
