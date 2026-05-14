import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:trim_flow/features/profile/presentation/bloc/profile_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:trim_flow/core/di/injection.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';
import 'package:trim_flow/features/home/view/home_page.dart';

import 'package:trim_flow/core/app_mode/app_mode_bloc.dart';
import 'package:trim_flow/core/app_mode/app_mode_state.dart';
import 'package:trim_flow/features/module_selection/view/module_selection_view.dart';
import 'package:trim_flow/features/barber/view/barber_home_page.dart' deferred as barber;
import 'package:trim_flow/features/auth/presentation/views/access_code_view.dart';
import 'package:trim_flow/features/auth/presentation/views/login_view.dart';
import 'package:trim_flow/core/app_mode/app_mode_event.dart';
import 'package:core/core.dart';

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
          body: Center(child: CircularProgressIndicator(color: Color(0xFFD4AF37))),
        );
      },
    );
  }
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => getIt<TenantThemeBloc>()..loadTenant('barberia_alpha')),
        BlocProvider(create: (_) => getIt<AppModeBloc>()..add(const AppModeEvent.initialize())),
        BlocProvider(create: (_) => ProfileBloc()..add(const LoadProfileEvent())),
        BlocProvider(create: (_) => getIt<HomeBloc>()..add(const HomeEvent.load())),
      ],
      child: BlocBuilder<TenantThemeBloc, TenantThemeState>(
        builder: (context, themeState) {
          return MaterialApp(
            title: 'TrimFlow',
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
                if (state.accessCode == null) {
                  return AccessCodeView(
                    onCodeValidated: (code) => context.read<AppModeBloc>().add(AppModeEvent.setAccessCode(code)),
                  );
                }

                if (!state.isLoggedIn) {
                  return LoginView(
                    onLoginSuccess: () => context.read<AppModeBloc>().add(const AppModeEvent.login()),
                  );
                }

                if (state.mode == null) {
                  return const ModuleSelectionView();
                }

                if (state.mode == AppMode.client) {
                  return const HomePage();
                }

                return DeferredWidget(
                  loader: barber.loadLibrary,
                  builder: () => barber.BarberHomePage(),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
