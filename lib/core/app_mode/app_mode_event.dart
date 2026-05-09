import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:core/core.dart';

part 'app_mode_event.freezed.dart';

@freezed
abstract class AppModeEvent with _$AppModeEvent {
  const factory AppModeEvent.initialize() = Initialize;
  const factory AppModeEvent.changeMode(AppMode mode) = ChangeMode;
  const factory AppModeEvent.setAccessCode(String code) = SetAccessCode;
  const factory AppModeEvent.loginWithGoogle() = LoginWithGoogle;
  const factory AppModeEvent.login() = Login;
  const factory AppModeEvent.requestLogout() = RequestLogout;
  const factory AppModeEvent.logout() = Logout;
  const factory AppModeEvent.reset() = Reset;
}
