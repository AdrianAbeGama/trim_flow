// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'gallery_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$GalleryState {

 GalleryStatus get status; List<GalleryItem> get allItems; List<GalleryCategory> get categories; String? get selectedCategorySlug; String get searchQuery; bool get isEditing; bool get showOnlyFeatured; GalleryFilterMode get filterMode; String? get selectedBarberName; String? get errorMessage; String? get actionError;
/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$GalleryStateCopyWith<GalleryState> get copyWith => _$GalleryStateCopyWithImpl<GalleryState>(this as GalleryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is GalleryState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other.allItems, allItems)&&const DeepCollectionEquality().equals(other.categories, categories)&&(identical(other.selectedCategorySlug, selectedCategorySlug) || other.selectedCategorySlug == selectedCategorySlug)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.showOnlyFeatured, showOnlyFeatured) || other.showOnlyFeatured == showOnlyFeatured)&&(identical(other.filterMode, filterMode) || other.filterMode == filterMode)&&(identical(other.selectedBarberName, selectedBarberName) || other.selectedBarberName == selectedBarberName)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.actionError, actionError) || other.actionError == actionError));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(allItems),const DeepCollectionEquality().hash(categories),selectedCategorySlug,searchQuery,isEditing,showOnlyFeatured,filterMode,selectedBarberName,errorMessage,actionError);

@override
String toString() {
  return 'GalleryState(status: $status, allItems: $allItems, categories: $categories, selectedCategorySlug: $selectedCategorySlug, searchQuery: $searchQuery, isEditing: $isEditing, showOnlyFeatured: $showOnlyFeatured, filterMode: $filterMode, selectedBarberName: $selectedBarberName, errorMessage: $errorMessage, actionError: $actionError)';
}


}

/// @nodoc
abstract mixin class $GalleryStateCopyWith<$Res>  {
  factory $GalleryStateCopyWith(GalleryState value, $Res Function(GalleryState) _then) = _$GalleryStateCopyWithImpl;
@useResult
$Res call({
 GalleryStatus status, List<GalleryItem> allItems, List<GalleryCategory> categories, String? selectedCategorySlug, String searchQuery, bool isEditing, bool showOnlyFeatured, GalleryFilterMode filterMode, String? selectedBarberName, String? errorMessage, String? actionError
});




}
/// @nodoc
class _$GalleryStateCopyWithImpl<$Res>
    implements $GalleryStateCopyWith<$Res> {
  _$GalleryStateCopyWithImpl(this._self, this._then);

  final GalleryState _self;
  final $Res Function(GalleryState) _then;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? allItems = null,Object? categories = null,Object? selectedCategorySlug = freezed,Object? searchQuery = null,Object? isEditing = null,Object? showOnlyFeatured = null,Object? filterMode = null,Object? selectedBarberName = freezed,Object? errorMessage = freezed,Object? actionError = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GalleryStatus,allItems: null == allItems ? _self.allItems : allItems // ignore: cast_nullable_to_non_nullable
as List<GalleryItem>,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<GalleryCategory>,selectedCategorySlug: freezed == selectedCategorySlug ? _self.selectedCategorySlug : selectedCategorySlug // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,showOnlyFeatured: null == showOnlyFeatured ? _self.showOnlyFeatured : showOnlyFeatured // ignore: cast_nullable_to_non_nullable
as bool,filterMode: null == filterMode ? _self.filterMode : filterMode // ignore: cast_nullable_to_non_nullable
as GalleryFilterMode,selectedBarberName: freezed == selectedBarberName ? _self.selectedBarberName : selectedBarberName // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,actionError: freezed == actionError ? _self.actionError : actionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [GalleryState].
extension GalleryStatePatterns on GalleryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _GalleryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _GalleryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _GalleryState value)  $default,){
final _that = this;
switch (_that) {
case _GalleryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _GalleryState value)?  $default,){
final _that = this;
switch (_that) {
case _GalleryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( GalleryStatus status,  List<GalleryItem> allItems,  List<GalleryCategory> categories,  String? selectedCategorySlug,  String searchQuery,  bool isEditing,  bool showOnlyFeatured,  GalleryFilterMode filterMode,  String? selectedBarberName,  String? errorMessage,  String? actionError)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _GalleryState() when $default != null:
return $default(_that.status,_that.allItems,_that.categories,_that.selectedCategorySlug,_that.searchQuery,_that.isEditing,_that.showOnlyFeatured,_that.filterMode,_that.selectedBarberName,_that.errorMessage,_that.actionError);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( GalleryStatus status,  List<GalleryItem> allItems,  List<GalleryCategory> categories,  String? selectedCategorySlug,  String searchQuery,  bool isEditing,  bool showOnlyFeatured,  GalleryFilterMode filterMode,  String? selectedBarberName,  String? errorMessage,  String? actionError)  $default,) {final _that = this;
switch (_that) {
case _GalleryState():
return $default(_that.status,_that.allItems,_that.categories,_that.selectedCategorySlug,_that.searchQuery,_that.isEditing,_that.showOnlyFeatured,_that.filterMode,_that.selectedBarberName,_that.errorMessage,_that.actionError);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( GalleryStatus status,  List<GalleryItem> allItems,  List<GalleryCategory> categories,  String? selectedCategorySlug,  String searchQuery,  bool isEditing,  bool showOnlyFeatured,  GalleryFilterMode filterMode,  String? selectedBarberName,  String? errorMessage,  String? actionError)?  $default,) {final _that = this;
switch (_that) {
case _GalleryState() when $default != null:
return $default(_that.status,_that.allItems,_that.categories,_that.selectedCategorySlug,_that.searchQuery,_that.isEditing,_that.showOnlyFeatured,_that.filterMode,_that.selectedBarberName,_that.errorMessage,_that.actionError);case _:
  return null;

}
}

}

/// @nodoc


class _GalleryState extends GalleryState {
  const _GalleryState({this.status = GalleryStatus.initial, final  List<GalleryItem> allItems = const <GalleryItem>[], final  List<GalleryCategory> categories = const <GalleryCategory>[], this.selectedCategorySlug, this.searchQuery = '', this.isEditing = false, this.showOnlyFeatured = false, this.filterMode = GalleryFilterMode.styles, this.selectedBarberName, this.errorMessage, this.actionError}): _allItems = allItems,_categories = categories,super._();
  

@override@JsonKey() final  GalleryStatus status;
 final  List<GalleryItem> _allItems;
@override@JsonKey() List<GalleryItem> get allItems {
  if (_allItems is EqualUnmodifiableListView) return _allItems;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allItems);
}

 final  List<GalleryCategory> _categories;
@override@JsonKey() List<GalleryCategory> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

@override final  String? selectedCategorySlug;
@override@JsonKey() final  String searchQuery;
@override@JsonKey() final  bool isEditing;
@override@JsonKey() final  bool showOnlyFeatured;
@override@JsonKey() final  GalleryFilterMode filterMode;
@override final  String? selectedBarberName;
@override final  String? errorMessage;
@override final  String? actionError;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$GalleryStateCopyWith<_GalleryState> get copyWith => __$GalleryStateCopyWithImpl<_GalleryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _GalleryState&&(identical(other.status, status) || other.status == status)&&const DeepCollectionEquality().equals(other._allItems, _allItems)&&const DeepCollectionEquality().equals(other._categories, _categories)&&(identical(other.selectedCategorySlug, selectedCategorySlug) || other.selectedCategorySlug == selectedCategorySlug)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery)&&(identical(other.isEditing, isEditing) || other.isEditing == isEditing)&&(identical(other.showOnlyFeatured, showOnlyFeatured) || other.showOnlyFeatured == showOnlyFeatured)&&(identical(other.filterMode, filterMode) || other.filterMode == filterMode)&&(identical(other.selectedBarberName, selectedBarberName) || other.selectedBarberName == selectedBarberName)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.actionError, actionError) || other.actionError == actionError));
}


@override
int get hashCode => Object.hash(runtimeType,status,const DeepCollectionEquality().hash(_allItems),const DeepCollectionEquality().hash(_categories),selectedCategorySlug,searchQuery,isEditing,showOnlyFeatured,filterMode,selectedBarberName,errorMessage,actionError);

@override
String toString() {
  return 'GalleryState(status: $status, allItems: $allItems, categories: $categories, selectedCategorySlug: $selectedCategorySlug, searchQuery: $searchQuery, isEditing: $isEditing, showOnlyFeatured: $showOnlyFeatured, filterMode: $filterMode, selectedBarberName: $selectedBarberName, errorMessage: $errorMessage, actionError: $actionError)';
}


}

/// @nodoc
abstract mixin class _$GalleryStateCopyWith<$Res> implements $GalleryStateCopyWith<$Res> {
  factory _$GalleryStateCopyWith(_GalleryState value, $Res Function(_GalleryState) _then) = __$GalleryStateCopyWithImpl;
@override @useResult
$Res call({
 GalleryStatus status, List<GalleryItem> allItems, List<GalleryCategory> categories, String? selectedCategorySlug, String searchQuery, bool isEditing, bool showOnlyFeatured, GalleryFilterMode filterMode, String? selectedBarberName, String? errorMessage, String? actionError
});




}
/// @nodoc
class __$GalleryStateCopyWithImpl<$Res>
    implements _$GalleryStateCopyWith<$Res> {
  __$GalleryStateCopyWithImpl(this._self, this._then);

  final _GalleryState _self;
  final $Res Function(_GalleryState) _then;

/// Create a copy of GalleryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? allItems = null,Object? categories = null,Object? selectedCategorySlug = freezed,Object? searchQuery = null,Object? isEditing = null,Object? showOnlyFeatured = null,Object? filterMode = null,Object? selectedBarberName = freezed,Object? errorMessage = freezed,Object? actionError = freezed,}) {
  return _then(_GalleryState(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as GalleryStatus,allItems: null == allItems ? _self._allItems : allItems // ignore: cast_nullable_to_non_nullable
as List<GalleryItem>,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<GalleryCategory>,selectedCategorySlug: freezed == selectedCategorySlug ? _self.selectedCategorySlug : selectedCategorySlug // ignore: cast_nullable_to_non_nullable
as String?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,isEditing: null == isEditing ? _self.isEditing : isEditing // ignore: cast_nullable_to_non_nullable
as bool,showOnlyFeatured: null == showOnlyFeatured ? _self.showOnlyFeatured : showOnlyFeatured // ignore: cast_nullable_to_non_nullable
as bool,filterMode: null == filterMode ? _self.filterMode : filterMode // ignore: cast_nullable_to_non_nullable
as GalleryFilterMode,selectedBarberName: freezed == selectedBarberName ? _self.selectedBarberName : selectedBarberName // ignore: cast_nullable_to_non_nullable
as String?,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,actionError: freezed == actionError ? _self.actionError : actionError // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
