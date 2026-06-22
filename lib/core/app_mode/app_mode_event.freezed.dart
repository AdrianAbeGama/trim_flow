// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'app_mode_event.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$AppModeEvent {





@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppModeEvent);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppModeEvent()';
}


}

/// @nodoc
class $AppModeEventCopyWith<$Res>  {
$AppModeEventCopyWith(AppModeEvent _, $Res Function(AppModeEvent) __);
}


/// Adds pattern-matching-related methods to [AppModeEvent].
extension AppModeEventPatterns on AppModeEvent {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>({TResult Function( Initialize value)?  initialize,TResult Function( ChangeMode value)?  changeMode,TResult Function( SetAccessCode value)?  setAccessCode,TResult Function( LoginWithGoogle value)?  loginWithGoogle,TResult Function( Login value)?  login,TResult Function( PasswordRecoveryStarted value)?  passwordRecoveryStarted,TResult Function( PasswordRecoveryFinished value)?  passwordRecoveryFinished,TResult Function( RequestLogout value)?  requestLogout,TResult Function( Logout value)?  logout,TResult Function( Reset value)?  reset,required TResult orElse(),}){
final _that = this;
switch (_that) {
case Initialize() when initialize != null:
return initialize(_that);case ChangeMode() when changeMode != null:
return changeMode(_that);case SetAccessCode() when setAccessCode != null:
return setAccessCode(_that);case LoginWithGoogle() when loginWithGoogle != null:
return loginWithGoogle(_that);case Login() when login != null:
return login(_that);case PasswordRecoveryStarted() when passwordRecoveryStarted != null:
return passwordRecoveryStarted(_that);case PasswordRecoveryFinished() when passwordRecoveryFinished != null:
return passwordRecoveryFinished(_that);case RequestLogout() when requestLogout != null:
return requestLogout(_that);case Logout() when logout != null:
return logout(_that);case Reset() when reset != null:
return reset(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>({required TResult Function( Initialize value)  initialize,required TResult Function( ChangeMode value)  changeMode,required TResult Function( SetAccessCode value)  setAccessCode,required TResult Function( LoginWithGoogle value)  loginWithGoogle,required TResult Function( Login value)  login,required TResult Function( PasswordRecoveryStarted value)  passwordRecoveryStarted,required TResult Function( PasswordRecoveryFinished value)  passwordRecoveryFinished,required TResult Function( RequestLogout value)  requestLogout,required TResult Function( Logout value)  logout,required TResult Function( Reset value)  reset,}){
final _that = this;
switch (_that) {
case Initialize():
return initialize(_that);case ChangeMode():
return changeMode(_that);case SetAccessCode():
return setAccessCode(_that);case LoginWithGoogle():
return loginWithGoogle(_that);case Login():
return login(_that);case PasswordRecoveryStarted():
return passwordRecoveryStarted(_that);case PasswordRecoveryFinished():
return passwordRecoveryFinished(_that);case RequestLogout():
return requestLogout(_that);case Logout():
return logout(_that);case Reset():
return reset(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>({TResult? Function( Initialize value)?  initialize,TResult? Function( ChangeMode value)?  changeMode,TResult? Function( SetAccessCode value)?  setAccessCode,TResult? Function( LoginWithGoogle value)?  loginWithGoogle,TResult? Function( Login value)?  login,TResult? Function( PasswordRecoveryStarted value)?  passwordRecoveryStarted,TResult? Function( PasswordRecoveryFinished value)?  passwordRecoveryFinished,TResult? Function( RequestLogout value)?  requestLogout,TResult? Function( Logout value)?  logout,TResult? Function( Reset value)?  reset,}){
final _that = this;
switch (_that) {
case Initialize() when initialize != null:
return initialize(_that);case ChangeMode() when changeMode != null:
return changeMode(_that);case SetAccessCode() when setAccessCode != null:
return setAccessCode(_that);case LoginWithGoogle() when loginWithGoogle != null:
return loginWithGoogle(_that);case Login() when login != null:
return login(_that);case PasswordRecoveryStarted() when passwordRecoveryStarted != null:
return passwordRecoveryStarted(_that);case PasswordRecoveryFinished() when passwordRecoveryFinished != null:
return passwordRecoveryFinished(_that);case RequestLogout() when requestLogout != null:
return requestLogout(_that);case Logout() when logout != null:
return logout(_that);case Reset() when reset != null:
return reset(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>({TResult Function()?  initialize,TResult Function( AppMode mode)?  changeMode,TResult Function( String code)?  setAccessCode,TResult Function()?  loginWithGoogle,TResult Function()?  login,TResult Function()?  passwordRecoveryStarted,TResult Function()?  passwordRecoveryFinished,TResult Function()?  requestLogout,TResult Function()?  logout,TResult Function()?  reset,required TResult orElse(),}) {final _that = this;
switch (_that) {
case Initialize() when initialize != null:
return initialize();case ChangeMode() when changeMode != null:
return changeMode(_that.mode);case SetAccessCode() when setAccessCode != null:
return setAccessCode(_that.code);case LoginWithGoogle() when loginWithGoogle != null:
return loginWithGoogle();case Login() when login != null:
return login();case PasswordRecoveryStarted() when passwordRecoveryStarted != null:
return passwordRecoveryStarted();case PasswordRecoveryFinished() when passwordRecoveryFinished != null:
return passwordRecoveryFinished();case RequestLogout() when requestLogout != null:
return requestLogout();case Logout() when logout != null:
return logout();case Reset() when reset != null:
return reset();case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>({required TResult Function()  initialize,required TResult Function( AppMode mode)  changeMode,required TResult Function( String code)  setAccessCode,required TResult Function()  loginWithGoogle,required TResult Function()  login,required TResult Function()  passwordRecoveryStarted,required TResult Function()  passwordRecoveryFinished,required TResult Function()  requestLogout,required TResult Function()  logout,required TResult Function()  reset,}) {final _that = this;
switch (_that) {
case Initialize():
return initialize();case ChangeMode():
return changeMode(_that.mode);case SetAccessCode():
return setAccessCode(_that.code);case LoginWithGoogle():
return loginWithGoogle();case Login():
return login();case PasswordRecoveryStarted():
return passwordRecoveryStarted();case PasswordRecoveryFinished():
return passwordRecoveryFinished();case RequestLogout():
return requestLogout();case Logout():
return logout();case Reset():
return reset();case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>({TResult? Function()?  initialize,TResult? Function( AppMode mode)?  changeMode,TResult? Function( String code)?  setAccessCode,TResult? Function()?  loginWithGoogle,TResult? Function()?  login,TResult? Function()?  passwordRecoveryStarted,TResult? Function()?  passwordRecoveryFinished,TResult? Function()?  requestLogout,TResult? Function()?  logout,TResult? Function()?  reset,}) {final _that = this;
switch (_that) {
case Initialize() when initialize != null:
return initialize();case ChangeMode() when changeMode != null:
return changeMode(_that.mode);case SetAccessCode() when setAccessCode != null:
return setAccessCode(_that.code);case LoginWithGoogle() when loginWithGoogle != null:
return loginWithGoogle();case Login() when login != null:
return login();case PasswordRecoveryStarted() when passwordRecoveryStarted != null:
return passwordRecoveryStarted();case PasswordRecoveryFinished() when passwordRecoveryFinished != null:
return passwordRecoveryFinished();case RequestLogout() when requestLogout != null:
return requestLogout();case Logout() when logout != null:
return logout();case Reset() when reset != null:
return reset();case _:
  return null;

}
}

}

/// @nodoc


class Initialize implements AppModeEvent {
  const Initialize();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Initialize);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppModeEvent.initialize()';
}


}




/// @nodoc


class ChangeMode implements AppModeEvent {
  const ChangeMode(this.mode);
  

 final  AppMode mode;

/// Create a copy of AppModeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ChangeModeCopyWith<ChangeMode> get copyWith => _$ChangeModeCopyWithImpl<ChangeMode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ChangeMode&&(identical(other.mode, mode) || other.mode == mode));
}


@override
int get hashCode => Object.hash(runtimeType,mode);

@override
String toString() {
  return 'AppModeEvent.changeMode(mode: $mode)';
}


}

/// @nodoc
abstract mixin class $ChangeModeCopyWith<$Res> implements $AppModeEventCopyWith<$Res> {
  factory $ChangeModeCopyWith(ChangeMode value, $Res Function(ChangeMode) _then) = _$ChangeModeCopyWithImpl;
@useResult
$Res call({
 AppMode mode
});




}
/// @nodoc
class _$ChangeModeCopyWithImpl<$Res>
    implements $ChangeModeCopyWith<$Res> {
  _$ChangeModeCopyWithImpl(this._self, this._then);

  final ChangeMode _self;
  final $Res Function(ChangeMode) _then;

/// Create a copy of AppModeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? mode = null,}) {
  return _then(ChangeMode(
null == mode ? _self.mode : mode // ignore: cast_nullable_to_non_nullable
as AppMode,
  ));
}


}

/// @nodoc


class SetAccessCode implements AppModeEvent {
  const SetAccessCode(this.code);
  

 final  String code;

/// Create a copy of AppModeEvent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SetAccessCodeCopyWith<SetAccessCode> get copyWith => _$SetAccessCodeCopyWithImpl<SetAccessCode>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SetAccessCode&&(identical(other.code, code) || other.code == code));
}


@override
int get hashCode => Object.hash(runtimeType,code);

@override
String toString() {
  return 'AppModeEvent.setAccessCode(code: $code)';
}


}

/// @nodoc
abstract mixin class $SetAccessCodeCopyWith<$Res> implements $AppModeEventCopyWith<$Res> {
  factory $SetAccessCodeCopyWith(SetAccessCode value, $Res Function(SetAccessCode) _then) = _$SetAccessCodeCopyWithImpl;
@useResult
$Res call({
 String code
});




}
/// @nodoc
class _$SetAccessCodeCopyWithImpl<$Res>
    implements $SetAccessCodeCopyWith<$Res> {
  _$SetAccessCodeCopyWithImpl(this._self, this._then);

  final SetAccessCode _self;
  final $Res Function(SetAccessCode) _then;

/// Create a copy of AppModeEvent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') $Res call({Object? code = null,}) {
  return _then(SetAccessCode(
null == code ? _self.code : code // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

/// @nodoc


class LoginWithGoogle implements AppModeEvent {
  const LoginWithGoogle();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LoginWithGoogle);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppModeEvent.loginWithGoogle()';
}


}




/// @nodoc


class Login implements AppModeEvent {
  const Login();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Login);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppModeEvent.login()';
}


}




/// @nodoc


class PasswordRecoveryStarted implements AppModeEvent {
  const PasswordRecoveryStarted();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordRecoveryStarted);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppModeEvent.passwordRecoveryStarted()';
}


}




/// @nodoc


class PasswordRecoveryFinished implements AppModeEvent {
  const PasswordRecoveryFinished();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PasswordRecoveryFinished);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppModeEvent.passwordRecoveryFinished()';
}


}




/// @nodoc


class RequestLogout implements AppModeEvent {
  const RequestLogout();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RequestLogout);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppModeEvent.requestLogout()';
}


}




/// @nodoc


class Logout implements AppModeEvent {
  const Logout();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Logout);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppModeEvent.logout()';
}


}




/// @nodoc


class Reset implements AppModeEvent {
  const Reset();
  






@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Reset);
}


@override
int get hashCode => runtimeType.hashCode;

@override
String toString() {
  return 'AppModeEvent.reset()';
}


}




// dart format on
