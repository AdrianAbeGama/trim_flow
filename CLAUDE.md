# TrimFlow — Contexto del Proyecto

> Archivo que Claude lee automáticamente al iniciar. Sintetiza todo lo que necesita saber para trabajar en este repo sin volver a auditar desde cero.

---

## 1. Qué es TrimFlow

SaaS B2B/B2C multi-tenant para barberías premium en Perú. Dos modos en una sola app:
- **Modo Cliente (B2C)** — agenda cortes, ve galería, acumula puntos de fidelidad
- **Modo Barbero (B2B)** — agenda en vivo, walk-ins, dashboard, panel admin

Stack: **Flutter 3.11+** · **Supabase** (Postgres 17.6, sa-east-1) · **BLoC** · **Clean Architecture** · **Freezed** · **get_it/Injectable** · **Hive CE** (galería local)

---

## 2. Reglas de Oro (README.md)

**OBLIGATORIO en cada tarea:**
1. Clean Architecture + BLoC + Repository Pattern
2. `@freezed` para todos los estados y eventos
3. `get_it` para inyección de dependencias (`@LazySingleton(as: ...)` para repos, `@injectable` para blocs)
4. `flutter analyze` debe devolver **"No issues found!"** al terminar
5. Paleta: **Negro `#000000` · Blanco `#FFFFFF` · Dorado `#D4AF37`**
6. Estilo minimalista premium — sin emojis en código, sin comentarios redundantes
7. Archivos `< 500 líneas`

---

## 3. Backend Supabase

| Dato | Valor |
|---|---|
| Project ID | `uqhszqujcsmlmubeynfp` |
| Región | sa-east-1 |
| Postgres | 17.6 |
| URL | `https://uqhszqujcsmlmubeynfp.supabase.co` |
| Estado | ACTIVE_HEALTHY |

### Patrón ADR-0015 / ADR-0018 (CRÍTICO)
**Mutaciones SOLO vía RPCs `SECURITY DEFINER`**. Nunca hacer INSERT/UPDATE/DELETE directos desde el cliente para tablas de dominio. Las RPCs validan tenant, escriben `audit_log` atómico y respetan ledger inmutable.

### Tablas principales (27 con RLS activo)
- `tenants` — root multi-tenant
- `profiles` — staff B2B (id = auth.users.id). **NO tiene `birth_date`** (solo `customers`)
- `customers` — clientes B2C (lookup por `auth_user_id`). Tiene `birth_date`, `whatsapp`, `points`
- `reservations` — agenda (72 filas reales), exclusion constraint GIST anti-double-booking
- `ledger_entries` — INMUTABLE append-only (no `updated_at`)
- `services`, `branches`, `categories`, `business_hours`, `promotions`, `customer_coupons`
- `audit_log` — particionado mensual

### RPCs útiles que YA EXISTEN
- `complete_reservation_atomic`, `mark_no_show_atomic`
- `create_anonymous_booking` (walk-in barbero)
- `get_available_slots`, `get_dashboard_kpis`, `get_commissions_report`
- `get_daily_cash_close_report`
- `emit_customer_coupon`, `adjust_customer_points`, `validate_coupon_for_reservation`
- `upsert_promotion`, `archive_promotion`
- `update_tenant_settings`, `provision_tenant`

### RPCs PENDIENTES del socio (bloqueantes)
1. **`provision_customer_self(p_tenant_id, p_full_name, p_email, p_avatar_url)`** — bootstrap B2C nuevo. **Sin esto los clientes nuevos NO pueden crear su fila en `customers`** (RLS `customers_insert_staff` lo bloquea). Spec SQL ya entregado en conversación previa.
2. **`cancel_reservation_atomic`** — cancelación de cita por cliente B2C
3. **`customer_self_claim_loyalty_reward`** — reclamar premio 50% sin pasar por staff
4. **`create_client_reservation_atomic`** — para que el cliente cree sus propias reservas

### Datos seed clave en DB
- Adrián Barbero: `e51e7fc3-8421-4520-a8a6-867ac7b5d2e2` (role=barber)
- 6 staff totales, 8 customers, 72 reservations, 52 ledger entries, 6 services, 4 branches

### MCP Supabase
Disponible. Funciones más usadas:
- `mcp__356a0c5c-...__execute_sql` — para verificar schema, datos
- `mcp__356a0c5c-...__list_tables` — para auditar
- `mcp__356a0c5c-...__get_advisors` — security + performance lints

---

## 4. Estructura del Proyecto

```
lib/
├── app/view/                          App + LoadingApp (splash)
├── core/
│   ├── app_mode/                      AppModeBloc (modo cliente/barbero, auth state)
│   ├── config/app_config.dart         Credenciales via --dart-define
│   ├── di/                            injection.dart + supabase_module.dart
│   ├── notifications/                 Local notifications
│   ├── services/auth_service.dart     SupabaseAuth wrapper
│   ├── staff/                         StaffRepository (consume profiles real)
│   ├── storage/local_storage_provider.dart  Hive CE singleton
│   ├── theme/                         TenantThemeBloc + extension dorada
│   └── widgets/avatar_premium.dart    Avatar con fallback iniciales doradas
├── features/
│   ├── auth/                          LoginView con Google OAuth
│   ├── barber/
│   │   ├── view/                      BarberHomePage + BarberProfileView
│   │   └── agenda/                    Agenda Realtime (BarberAgendaView, AgendaBloc)
│   ├── gallery/                       Galería Pinterest con Hive CE
│   ├── home/                          HomePage (cliente, 5 tabs)
│   ├── products/                      Productos (100% MOCK)
│   ├── profile/                       ProfileBloc + ProfileSupabaseRepository
│   └── reservations/                  Flujo de reserva (100% MOCK)
└── main_{development,staging,production}.dart   Entry points por flavor
```

`packages/core/` — modelos compartidos: `UserProfile`, `Reservation`, `Service`, `BarberCenter`, `Professional`, `AppMode` enum.

---

## 5. Flavors / Cómo lanzar la app

```bash
flutter run -t lib/main_development.dart --dart-define-from-file=env/dev.json
flutter run -t lib/main_staging.dart     --dart-define-from-file=env/staging.json
flutter run -t lib/main_production.dart  --dart-define-from-file=env/prod.json
```

`env/*.json` está en `.gitignore`. Contiene `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `FLAVOR`.

---

## 6. Estado de cada Flujo

### ✅ Funciona bien
- **Splash + Boot** — premium 1.8s, retry on error, guards idempotentes
- **Login Google** — `prompt=select_account`, `SignOutScope.global`
- **Logout** — limpia state, ProfileBloc se sincroniza vía `AppModeBloc.stream`
- **Profile B2C** — SELECT/UPDATE/upsert a `customers`, foto Google con fallback iniciales
- **Profile B2B** — SELECT/UPDATE a `profiles`, sin `birth_date` (correcto)
- **Citas Cliente** — SELECT real a `reservations` con joins
- **Historial Cliente** — SELECT real a `ledger_entries` con join a `reservations`+`profiles`
- **Agenda Barbero** — Realtime channel + walk-in via `create_anonymous_booking`
- **Galería UI** — Pinterest masonry, filtros duales, panel admin 3 tabs (Portafolios/Staff/Categorías)
- **Staff lookup** — `StaffRepository` consume `profiles` real (Adrián Barbero auto-detect en dropdowns)
- **Avatar Premium** — fallback iniciales doradas universal

### 🔴 BUGS CRÍTICOS pendientes (no resueltos)
1. **Mock data en AgendaBloc** — si no hay citas reales, inyecta 3 fake (Carlos Ruiz, Miguel Soto, José Pérez). Archivo: `lib/features/barber/agenda/presentation/bloc/agenda_bloc.dart` líneas ~104-140. **Hay que eliminar el bloque.**
2. **ReservationBloc no escribe en Supabase** — `confirmReservation` solo simula con `Future.delayed`. El cliente NO crea reservas reales. Archivo: `lib/features/reservations/presentation/bloc/reservation_bloc.dart`.
3. **Galería con setState dentro de build via addPostFrameCallback** — anti-patrón con potencial loop infinito. Archivo: `lib/features/gallery/presentation/views/gallery_view.dart` líneas ~215-235.

### 🟠 Bugs menores
4. `ReservationSuccessView` re-crea HomePage en lugar de pop al root (pierde state de blocs).
5. Reset de fidelidad solo local — no toca `customers.points` en DB.
6. "Reservar con este corte" cambia tab pero no pre-selecciona barbero/servicio.

### 🟡 100% MOCK (bloqueado por backend)
- Módulo **Productos** completo (cart, favoritos, checkout, inventario)
- Módulo **Reservations** (selectores de centro/servicio/profesional/fecha)
- **Home content** (hero, about, stories, locations editables, social links)
- **Galería persistente cloud** — hoy es Hive CE local
- **Sistema de reviews/ratings** — no existe tabla
- **Push notifications reales** — solo locales con `flutter_local_notifications`

---

## 7. Convenciones del Proyecto

### DI
- Repos: `@LazySingleton(as: XRepository)` con constructor `(this._supabaseClient)`
- Blocs simples: `@injectable` con dependencias inyectadas
- Blocs con runtime params (ej. `AgendaBloc.barberId`): NO anotar, instanciar en la vista con `getIt<XRepository>()`
- `SupabaseClient` viene de `lib/core/di/supabase_module.dart` (`@module`)

### Freezed
```dart
@freezed
abstract class XState with _$XState {
  const XState._();
  const factory XState({...}) = _XState;
}

@freezed
abstract class XEvent with _$XEvent {
  const factory XEvent.started() = XStarted;
  const factory XEvent.something(String arg) = XSomething;
}
```

### Repositorios
- Interface en `lib/features/<feature>/domain/repositories/`
- Implementación en `lib/features/<feature>/data/repositories/`
- Mappers SQL row → modelo en `lib/features/<feature>/data/mappers/`

### Iconos
- FontAwesome 11.x — usar `FaIcon(FontAwesomeIcons.X)`, **NO** `Icon(FontAwesomeIcons.X)` (FaIconData ya no es subtipo de IconData)
- Material `Icons.X` con `Icon()`
- Para widgets reusables: aceptar `Widget icon` o `IconBuilder` typedef en vez de `IconData`

### Persistencia
- `SharedPreferences` para flags simples (`access_code`, `app_mode`)
- `Hive CE` para galería (sin code generation — usa `Box<Map>` + `toMap/fromMap`)
- ❌ NO usar `isar` — conflict con `source_gen` ^4 que requiere `json_serializable`

---

## 8. Workflows Operativos

### Cuando se agregan/modifican anotaciones DI o freezed
```bash
dart run build_runner build --delete-conflicting-outputs
```

### Antes de cualquier commit
```bash
dart analyze lib    # debe decir "No issues found!"
```

### Git
- Branch actual: `feature/barber-agenda-and-gallery`
- Mensajes estilo: `feat(scope): description` (en lowercase, imperativo)
- Co-author: `Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>`
- Nunca `--no-verify` salvo orden explícita
- Nunca push a `main` sin orden explícita
- Branch tracking: el usuario corre `git push -u origin <branch>` la primera vez

### Si build_runner tiene conflicto de versiones
- Verificar `json_serializable` vs `source_gen` compat
- NO bajar versiones de freezed/injectable_generator
- Hive_CE es seguro (no requiere generator)

---

## 9. Configuración crítica del Auth Service

```dart
signInWithGoogle:
  redirectTo: 'io.supabase.trimflow://login-callback'
  queryParams: {'prompt': 'select_account', 'access_type': 'offline'}

signOut:
  scope: SignOutScope.global   // invalida sesión en server
```

`AndroidManifest.xml` ya tiene el deep link configurado.

---

## 10. Patrones de Navegación

### Cambiar tab desde otra vista (cliente)
```dart
Navigator.of(context).popUntil((route) => route.isFirst);
HomePage.requestedTab.value = HomePage.reservationsTabIndex; // 2
```

`HomePage` tiene listener interno que escucha `requestedTab` y hace `tabController.animateTo`.

### Mostrar bottom sheet sobre la app
Usar `showModalBottomSheet` con `isScrollControlled: true` para sheets editables (forms).
Para sheets de cuarto pantalla: `SizedBox(height: MediaQuery.of(context).size.height * 0.28)`.

---

## 11. Auto-Memory del Usuario

Archivos persistentes en `C:\Users\LENOVO\.claude\projects\C--Users-LENOVO-OneDrive-Desktop-Proyect-trim-flow\memory\`:
- `project_trimflow.md` — ref del proyecto
- `project_db_pattern.md` — ADR-0015/0018

Si descubres algo nuevo importante (nueva regla del usuario, gotcha, módulo agregado, etc.), guardarlo en una memoria nueva siguiendo el formato existente.

---

## 12. Hoja de Ruta para llegar a Producción

### Sprint 1 — Bloqueadores críticos (2-3 días)
1. Eliminar mock data del `AgendaBloc`
2. Conectar `ReservationBloc` a `create_anonymous_booking` o esperar RPC nueva del socio
3. Fix del anti-patrón `setState` en `gallery_view.dart`
4. Fix `ReservationSuccessView` para no re-crear HomePage
5. Pull-to-refresh en Profile, Agenda, Home

### Sprint 2 — Backend del socio (bloqueado)
- RPCs: `provision_customer_self`, `cancel_reservation_atomic`, `customer_self_claim_loyalty_reward`, `create_client_reservation_atomic`
- Tablas: `products`, `gallery_items`, `reviews`

### Sprint 3 — Cablear lo que entregue el socio
- 1 línea en `ProfileSupabaseRepository` para `provision_customer_self`
- Conectar `ReservationBloc` real
- Reemplazar `ProductMockDatasource` por `ProductSupabaseRepository`
- Intercambiar `GalleryHiveRepository` por `GallerySupabaseRepository`

### Sprint 4 — Push notifications + métricas
- Firebase Messaging + FCM token sync a `customer_notification_preferences`
- Dashboard barbero con `get_dashboard_kpis(filter_to_caller_barber=true)`
- Reporte comisiones con `get_commissions_report`

### Sprint 5 — Polish + Lanzamiento
- Sentry/Crashlytics
- Loading skeletons
- Haptic feedback
- App Store + Play Store assets
- Privacy policy + términos

---

## 13. Cosas que NO hacer

- ❌ NO tocar SQL/migraciones del socio. Solo lectura via MCP.
- ❌ NO agregar comentarios redundantes en código (el usuario los odia)
- ❌ NO usar emojis en código (solo en mensajes Markdown al usuario)
- ❌ NO hacer commit/push sin orden explícita del usuario
- ❌ NO crear archivos `.md` de docs/planning sin pedírselo
- ❌ NO usar `dependency_overrides` para forzar versiones (rompe generators)
- ❌ NO escribir UPDATE/INSERT directos a tablas de dominio desde Flutter (viola ADR-0015)
- ❌ NO tocar `injection.config.dart` ni archivos `.freezed.dart` (regenerados)
- ❌ NO usar `setState` dentro de `build()` ni dentro de `addPostFrameCallback` desde build

---

## 14. Cosas que SIEMPRE hacer

- ✅ Correr `dart analyze lib` antes de declarar tarea completa
- ✅ Usar `AvatarPremium` en TODOS los avatares (no `CachedNetworkImage` directo)
- ✅ Validar que repos son `@LazySingleton(as: ...)` y blocs `@injectable`
- ✅ Para state/event nuevos, usar `@freezed`
- ✅ Pasar el `BlocProvider.value(value: bloc)` en navegaciones Push
- ✅ Si modificas anotaciones DI/freezed, correr `build_runner`
- ✅ Aceptar `Widget icon` o `IconBuilder` typedef en widgets custom en vez de `IconData` (compat FaIcon)

---

## 15. Cuenta Real de Pruebas

- **Adrián Barbero** (institucional Google) — barber en DB con id `e51e7fc3-...`, branch `e7280f80-...`, specialty "Experto en Platinados y Fades Premium"
- Cliente B2C: cualquier cuenta Gmail normal funciona — pero al ser nueva sin fila en `customers`, falla por RLS (bloqueado por `provision_customer_self` pendiente)

---

## 16. Decisiones técnicas tomadas (no revisar)

- **Hive CE** en lugar de Isar — conflict de `source_gen` versions
- **kalender NO** — vista matriz custom con `CustomPainter` (sin licencia, sin watermark)
- **`prompt=select_account`** para forzar elección de cuenta Google
- **`HomePage.requestedTab` ValueNotifier estático** — patrón pragmático para navegación cross-feature sin un NavigationCoordinator
- **ProfileBloc escucha `AppModeBloc.stream`** (no auth directo) — garantiza orden, evita race condition
- **`_lastKnownUserId`** en AppModeBloc reemplaza al flag `_isLoggingOut` — inmune a eventos rezagados
