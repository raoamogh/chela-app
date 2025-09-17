import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/user_profile_model.dart';
import '../api/api_service.dart';

// Notifier to manage the profile data and updates
class ProfileNotifier extends StateNotifier<AsyncValue<UserProfile>> {
  ProfileNotifier() : super(const AsyncValue.loading()) {
    loadProfile();
  }

  Future<void> loadProfile() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => ApiService.getUserProfile());
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    final success = await ApiService.updateUserProfile(data);
    if (success) {
      await loadProfile(); // Refresh data on successful save
    }
    return success;
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, AsyncValue<UserProfile>>((ref) {
  return ProfileNotifier();
});