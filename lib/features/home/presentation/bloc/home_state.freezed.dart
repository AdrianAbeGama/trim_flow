// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$HomeState {

 HomeStatus get status; HomeContent get content; bool get isEditing;
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateCopyWith<HomeState> get copyWith => _$HomeStateCopyWithImpl<HomeState>(this as HomeState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeState&&(identical(other.status, status) || other.status == status)&&(identical(other.content, content) || other.content == content)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing));
}


@override
int get hashCode => Object.hash(runtimeType,status,content,isEditing);

@override
String toString() {
  return 'HomeState(status: $status, content: $content, isEditing: $isEditing)';
}


}

/// @nodoc
abstract mixin class $HomeStateCopyWith<$Res>  {
  factory $HomeStateCopyWith(HomeState value, $Res Function(HomeState) _then) = _$HomeStateCopyWithImpl;
@useResult
$Res call({
 HomeStatus status, HomeContent content, bool isEditing
});


$HomeContentCopyWith<$Res> get content;

}
/// @nodoc
class _$HomeStateCopyWithImpl<$Res>
    implements $HomeStateCopyWith<$Res> {
  _$HomeStateCopyWithImpl(this._self, this._then);

  final HomeState _self;
  final $Res Function(HomeState) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? content = null,Object? isEditing = null,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HomeStatus,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as HomeContent,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeContentCopyWith<$Res> get content {
  
  return $HomeContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}


/// Adds pattern-matching-related methods to [HomeState].
extension HomeStatePatterns on HomeState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( HomeStateData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case HomeStateData() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( HomeStateData value)  $default,){
final _that = this;
switch (_that) {
case HomeStateData():
return $default(_that);case _:
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( HomeStateData value)?  $default,){
final _that = this;
switch (_that) {
case HomeStateData() when $default != null:
return $default(_that);case _:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( HomeStatus status,  HomeContent content,  bool isEditing)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case HomeStateData() when $default != null:
return $default(_that.status,_that.content,_that.isEditing);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( HomeStatus status,  HomeContent content,  bool isEditing)  $default,) {final _that = this;
switch (_that) {
case HomeStateData():
return $default(_that.status,_that.content,_that.isEditing);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( HomeStatus status,  HomeContent content,  bool isEditing)?  $default,) {final _that = this;
switch (_that) {
case HomeStateData() when $default != null:
return $default(_that.status,_that.content,_that.isEditing);case _:
  return null;

}
}

}

/// @nodoc


class HomeStateData implements HomeState {
  const HomeStateData({this.status = HomeStatus.initial, this.content = const HomeContent(), this.isEditing = false});
  

@override@JsonKey() final  HomeStatus status;
@override@JsonKey() final  HomeContent content;
@override@JsonKey() final  bool isEditing;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeStateDataCopyWith<HomeStateData> get copyWith => _$HomeStateDataCopyWithImpl<HomeStateData>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeStateData&&(identical(other.status, status) || other.status == status)&&(identical(other.content, content) || other.content == content)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing));
}


@override
int get hashCode => Object.hash(runtimeType,status,content,isEditing);

@override
String toString() {
  return 'HomeState(status: $status, content: $content, isEditing: $isEditing)';
}


}

/// @nodoc
abstract mixin class $HomeStateDataCopyWith<$Res> implements $HomeStateCopyWith<$Res> {
  factory $HomeStateDataCopyWith(HomeStateData value, $Res Function(HomeStateData) _then) = _$HomeStateDataCopyWithImpl;
@override @useResult
$Res call({
 HomeStatus status, HomeContent content, bool isEditing
});


@override $HomeContentCopyWith<$Res> get content;

}
/// @nodoc
class _$HomeStateDataCopyWithImpl<$Res>
    implements $HomeStateDataCopyWith<$Res> {
  _$HomeStateDataCopyWithImpl(this._self, this._then);

  final HomeStateData _self;
  final $Res Function(HomeStateData) _then;

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? content = null,Object? isEditing = null,}) {
  return _then(HomeStateData(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as HomeStatus,content: null == content ? _self.content : content // ignore: cast_nullable_to_non_nullable
as HomeContent,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of HomeState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$HomeContentCopyWith<$Res> get content {
  
  return $HomeContentCopyWith<$Res>(_self.content, (value) {
    return _then(_self.copyWith(content: value));
  });
}
}

// dart format on
