enum UserRole { patient, driver }

class UserModel {
  const UserModel({
    required this.name,
    required this.role,
  });

  final String name;
  final UserRole role;
}
