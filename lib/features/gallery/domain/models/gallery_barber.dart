class GalleryBarber {
  final String id;
  final String name;
  final String specialty;
  final String? avatarHint;
  final bool isLocalAvatar;

  const GalleryBarber({
    required this.id,
    required this.name,
    required this.specialty,
    this.avatarHint,
    this.isLocalAvatar = false,
  });

  GalleryBarber copyWith({
    String? name,
    String? specialty,
    String? avatarHint,
    bool? isLocalAvatar,
  }) {
    return GalleryBarber(
      id: id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      avatarHint: avatarHint ?? this.avatarHint,
      isLocalAvatar: isLocalAvatar ?? this.isLocalAvatar,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'avatarHint': avatarHint,
      'isLocalAvatar': isLocalAvatar,
    };
  }

  static GalleryBarber fromMap(Map<dynamic, dynamic> raw) {
    final map = raw.cast<String, dynamic>();
    return GalleryBarber(
      id: map['id'] as String,
      name: map['name'] as String,
      specialty: map['specialty'] as String,
      avatarHint: map['avatarHint'] as String?,
      isLocalAvatar: map['isLocalAvatar'] as bool? ?? false,
    );
  }
}
