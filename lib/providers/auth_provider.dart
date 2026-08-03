import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/admin_user.dart';
import '../repositories/admin_repository.dart';
import 'repository_providers.dart';

class AdminAuthState {
  final AdminUser? user;
  final bool isLoading;
  final String? error;
  final bool checked;

  const AdminAuthState({this.user, this.isLoading = false, this.error, this.checked = false});

  AdminAuthState copyWith({AdminUser? user, bool? isLoading, String? error, bool? checked, bool clearUser = false}) {
    return AdminAuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: error,
      checked: checked ?? this.checked,
    );
  }
}

class AdminAuthNotifier extends StateNotifier<AdminAuthState> {
  final AdminRepository _repo;
  AdminAuthNotifier(this._repo) : super(const AdminAuthState());

  Future<void> restoreSession() async {
    final user = await _repo.currentUser();
    state = state.copyWith(user: user, checked: true);
  }

  Future<bool> login(String email, String password) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final user = await _repo.login(email, password);
      if (!user.isAdmin) {
        await _repo.logout();
        state = state.copyWith(isLoading: false, error: 'access_denied', clearUser: true);
        return false;
      }
      state = state.copyWith(user: user, isLoading: false);
      return true;
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
      return false;
    }
  }

  Future<void> logout() async {
    await _repo.logout();
    state = state.copyWith(clearUser: true);
  }
}

final adminAuthProvider = StateNotifierProvider<AdminAuthNotifier, AdminAuthState>((ref) {
  return AdminAuthNotifier(ref.watch(adminRepositoryProvider));
});
