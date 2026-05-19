import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.uid,
    required super.email,
    required super.firstName,
    required super.lastName,
    super.token,
  });

  factory UserModel.fromJson(Map<String, dynamic> json, {String? token}) {
    return UserModel(
      id: json['id'] ?? 0,
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      token: token,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'uid': uid,
        'email': email,
        'first_name': firstName,
        'last_name': lastName,
      };
}
