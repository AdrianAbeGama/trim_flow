// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'home_content.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$HomeContent {

 String get heroTitle; String get heroSubtitle; String get heroImageUrl; String get heroTag1; String get heroTag2; List<Map<String, String>> get stories; List<Map<String, String>> get services; List<Map<String, String>> get products; String get aboutUsTitle; String get aboutUsText; String get aboutUsImageUrl; String get aboutUsVideoUrl; Map<String, String> get socialLinks; List<Map<String, String>> get locations;
/// Create a copy of HomeContent
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$HomeContentCopyWith<HomeContent> get copyWith => _$HomeContentCopyWithImpl<HomeContent>(this as HomeContent, _$identity);

  /// Serializes this HomeContent to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is HomeContent&&(identical(other.heroTitle, heroTitle) || other.heroTitle == heroTitle)&&(identical(other.heroSubtitle, heroSubtitle) || other.heroSubtitle == heroSubtitle)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&(identical(other.heroTag1, heroTag1) || other.heroTag1 == heroTag1)&&(identical(other.heroTag2, heroTag2) || other.heroTag2 == heroTag2)&&const DeepCollectionEquality().equals(other.stories, stories)&&const DeepCollectionEquality().equals(other.services, services)&&const DeepCollectionEquality().equals(other.products, products)&&(identical(other.aboutUsTitle, aboutUsTitle) || other.aboutUsTitle == aboutUsTitle)&&(identical(other.aboutUsText, aboutUsText) || other.aboutUsText == aboutUsText)&&(identical(other.aboutUsImageUrl, aboutUsImageUrl) || other.aboutUsImageUrl == aboutUsImageUrl)&&(identical(other.aboutUsVideoUrl, aboutUsVideoUrl) || other.aboutUsVideoUrl == aboutUsVideoUrl)&&const DeepCollectionEquality().equals(other.socialLinks, socialLinks)&&const DeepCollectionEquality().equals(other.locations, locations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,heroTitle,heroSubtitle,heroImageUrl,heroTag1,heroTag2,const DeepCollectionEquality().hash(stories),const DeepCollectionEquality().hash(services),const DeepCollectionEquality().hash(products),aboutUsTitle,aboutUsText,aboutUsImageUrl,aboutUsVideoUrl,const DeepCollectionEquality().hash(socialLinks),const DeepCollectionEquality().hash(locations));

@override
String toString() {
  return 'HomeContent(heroTitle: $heroTitle, heroSubtitle: $heroSubtitle, heroImageUrl: $heroImageUrl, heroTag1: $heroTag1, heroTag2: $heroTag2, stories: $stories, services: $services, products: $products, aboutUsTitle: $aboutUsTitle, aboutUsText: $aboutUsText, aboutUsImageUrl: $aboutUsImageUrl, aboutUsVideoUrl: $aboutUsVideoUrl, socialLinks: $socialLinks, locations: $locations)';
}


}

/// @nodoc
abstract mixin class $HomeContentCopyWith<$Res>  {
  factory $HomeContentCopyWith(HomeContent value, $Res Function(HomeContent) _then) = _$HomeContentCopyWithImpl;
@useResult
$Res call({
 String heroTitle, String heroSubtitle, String heroImageUrl, String heroTag1, String heroTag2, List<Map<String, String>> stories, List<Map<String, String>> services, List<Map<String, String>> products, String aboutUsTitle, String aboutUsText, String aboutUsImageUrl, String aboutUsVideoUrl, Map<String, String> socialLinks, List<Map<String, String>> locations
});




}
/// @nodoc
class _$HomeContentCopyWithImpl<$Res>
    implements $HomeContentCopyWith<$Res> {
  _$HomeContentCopyWithImpl(this._self, this._then);

  final HomeContent _self;
  final $Res Function(HomeContent) _then;

/// Create a copy of HomeContent
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? heroTitle = null,Object? heroSubtitle = null,Object? heroImageUrl = null,Object? heroTag1 = null,Object? heroTag2 = null,Object? stories = null,Object? services = null,Object? products = null,Object? aboutUsTitle = null,Object? aboutUsText = null,Object? aboutUsImageUrl = null,Object? aboutUsVideoUrl = null,Object? socialLinks = null,Object? locations = null,}) {
  return _then(_self.copyWith(
heroTitle: null == heroTitle ? _self.heroTitle : heroTitle // ignore: cast_nullable_to_non_nullable
as String,heroSubtitle: null == heroSubtitle ? _self.heroSubtitle : heroSubtitle // ignore: cast_nullable_to_non_nullable
as String,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,heroTag1: null == heroTag1 ? _self.heroTag1 : heroTag1 // ignore: cast_nullable_to_non_nullable
as String,heroTag2: null == heroTag2 ? _self.heroTag2 : heroTag2 // ignore: cast_nullable_to_non_nullable
as String,stories: null == stories ? _self.stories : stories // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,services: null == services ? _self.services : services // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,aboutUsTitle: null == aboutUsTitle ? _self.aboutUsTitle : aboutUsTitle // ignore: cast_nullable_to_non_nullable
as String,aboutUsText: null == aboutUsText ? _self.aboutUsText : aboutUsText // ignore: cast_nullable_to_non_nullable
as String,aboutUsImageUrl: null == aboutUsImageUrl ? _self.aboutUsImageUrl : aboutUsImageUrl // ignore: cast_nullable_to_non_nullable
as String,aboutUsVideoUrl: null == aboutUsVideoUrl ? _self.aboutUsVideoUrl : aboutUsVideoUrl // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self.socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,locations: null == locations ? _self.locations : locations // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,
  ));
}

}


/// Adds pattern-matching-related methods to [HomeContent].
extension HomeContentPatterns on HomeContent {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _HomeContent value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _HomeContent() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _HomeContent value)  $default,){
final _that = this;
switch (_that) {
case _HomeContent():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _HomeContent value)?  $default,){
final _that = this;
switch (_that) {
case _HomeContent() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String heroTitle,  String heroSubtitle,  String heroImageUrl,  String heroTag1,  String heroTag2,  List<Map<String, String>> stories,  List<Map<String, String>> services,  List<Map<String, String>> products,  String aboutUsTitle,  String aboutUsText,  String aboutUsImageUrl,  String aboutUsVideoUrl,  Map<String, String> socialLinks,  List<Map<String, String>> locations)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _HomeContent() when $default != null:
return $default(_that.heroTitle,_that.heroSubtitle,_that.heroImageUrl,_that.heroTag1,_that.heroTag2,_that.stories,_that.services,_that.products,_that.aboutUsTitle,_that.aboutUsText,_that.aboutUsImageUrl,_that.aboutUsVideoUrl,_that.socialLinks,_that.locations);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String heroTitle,  String heroSubtitle,  String heroImageUrl,  String heroTag1,  String heroTag2,  List<Map<String, String>> stories,  List<Map<String, String>> services,  List<Map<String, String>> products,  String aboutUsTitle,  String aboutUsText,  String aboutUsImageUrl,  String aboutUsVideoUrl,  Map<String, String> socialLinks,  List<Map<String, String>> locations)  $default,) {final _that = this;
switch (_that) {
case _HomeContent():
return $default(_that.heroTitle,_that.heroSubtitle,_that.heroImageUrl,_that.heroTag1,_that.heroTag2,_that.stories,_that.services,_that.products,_that.aboutUsTitle,_that.aboutUsText,_that.aboutUsImageUrl,_that.aboutUsVideoUrl,_that.socialLinks,_that.locations);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String heroTitle,  String heroSubtitle,  String heroImageUrl,  String heroTag1,  String heroTag2,  List<Map<String, String>> stories,  List<Map<String, String>> services,  List<Map<String, String>> products,  String aboutUsTitle,  String aboutUsText,  String aboutUsImageUrl,  String aboutUsVideoUrl,  Map<String, String> socialLinks,  List<Map<String, String>> locations)?  $default,) {final _that = this;
switch (_that) {
case _HomeContent() when $default != null:
return $default(_that.heroTitle,_that.heroSubtitle,_that.heroImageUrl,_that.heroTag1,_that.heroTag2,_that.stories,_that.services,_that.products,_that.aboutUsTitle,_that.aboutUsText,_that.aboutUsImageUrl,_that.aboutUsVideoUrl,_that.socialLinks,_that.locations);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _HomeContent implements HomeContent {
  const _HomeContent({this.heroTitle = '', this.heroSubtitle = '', this.heroImageUrl = '', this.heroTag1 = '', this.heroTag2 = '', final  List<Map<String, String>> stories = const [], final  List<Map<String, String>> services = const [], final  List<Map<String, String>> products = const [], this.aboutUsTitle = '', this.aboutUsText = '', this.aboutUsImageUrl = '', this.aboutUsVideoUrl = '', final  Map<String, String> socialLinks = const {'instagram' : '', 'tiktok' : '', 'whatsapp' : '', 'facebook' : ''}, final  List<Map<String, String>> locations = const []}): _stories = stories,_services = services,_products = products,_socialLinks = socialLinks,_locations = locations;
  factory _HomeContent.fromJson(Map<String, dynamic> json) => _$HomeContentFromJson(json);

@override@JsonKey() final  String heroTitle;
@override@JsonKey() final  String heroSubtitle;
@override@JsonKey() final  String heroImageUrl;
@override@JsonKey() final  String heroTag1;
@override@JsonKey() final  String heroTag2;
 final  List<Map<String, String>> _stories;
@override@JsonKey() List<Map<String, String>> get stories {
  if (_stories is EqualUnmodifiableListView) return _stories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_stories);
}

 final  List<Map<String, String>> _services;
@override@JsonKey() List<Map<String, String>> get services {
  if (_services is EqualUnmodifiableListView) return _services;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_services);
}

 final  List<Map<String, String>> _products;
@override@JsonKey() List<Map<String, String>> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

@override@JsonKey() final  String aboutUsTitle;
@override@JsonKey() final  String aboutUsText;
@override@JsonKey() final  String aboutUsImageUrl;
@override@JsonKey() final  String aboutUsVideoUrl;
 final  Map<String, String> _socialLinks;
@override@JsonKey() Map<String, String> get socialLinks {
  if (_socialLinks is EqualUnmodifiableMapView) return _socialLinks;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_socialLinks);
}

 final  List<Map<String, String>> _locations;
@override@JsonKey() List<Map<String, String>> get locations {
  if (_locations is EqualUnmodifiableListView) return _locations;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_locations);
}


/// Create a copy of HomeContent
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$HomeContentCopyWith<_HomeContent> get copyWith => __$HomeContentCopyWithImpl<_HomeContent>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$HomeContentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _HomeContent&&(identical(other.heroTitle, heroTitle) || other.heroTitle == heroTitle)&&(identical(other.heroSubtitle, heroSubtitle) || other.heroSubtitle == heroSubtitle)&&(identical(other.heroImageUrl, heroImageUrl) || other.heroImageUrl == heroImageUrl)&&(identical(other.heroTag1, heroTag1) || other.heroTag1 == heroTag1)&&(identical(other.heroTag2, heroTag2) || other.heroTag2 == heroTag2)&&const DeepCollectionEquality().equals(other._stories, _stories)&&const DeepCollectionEquality().equals(other._services, _services)&&const DeepCollectionEquality().equals(other._products, _products)&&(identical(other.aboutUsTitle, aboutUsTitle) || other.aboutUsTitle == aboutUsTitle)&&(identical(other.aboutUsText, aboutUsText) || other.aboutUsText == aboutUsText)&&(identical(other.aboutUsImageUrl, aboutUsImageUrl) || other.aboutUsImageUrl == aboutUsImageUrl)&&(identical(other.aboutUsVideoUrl, aboutUsVideoUrl) || other.aboutUsVideoUrl == aboutUsVideoUrl)&&const DeepCollectionEquality().equals(other._socialLinks, _socialLinks)&&const DeepCollectionEquality().equals(other._locations, _locations));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,heroTitle,heroSubtitle,heroImageUrl,heroTag1,heroTag2,const DeepCollectionEquality().hash(_stories),const DeepCollectionEquality().hash(_services),const DeepCollectionEquality().hash(_products),aboutUsTitle,aboutUsText,aboutUsImageUrl,aboutUsVideoUrl,const DeepCollectionEquality().hash(_socialLinks),const DeepCollectionEquality().hash(_locations));

@override
String toString() {
  return 'HomeContent(heroTitle: $heroTitle, heroSubtitle: $heroSubtitle, heroImageUrl: $heroImageUrl, heroTag1: $heroTag1, heroTag2: $heroTag2, stories: $stories, services: $services, products: $products, aboutUsTitle: $aboutUsTitle, aboutUsText: $aboutUsText, aboutUsImageUrl: $aboutUsImageUrl, aboutUsVideoUrl: $aboutUsVideoUrl, socialLinks: $socialLinks, locations: $locations)';
}


}

/// @nodoc
abstract mixin class _$HomeContentCopyWith<$Res> implements $HomeContentCopyWith<$Res> {
  factory _$HomeContentCopyWith(_HomeContent value, $Res Function(_HomeContent) _then) = __$HomeContentCopyWithImpl;
@override @useResult
$Res call({
 String heroTitle, String heroSubtitle, String heroImageUrl, String heroTag1, String heroTag2, List<Map<String, String>> stories, List<Map<String, String>> services, List<Map<String, String>> products, String aboutUsTitle, String aboutUsText, String aboutUsImageUrl, String aboutUsVideoUrl, Map<String, String> socialLinks, List<Map<String, String>> locations
});




}
/// @nodoc
class __$HomeContentCopyWithImpl<$Res>
    implements _$HomeContentCopyWith<$Res> {
  __$HomeContentCopyWithImpl(this._self, this._then);

  final _HomeContent _self;
  final $Res Function(_HomeContent) _then;

/// Create a copy of HomeContent
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? heroTitle = null,Object? heroSubtitle = null,Object? heroImageUrl = null,Object? heroTag1 = null,Object? heroTag2 = null,Object? stories = null,Object? services = null,Object? products = null,Object? aboutUsTitle = null,Object? aboutUsText = null,Object? aboutUsImageUrl = null,Object? aboutUsVideoUrl = null,Object? socialLinks = null,Object? locations = null,}) {
  return _then(_HomeContent(
heroTitle: null == heroTitle ? _self.heroTitle : heroTitle // ignore: cast_nullable_to_non_nullable
as String,heroSubtitle: null == heroSubtitle ? _self.heroSubtitle : heroSubtitle // ignore: cast_nullable_to_non_nullable
as String,heroImageUrl: null == heroImageUrl ? _self.heroImageUrl : heroImageUrl // ignore: cast_nullable_to_non_nullable
as String,heroTag1: null == heroTag1 ? _self.heroTag1 : heroTag1 // ignore: cast_nullable_to_non_nullable
as String,heroTag2: null == heroTag2 ? _self.heroTag2 : heroTag2 // ignore: cast_nullable_to_non_nullable
as String,stories: null == stories ? _self._stories : stories // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,services: null == services ? _self._services : services // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,aboutUsTitle: null == aboutUsTitle ? _self.aboutUsTitle : aboutUsTitle // ignore: cast_nullable_to_non_nullable
as String,aboutUsText: null == aboutUsText ? _self.aboutUsText : aboutUsText // ignore: cast_nullable_to_non_nullable
as String,aboutUsImageUrl: null == aboutUsImageUrl ? _self.aboutUsImageUrl : aboutUsImageUrl // ignore: cast_nullable_to_non_nullable
as String,aboutUsVideoUrl: null == aboutUsVideoUrl ? _self.aboutUsVideoUrl : aboutUsVideoUrl // ignore: cast_nullable_to_non_nullable
as String,socialLinks: null == socialLinks ? _self._socialLinks : socialLinks // ignore: cast_nullable_to_non_nullable
as Map<String, String>,locations: null == locations ? _self._locations : locations // ignore: cast_nullable_to_non_nullable
as List<Map<String, String>>,
  ));
}


}

// dart format on
