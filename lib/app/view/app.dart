import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';
import 'package:trim_flow/core/app_mode/bootstrap_mode.dart';
import 'package:trim_flow/features/barber/view/barber_home_page.dart' deferred as barber;
import 'package:trim_flow/features/auth/presentation/views/access_code_view.dart';
import 'package:trim_flow/features/auth/presentation/views/login_view.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_bloc.dart';
import 'package:trim_flow/features/products/presentation/bloc/cart_event.dart';
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
  const _PostLoginTransition();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF070707),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
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
        BlocProvider(create: (_) => ReservationBloc()),
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
                      ? const HomePage()
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
