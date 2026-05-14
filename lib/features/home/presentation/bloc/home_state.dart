import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/home_content.dart';

part 'home_state.freezed.dart';

enum HomeStatus { initial, loading, loaded, error }

@freezed
abstract class HomeState with _$HomeState {
  const factory HomeState({
    @Default(HomeStatus.initial) HomeStatus status,
    @Default(HomeContent()) HomeContent content,
    @Default(false) bool isEditing,
  }) = HomeStateData;
}
