# TrimFlow

A minimalist and professional mobile application for hair salons and barbershops.

## 🛡️ Protocolo de Desarrollo (Reglas de Oro)

*Estas reglas deben leerse y cumplirse estrictamente antes de cada tarea:*

1. **Arquitectura**: Uso obligatorio de **Clean Architecture + BLoC + Repository Pattern**.
2. **Generación de Código**: Uso obligatorio de **Freezed** para estados y eventos, y **get_it** para inyección de dependencias.
3. **Calidad de Código**: Tras cada tarea, es OBLIGATORIO ejecutar `flutter analyze`. Solo se acepta un resultado de **"No issues found!"**.
4. **UI/UX**: Estilo **minimalista y premium**. Paleta de colores: **Negro (#000000), Blanco (#FFFFFF) y Dorado (#D4AF37)** *(default fallback para Barbería Dream Flow; otros tenants usan su `branding` JSONB)*.

---

## 🚀 Cómo Ejecutar la App

TrimFlow se distribuye como **dos apps Android independientes** que comparten el mismo backend Supabase:

| App | Para quién | Package ID | Flavor |
|---|---|---|---|
| **TrimFlow** | Clientes finales (B2C) | `com.trimflow.app` | `client` |
| **TrimFlow Business** | Barberos y administradores (B2B) | `com.trimflow.business` | `business` |

> **⚠️ IMPORTANTE:** Cada comando instala UNA sola app. Para tener ambas en tu celular debes correr ambos comandos. Las dos apps coexisten — distinto ícono, distintos datos locales, mismo Supabase.

### 📱 TrimFlow (Cliente - B2C)

```bash
# Desarrollo
flutter run --flavor client -t lib/main_development.dart --dart-define-from-file=env/dev.json

# Staging
flutter run --flavor client -t lib/main_staging.dart --dart-define-from-file=env/staging.json

# Producción
flutter run --flavor client -t lib/main_production.dart --dart-define-from-file=env/prod.json --release
```

**Qué verás:** HomePage con 5 tabs (Home, Productos, Citas, Galería, Profile). Modo barbero deshabilitado.

### 💼 TrimFlow Business (Barbero - B2B)

```bash
# Desarrollo
flutter run --flavor business -t lib/main_business_development.dart --dart-define-from-file=env/dev.json

# Staging
flutter run --flavor business -t lib/main_business_staging.dart --dart-define-from-file=env/staging.json

# Producción
flutter run --flavor business -t lib/main_business_production.dart --dart-define-from-file=env/prod.json --release
```

**Qué verás:** Acceso directo a Agenda del barbero, Walk-in, Panel admin, Galería editable. Modo cliente deshabilitado.

### 🔄 Workflow recomendado para probar ambas

```bash
# 1. Instala la cliente
flutter run --flavor client -t lib/main_development.dart --dart-define-from-file=env/dev.json
# Espera a que abra → presiona "q" para detener

# 2. Instala la business (sin desconectar el celular)
flutter run --flavor business -t lib/main_business_development.dart --dart-define-from-file=env/dev.json
# Espera a que abra → ahora tienes las 2 apps instaladas en paralelo

# 3. Verifica que las 2 estén instaladas
adb shell pm list packages | findstr trimflow
# Debería salir: com.trimflow.app y com.trimflow.business
```

### 🧹 Si algo falla al cambiar de flavor

```bash
flutter clean
flutter pub get
# Luego repite el comando del flavor que necesites
```

---

## 🎯 Cómo identificar en qué app estoy

### Diferencias visuales

| Señal | App Cliente | App Business |
|---|---|---|
| **Ícono y nombre en celular** | "TrimFlow" | "TrimFlow Business" |
| **Pantalla inicial post-login** | HomePage con bottom navbar de 5 tabs | BarberHomePage con agenda en vivo |
| **Tabs disponibles** | Home / Productos / Citas / Galería / Profile | Agenda / Walk-in / Galería admin / Dashboard / Profile |
| **Badge en headers** | Sin badge especial | Badge dorado **"MODO BARBERO"** en cabeceras |
| **Tema de color** | Sigue `tenants.branding` del cliente logueado | Sigue `tenants.branding` del barbero logueado |
| **Botón de cambio de modo** | ❌ No existe | ❌ No existe |

### Verificación rápida en código

Cualquier widget puede saber en qué app está leyendo `widget.bootstrapMode` o el `BlocProvider<AppModeBloc>().state.mode`:
- `AppMode.client` → app cliente
- `AppMode.barber` → app business

---

## 🏗️ Stack Técnico

- **Flutter** 3.11+ con Dart SDK ^3.11.4
- **Supabase** (Postgres 17.6, región sa-east-1)
- **BLoC** + **Clean Architecture** + **Repository Pattern**
- **Freezed** para estados/eventos
- **get_it** + **Injectable** para inyección de dependencias
- **Hive CE** para persistencia local (galería)
- **FontAwesome v11** (usar `FaIcon`, no `Icon(FontAwesomeIcons.X)`)

---

## 📂 Estructura

```
lib/
├── app/view/                    App + LoadingApp (splash)
├── core/
│   ├── app_mode/                AppModeBloc + BootstrapMode
│   ├── config/                  AppConfig (credenciales --dart-define)
│   ├── di/                      injection.dart + supabase_module.dart
│   ├── theme/                   TenantThemeBloc + TenantBrandingColors
│   └── widgets/                 AvatarPremium y compartidos
├── features/
│   ├── auth/                    Login Google
│   ├── barber/                  Agenda Realtime + walk-in (solo TrimFlow Business)
│   ├── gallery/                 Galería Pinterest (compartida)
│   ├── home/                    HomePage cliente 5 tabs (solo TrimFlow)
│   ├── products/                Productos B2C (solo TrimFlow)
│   ├── profile/                 Perfil de usuario (compartido)
│   └── reservations/            Flujo de reserva B2C (solo TrimFlow)
├── main_development.dart            ← Entry TrimFlow cliente dev
├── main_staging.dart                ← Entry TrimFlow cliente staging
├── main_production.dart             ← Entry TrimFlow cliente prod
├── main_business_development.dart   ← Entry TrimFlow Business dev
├── main_business_staging.dart       ← Entry TrimFlow Business staging
└── main_business_production.dart    ← Entry TrimFlow Business prod
```

---

## 🔧 Setup Inicial

1. Clonar el repo
2. Copiar credenciales: pedirle a Adrián los archivos `env/dev.json`, `env/staging.json`, `env/prod.json` (no están en git por seguridad)
3. `flutter pub get`
4. Si modificaste anotaciones DI o Freezed: `dart run build_runner build --delete-conflicting-outputs`
5. `dart analyze lib` → debe decir **"No issues found!"**
6. Ejecutar uno de los comandos de arriba

---

## 📞 Backend

- **Proyecto Supabase:** `uqhszqujcsmlmubeynfp` (sa-east-1)
- **Patrón:** ADR-0015/0018 — todas las mutaciones via RPCs `SECURITY DEFINER`
- **NO** hacer `INSERT/UPDATE/DELETE` directos desde Flutter a tablas de dominio
