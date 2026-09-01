import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/storage/user_storage.dart';

class CurrentUser {
  final String name;
  final String email;

  const CurrentUser({
    required this.name,
    required this.email,
  });
}

final currentUserProvider = FutureProvider<CurrentUser>((ref) async {
  final name = await UserStorage.getName();
  final email = await UserStorage.getEmail();

  return CurrentUser(
    name: name ?? 'Nutri User',
    email: email ?? '',
  );
});
