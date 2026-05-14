// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart' as _i480;
import 'package:trim_flow/core/services/auth_service.dart' as _i882;
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart' as _i272;
import 'package:trim_flow/features/home/data/repositories/home_repository_impl.dart'
    as _i979;
import 'package:trim_flow/features/home/domain/repositories/home_repository.dart'
    as _i662;
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart'
    as _i19;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    gh.lazySingleton<_i882.AuthService>(() => _i882.AuthService());
    gh.lazySingleton<_i272.TenantThemeBloc>(() => _i272.TenantThemeBloc());
    gh.lazySingleton<_i662.HomeRepository>(() => _i979.HomeRepositoryImpl());
    gh.lazySingleton<_i480.AppModeBloc>(
      () => _i480.AppModeBloc(gh<_i882.AuthService>()),
    );
    gh.factory<_i19.HomeBloc>(() => _i19.HomeBloc(gh<_i662.HomeRepository>()));
    return this;
  }
}
