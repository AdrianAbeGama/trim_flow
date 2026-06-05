# TrimFlow — Contexto del Proyecto

> Archivo que Claude lee al iniciar. Solo lo esencial: estructura, reglas y diseño premium.

SaaS B2B/B2C multi-tenant para barberías premium (Perú). Dos modos en una sola app:
- **Cliente (B2C)** — reservar, galería, fidelidad.
- **Barbero (B2B)** — agenda en vivo, walk-ins, panel admin.

Stack: **Flutter 3.11+** · **Supabase** (Postgres 17.6, project `uqhszqujcsmlmubeynfp`) · **BLoC** · **Clean Architecture** · **Freezed** · **get_it/Injectable** · **Hive CE** (galería local).

---

## 1. Reglas de Oro (OBLIGATORIO)

1. Clean Architecture + BLoC + Repository Pattern.
2. `@freezed` para todos los estados y eventos.
3. `get_it`: `@LazySingleton(as: XRepository)` para repos, `@injectable` para blocs. Blocs con runtime params (ej. `AgendaBloc.barberId`) NO se anotan; se instancian en la vista con `getIt<XRepository>()`.
4. `dart analyze lib` debe devolver **"No issues found!"** al terminar.
5. Estilo minimalista premium — **sin emojis en código**, **sin comentarios redundantes**.
6. Archivos **< 500 líneas**.
7. Si tocas anotaciones DI/freezed: `dart run build_runner build --delete-conflicting-outputs`.

### Backend (ADR-0015/0018)
- **Mutaciones SOLO vía RPCs `SECURITY DEFINER`**. Nunca INSERT/UPDATE/DELETE directo a tablas de dominio desde Flutter.
- MCP Supabase disponible **solo lectura** para auditar schema/datos. No tocar SQL/migraciones del socio.

### Git
- Mensajes `feat(scope): description` (lowercase, imperativo).
- Nunca `--no-verify`, nunca push a `main`, **nunca commit/push sin orden explícita**.

---

## 2. Estructura

```
lib/
├── app/view/                          App + LoadingApp (splash)
├── core/
│   ├── app_mode/                      AppModeBloc (modo cliente/barbero, auth)
│   ├── config/app_config.dart         Credenciales via --dart-define
│   ├── di/                            injection.dart + supabase_module.dart
│   ├── theme/                         TenantThemeBloc + tenant_branding_colors + extensión
│   └── widgets/
│       ├── avatar_premium.dart        Avatar con fallback iniciales
│       └── premium/                   ★ Sistema premium compartido (ver §3)
├── features/
│   ├── auth/                          Login Google OAuth
│   ├── barber/{view, agenda}/         Home barbero + Agenda Realtime
│   ├── gallery/                       Galería Pinterest (Hive CE)
│   ├── home/                          HomePage (cliente, 5 tabs; tab 4 = perfil)
│   ├── products/                      Productos (mock) + carrito + ofertas
│   ├── profile/                       ProfileBloc + citas/ticket
│   └── reservations/                  Flujo Reservar (wizard 5 fases + ticket)
└── main_{development,staging,production}.dart           # app Cliente
    main_business_{development,staging,production}.dart  # app Barbero (flavor business)
```

`packages/core/` — modelos compartidos (`UserProfile`, `Reservation`, `Service`, `BarberCenter`, `Professional`, `AppColorsInterface`, `AppMode`).

Flavors Android: `client` (`com.trimflow.app`) y `business` (`com.trimflow.business`). Lanzar:
```bash
flutter run -t lib/main_development.dart --flavor client --dart-define-from-file=env/dev.json -d <device>
```
`env/*.json` está en `.gitignore` (SUPABASE_URL, SUPABASE_ANON_KEY, FLAVOR).

---

## 3. Diseño Premium (lenguaje aprobado)

Estética: **dark premium tipo iOS** — fondos casi negros, acento del tenant, tipografía **Inter** (`google_fonts`), mucho aire, esquinas muy redondeadas (16–22), bordes finísimos (`white 0.05–0.06`), animaciones sutiles (`flutter_animate`), haptics. **NO** design system genérico ni gradientes/glow pesados; minimal y limpio.

### Colores del tenant (NO hardcodear)
`lib/core/theme/tenant_branding_colors.dart` lee **4 colores** del JSONB `tenants.branding`:
- `accent_color` → `context.primaryGold` (acento dominante, tiñe casi toda la UI)
- `primary_color` → `context.backgroundBlack`
- `secondary_color` → `tenantColors.surfaceDark`
- `tertiary_color` → `tenantColors.accentGold`

`textWhite`/`errorRed` fijos. **Usar siempre `context.primaryGold` etc.**, nunca dorados/colores hardcodeados.
Tenant de pruebas: **Barbería Ocean** (cuenta Adrián) — actualmente burdeos (`accent #9B1C31`).

### Primitivas premium compartidas — `lib/core/widgets/premium/`
Reutilizar SIEMPRE en vez de reimplementar:
- `premium_primitives.dart`: `PremiumPressable` (scale 0.97 + haptic), `PremiumSmartImage` (http/file/asset), `PremiumBackButton`, `PremiumPill`, `PremiumSectionLabel`, `PremiumEditingBadge` (accent configurable), `PremiumConfirmDelete` (sheet inferior — usar para TODO borrado).
- `premium_quick_action_card.dart`: `PremiumQuickActionCard` (CTA "crear/panel").
- `smart_calendar.dart`: `SmartCalendar` — calendario compartido (reservar + agenda) con **PageView** (slide real de semanas/meses), día seleccionado con contorno animado, dot blanco. API: `selectedDate`, `onDaySelected`, `firstSelectableDate?`, `markedDates?`, `collapseOnSelect`.
- `gallery_primitives.dart` es solo capa de compat (`typedef Gallery* = Premium*`). No agregar primitivas ahí.

Botón principal de acción (continuar/confirmar): **blanco/crema** `#F7F3EC` con texto negro.

### Iconos
- FontAwesome 11.x: `FaIcon(FontAwesomeIcons.X)` (NO `Icon(...)`). Material: `Icon(Icons.X)`.
- Widgets reusables: aceptar `Widget icon`/`IconBuilder`, no `IconData`.

### Persistencia
- `SharedPreferences` para flags (`access_code`, `app_mode`).
- `Hive CE` para galería (`Box<Map>` + `toMap/fromMap`, sin codegen). ❌ NO `isar`.

---

## 4. NO hacer
- ❌ INSERT/UPDATE/DELETE directo a tablas de dominio (viola ADR-0015).
- ❌ Tocar SQL/migraciones del socio, `injection.config.dart` ni `*.freezed.dart` (regenerados).
- ❌ Comentarios redundantes / emojis en código.
- ❌ `dependency_overrides` para forzar versiones (rompe generators).
- ❌ `setState` dentro de `build()` ni en `addPostFrameCallback` desde build.
- ❌ Commit/push sin orden explícita.

## 5. SIEMPRE hacer
- ✅ `dart analyze lib` limpio antes de declarar tarea completa.
- ✅ Reutilizar las primitivas de `core/widgets/premium/` y `AvatarPremium`.
- ✅ Repos `@LazySingleton(as: ...)`, blocs `@injectable`, state/event con `@freezed`.
- ✅ Pasar `BlocProvider.value(value: bloc)` en navegaciones Push.
- ✅ Colores SIEMPRE vía `context.primaryGold`/tenant, no hardcodeados.

---

## 6. Memoria
Memorias persistentes en `C:\Users\LENOVO\.claude\projects\C--Users-LENOVO-OneDrive-Desktop-Proyect-trim-flow\memory\` (índice en `MEMORY.md`). Guardar ahí reglas/gotchas nuevos del usuario.
