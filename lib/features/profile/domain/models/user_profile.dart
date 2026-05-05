import 'package:equatable/equatable.dart';

class CuttingRecord extends Equatable {
  const CuttingRecord({
    required this.day,
    required this.time,
    required this.price,
  });

  final String day;
  final String time;
  final String price;

  @override
  List<Object?> get props => [day, time, price];
}

class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.photoUrl,
    required this.phone,
    required this.birthDate,
    required this.notificationsEnabled,
    this.history = const [],
  });

  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final String photoUrl;
  final String phone;
  final String birthDate;
  final bool notificationsEnabled;
  final List<CuttingRecord> history;

  UserProfile copyWith({
    String? firstName,
    String? lastName,
    String? phone,
    String? birthDate,
    bool? notificationsEnabled,
    List<CuttingRecord>? history,
  }) {
    return UserProfile(
      id: id,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      email: email,
      photoUrl: photoUrl,
      phone: phone ?? this.phone,
      birthDate: birthDate ?? this.birthDate,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      history: history ?? this.history,
    );
  }

  @override
  List<Object?> get props => [
        id,
        firstName,
        lastName,
        email,
        photoUrl,
        phone,
        birthDate,
        notificationsEnabled,
        history,
      ];
}
