import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart';

final getIt = GetIt.instance;

@InjectableInit()
void configureDependencies() {
  // Registering core services
  getIt.registerLazySingleton<TenantThemeBloc>(() => TenantThemeBloc());
  
  // In the future, injectable_generator will handle this automatically
  // once we add @injectable to our classes and run the build.
}
