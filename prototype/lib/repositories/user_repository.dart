import 'package:medirapid/features/patient/models/user_model.dart';

class UserRepository {
  Future<List<UserModel>> getUsers() async {
    return [
      UserModel(name: 'r', role: UserRole.patient),
      UserModel(name: 's', role: UserRole.driver),
    ];
  }
}
