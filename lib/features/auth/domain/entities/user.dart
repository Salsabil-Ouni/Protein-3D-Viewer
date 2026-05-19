class User {
  final int id;
  final String uid;
  final String email;
  final String firstName;
  final String lastName;
  final String? token;

  const User({
    required this.id,
    required this.uid,
    required this.email,
    required this.firstName,
    required this.lastName,
    this.token,
  });

  String get fullName => '$firstName $lastName'.trim();
}
