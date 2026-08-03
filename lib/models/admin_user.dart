class AdminUser {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  final bool isAdmin;

  const AdminUser({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.isAdmin,
  });

  String get fullName => '$firstName $lastName'.trim();
}
