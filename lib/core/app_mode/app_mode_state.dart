import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';

part 'app_mode_state.freezed.dart';

@freezed
abstract class AppModeState with _$AppModeState {
  const factory AppModeState({
    AppMode? mode,
    String? accessCode,
    @Default(false) bool isLoggedIn,
    @Default(false) bool isInitialized,
    @Default(false) bool isPasswordRecovery,
  }) = _AppModeState;
}
