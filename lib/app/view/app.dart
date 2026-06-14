import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_state.dart';
import 'package:trim_flow/features/profile/presentation/views/complete_profile_view.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_bloc.dart';
import 'package:trim_flow/features/catalog/presentation/bloc/catalog_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/core/theme/tenant_theme_extension.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';
import 'package:trim_flow/core/app_mode/bootstrap_mode.dart';
import 'package:trim_flow/features/barber/view/barber_home_page.dart' deferred as barber;
import 'package:trim_flow/features/auth/presentation/views/access_code_view.dart';
import 'package:trim_flow/features/auth/presentation/views/claim_profile_view.dart';
import 'package:trim_flow/features/auth/presentation/views/login_view.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/orders_event.dart';
import 'package:core/core.dart';

import 'package:trim_flow/features/products/presentation/bloc/product_bloc.dart';
import 'package:trim_flow/features/products/data/repositories/product_repository_impl.dart';
import 'package:trim_flow/features/products/domain/usecases/product_usecases.dart';

class DeferredWidget extends StatefulWidget {
  const DeferredWidget({super.key, required this.loader, required this.builder});
  final Future<void> Function() loader;
  final Widget Function() builder;

  @override
  State<DeferredWidget> createState() => _DeferredWidgetState();
}

class _DeferredWidgetState extends State<DeferredWidget> {
  Future<void>? _future;

  @override
  void initState() {
    super.initState();
    _future = widget.loader();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return widget.builder();
        }
        return const Scaffold(
          backgroundColor: Colors.black,
          body: Center(child: CircularProgressIndicator(color: Color(0xFFB8BCBF), strokeWidth: 2)),
        );
      },
    );
  }
}

/// Loader neutro mostrado entre login y resolución del tenant.
/// NO usa colores del tema (sería el flash dorado que el usuario reportó).
/// Branding negro/blanco universal — coherente con el splash de LoadingApp.
class _PostLoginTransition extends StatelessWidget {
  const _PostLoginTransition({this.label});

  /// Nombre del negocio a mostrar (al cambiar de barberia). Si es null muestra
  /// "TRIMFLOW" (login inicial).
  final String? label;

  @override
  Widget build(BuildContext context) {
    // Login inicial: pantalla neutra TRIMFLOW (sin color de tenant aun).
    if (label == null) {
      return const Scaffold(
        backgroundColor: Color(0xFF070707),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'TRIMFLOW',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 6,
                  fontFamily: 'Inter',
                ),
              ),
              SizedBox(height: 28),
              SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  color: Colors.white54,
                  strokeWidth: 1.8,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Cambio de negocio: loader premium con color e inicial del tenant. El
    // recuadro es un mockup del logo (hasta que exista el logo real).
    final accent = context.primaryGold;
    final name = label!;
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return Scaffold(
      backgroundColor: const Color(0xFF080808),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: accent.withValues(alpha: 0.45),
                  width: 1.5,
                ),
              ),
              alignment: Alignment.center,
              child: Text(
                initial,
                style: TextStyle(
                  color: accent,
                  fontSize: 42,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -1,
                  fontFamily: 'Inter',
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scaleXY(
                  begin: 0.94,
                  end: 1.06,
                  duration: 900.ms,
                  curve: Curves.easeInOut,
                ),
            const SizedBox(height: 26),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Text(
                name,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                  letterSpacing: -0.4,
                  fontFamily: 'Inter',
                ),
              ),
            ).animate().fadeIn(duration: 350.ms),
            const SizedBox(height: 24),
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: accent),
            ),
          ],
        ),
      ),
    );
  }
}

/// Gate del cliente: si el perfil esta incompleto (cuenta nueva) obliga a
/// completar datos antes de entrar a la app. Si esta completo, muestra Home.
class _ClientGate extends StatelessWidget {
  const _ClientGate();

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<TenantThemeBloc>().state;
    // Cold start: cliente logueado sin barberias vinculadas → pegar codigo.
    if (themeState.isResolved && themeState.availableTenants.isEmpty) {
      return const ClaimProfileView();
    }
    return BlocBuilder<ProfileBloc, ProfileState>(
      builder: (context, state) {
        final user = state.user;
        if (user == null) {
          if (state.status == ProfileStatus.error) return const HomePage();
          String? switchingName;
          if (themeState.isSwitching) {
            for (final t in themeState.availableTenants) {
              if (t.id == themeState.tenantId) {
                switchingName = t.name;
                break;
              }
            }
          }
          return _PostLoginTransition(label: switchingName);
        }
        final complete =
            user.birthDate.trim().isNotEmpty && user.phone.trim().isNotEmpty;
        if (!complete) return CompleteProfileView(user: user);
        return const HomePage();
      },
    );
  }
}

class App extends StatefulWidget {
  const App({super.key, this.bootstrapMode = BootstrapMode.client});

  final BootstrapMode bootstrapMode;

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  void initState() {
    super.initState();
    if (widget.bootstrapMode.isBusiness) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        getIt<AppModeBloc>().add(const AppModeEvent.setAccessCode('2'));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<TenantThemeBloc>()),
        BlocProvider(create: (_) => getIt<AppModeBloc>()),
        BlocProvider(create: (_) => getIt<ProfileBloc>()..add(const LoadProfileEvent())),
        BlocProvider(create: (_) => getIt<HomeBloc>()..add(const HomeEvent.load())),
        BlocProvider(create: (_) => CartBloc()..add(const CartEvent.started())),
        BlocProvider(create: (_) => OrdersBloc()..add(const OrdersEvent.started())),
        BlocProvider(create: (_) => getIt<ReservationBloc>()),
        BlocProvider(create: (_) => getIt<CatalogBloc>()),
        BlocProvider(
          create: (_) {
            final repo = ProductRepositoryImpl();
            return ProductBloc(
              getProducts: GetProductsUseCase(repo),
              getCategories: GetCategoriesUseCase(repo),
              searchProducts: SearchProductsUseCase(repo),
              filterByCategory: FilterByCategoryUseCase(repo),
              saveProduct: SaveProductUseCase(repo),
              deleteProduct: DeleteProductUseCase(repo),
            );
          },
        ),
      ],
      child: BlocBuilder<TenantThemeBloc, TenantThemeState>(
        builder: (context, themeState) {
          final forcedMode = widget.bootstrapMode.asAppMode;
          final appTitle = widget.bootstrapMode.isBusiness ? 'TrimFlow Business' : 'TrimFlow';
          return MultiBlocListener(
            listeners: [
              BlocListener<AppModeBloc, AppModeState>(
                listenWhen: (previous, current) => previous.isLoggedIn != current.isLoggedIn && !current.isLoggedIn,
                listener: (context, state) {
                  _navigatorKey.currentState?.popUntil((route) => route.isFirst);
                },
              ),
              BlocListener<AppModeBloc, AppModeState>(
                listenWhen: (previous, current) =>
                    current.isLoggedIn && current.isInitialized && current.mode != forcedMode,
                listener: (context, state) {
                  context.read<AppModeBloc>().add(AppModeEvent.changeMode(forcedMode));
                },
              ),
              BlocListener<TenantThemeBloc, TenantThemeState>(
                listenWhen: (previous, current) =>
                    previous.tenantId != current.tenantId &&
                    previous.isResolved &&
                    current.isResolved,
                listener: (context, state) {
                  context.read<ProfileBloc>().add(const ProfileEvent.load());
                  context.read<HomeBloc>().add(const HomeEvent.load());
                },
              ),
            ],
            child: MaterialApp(
              navigatorKey: _navigatorKey,
              title: appTitle,
              theme: themeState.themeData,
              debugShowCheckedModeBanner: false,
              localizationsDelegates: const [
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: const [
                Locale('es', 'ES'),
                Locale('en', 'US'),
              ],
              locale: const Locale('es', 'ES'),
              home: BlocBuilder<AppModeBloc, AppModeState>(
                builder: (context, state) {
                  if (!state.isInitialized) {
                    return const Scaffold(
                      backgroundColor: Color(0xFF070707),
                      body: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFFB8BCBF),
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  }

                  if (state.accessCode == null) {
                    if (widget.bootstrapMode.isBusiness) {
                      return const _PostLoginTransition();
                    }
                    return AccessCodeView(
                      onCodeValidated: (code) => context.read<AppModeBloc>().add(AppModeEvent.setAccessCode(code)),
                    );
                  }

                  if (!state.isLoggedIn) {
                    return LoginView(
                      onLoginSuccess: () => context.read<AppModeBloc>().add(const AppModeEvent.login()),
                    );
                  }

                  // Espera a que el tema del tenant esté resuelto antes de mostrar
                  // el contenido principal. Loader neutro (negro + blanco) para
                  // evitar cualquier flash de colores del tema viejo.
                  if (themeState.isResolving || !themeState.isResolved) {
                    return const _PostLoginTransition();
                  }

                  final destination = forcedMode == AppMode.client
                      ? const _ClientGate()
                      : DeferredWidget(
                          loader: barber.loadLibrary,
                          builder: () => barber.BarberHomePage(),
                        );

                  return AnimatedSwitcher(
                    duration: const Duration(milliseconds: 350),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    child: KeyedSubtree(
                      key: ValueKey('home_${forcedMode.name}_${themeState.tenantId}'),
                      child: destination,
                    ),
                  );
                },
              ),
            ),
          );
        },
      ),
    );
  }
}
