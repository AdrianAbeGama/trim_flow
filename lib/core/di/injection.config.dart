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
import 'package:supabase_flutter/supabase_flutter.dart' as _i454;
import 'package:trim_flow/core/app_mode/app_mode_bloc.dart' as _i480;
import 'package:trim_flow/core/di/supabase_module.dart' as _i384;
import 'package:trim_flow/core/services/auth_service.dart' as _i882;
import 'package:trim_flow/core/staff/data/repositories/staff_supabase_repository.dart'
    as _i952;
import 'package:trim_flow/core/staff/domain/repositories/staff_repository.dart'
    as _i698;
import 'package:trim_flow/core/theme/tenant_theme_bloc.dart' as _i272;
import 'package:trim_flow/features/barber/agenda/data/repositories/agenda_supabase_repository.dart'
    as _i781;
import 'package:trim_flow/features/barber/agenda/domain/repositories/agenda_repository.dart'
    as _i434;
import 'package:trim_flow/features/catalog/data/repositories/catalog_supabase_repository.dart'
    as _i681;
import 'package:trim_flow/features/catalog/domain/repositories/catalog_repository.dart'
    as _i812;
import 'package:trim_flow/features/catalog/presentation/bloc/catalog_bloc.dart'
    as _i206;
import 'package:trim_flow/features/gallery/data/repositories/gallery_hive_repository.dart'
    as _i599;
import 'package:trim_flow/features/gallery/domain/repositories/gallery_repository.dart'
    as _i585;
import 'package:trim_flow/features/gallery/presentation/bloc/gallery_bloc.dart'
    as _i499;
import 'package:trim_flow/features/home/data/repositories/home_repository_impl.dart'
    as _i979;
import 'package:trim_flow/features/home/domain/repositories/home_repository.dart'
    as _i662;
import 'package:trim_flow/features/home/presentation/bloc/home_bloc.dart'
    as _i19;
import 'package:trim_flow/features/profile/data/repositories/profile_supabase_repository.dart'
    as _i915;
import 'package:trim_flow/features/profile/domain/repositories/profile_repository.dart'
    as _i956;
import 'package:trim_flow/features/profile/presentation/bloc/profile_bloc.dart'
    as _i447;
import 'package:trim_flow/features/reservations/data/repositories/reservation_supabase_repository.dart'
    as _i156;
import 'package:trim_flow/features/reservations/domain/repositories/reservation_repository.dart'
    as _i224;
import 'package:trim_flow/features/reservations/presentation/bloc/reservation_bloc.dart'
    as _i316;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final supabaseModule = _$SupabaseModule();
    gh.lazySingleton<_i454.SupabaseClient>(() => supabaseModule.supabaseClient);
    gh.lazySingleton<_i882.AuthService>(() => _i882.AuthService());
    gh.lazySingleton<_i272.TenantThemeBloc>(() => _i272.TenantThemeBloc());
    gh.lazySingleton<_i585.GalleryRepository>(
      () => _i599.GalleryHiveRepository(),
    );
    gh.lazySingleton<_i662.HomeRepository>(() => _i979.HomeRepositoryImpl());
    gh.lazySingleton<_i480.AppModeBloc>(
      () => _i480.AppModeBloc(gh<_i882.AuthService>()),
    );
    gh.factory<_i499.GalleryBloc>(
      () => _i499.GalleryBloc(gh<_i585.GalleryRepository>()),
    );
    gh.lazySingleton<_i434.AgendaRepository>(
      () => _i781.AgendaSupabaseRepository(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i812.CatalogRepository>(
      () => _i681.CatalogSupabaseRepository(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i698.StaffRepository>(
      () => _i952.StaffSupabaseRepository(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i224.ReservationRepository>(
      () => _i156.ReservationSupabaseRepository(gh<_i454.SupabaseClient>()),
    );
    gh.lazySingleton<_i956.ProfileRepository>(
      () => _i915.ProfileSupabaseRepository(gh<_i454.SupabaseClient>()),
    );
    gh.factory<_i19.HomeBloc>(
      () => _i19.HomeBloc(
        gh<_i662.HomeRepository>(),
        gh<_i812.CatalogRepository>(),
        gh<_i272.TenantThemeBloc>(),
      ),
    );
    gh.factory<_i447.ProfileBloc>(
      () => _i447.ProfileBloc(
        gh<_i882.AuthService>(),
        gh<_i956.ProfileRepository>(),
        gh<_i480.AppModeBloc>(),
        gh<_i272.TenantThemeBloc>(),
      ),
    );
    gh.factory<_i316.ReservationBloc>(
      () => _i316.ReservationBloc(gh<_i224.ReservationRepository>()),
    );
    gh.factory<_i206.CatalogBloc>(
      () => _i206.CatalogBloc(
        gh<_i812.CatalogRepository>(),
        gh<_i272.TenantThemeBloc>(),
      ),
    );
    return this;
  }
}

class _$SupabaseModule extends _i384.SupabaseModule {}
