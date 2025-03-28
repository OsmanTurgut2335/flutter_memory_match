import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mem_game/data/user/model/user_model.dart';
import 'package:mem_game/data/user/repository/user_repository.dart';
import 'package:mem_game/features/user/viewmodel/user_viewmodel.dart';

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository();
});

final userNotifierProvider = StateNotifierProvider<UserNotifier, UserModel?>((
  ref,
) {
  final repository = ref.watch(userRepositoryProvider);
  return UserNotifier(repository);
});
