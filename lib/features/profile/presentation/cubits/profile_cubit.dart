import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/domain/repos/profile_repo.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media_app/features/storage/domain/storage_repo.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepo profileRepo;
  final StorageRepo storageRepo;

  ProfileCubit({required this.storageRepo, required this.profileRepo})
    : super(ProfileInitial());

  // fetch user profile using repo -> userful for loading single profile pages
  Future<void> fetchUserProfile(String uid) async {
    emit(ProfileLoading());
    try {
      print("Fetching profile for UID: $uid");

      final user = await profileRepo.fetchUserProfile(uid);

      if (user != null) {
        print("✅ Profile Loaded: ${user.name}");
        emit(ProfileLoaded(user));
      } else {
        print("❌ Profile not found");
        emit(ProfileError("User not found!"));
      }
    } catch (e) {
      print("❌ Error: $e");
      emit(ProfileError(e.toString()));
    }
  }

  // return user profile given uid -> useful for loading many profiles for posts
  Future<ProfileUser?> getUserProfile(String uid) async {
    final user = await profileRepo.fetchUserProfile(uid);
    return user;
  }

  // update bio or profile picture
  Future<void> updateProfile({
    required String uid,
    String? newBio,
    String? imageMobilePath,
    Uint8List? imageWebBytes,
  }) async {
    emit(ProfileLoading());

    try {
      // fetch current profile first
      final currentUser = await profileRepo.fetchUserProfile(uid);

      if (currentUser == null) {
        emit(ProfileError("Failed to fetch user for profile update"));
        return;
      }

      // profile picture update
      String? imageDownloadUrl;

      // ensure there is an image
      if (imageWebBytes != null || imageMobilePath != null) {
        // for mobile
        if (imageMobilePath != null) {
          // upload
          imageDownloadUrl = await storageRepo.uploadProfileImageMobile(
            imageMobilePath,
            uid,
          );
        } else if (imageWebBytes != null) {
          // upload
          imageDownloadUrl = await storageRepo.uploadProfileImageWeb(
            imageWebBytes,
            uid,
          );
        }

        if (imageDownloadUrl == null) {
          emit(ProfileError("Failed to upload image"));
          return;
        }
      }
      // update new profile
      final updatedProfile = currentUser.copyWith(
        newBio: newBio ?? currentUser.bio,
        newProfileImageUrl: imageDownloadUrl ?? currentUser.profileImageUrl,
      );

      // update  in repo
      await profileRepo.updateProfile(updatedProfile);

      // re-fetch the updated profile
      await fetchUserProfile(uid);
    } catch (e) {
      emit(ProfileError("Error updating profile: $e"));
    }
  }

  // toggle follow/unfollow
  Future<void> toggleFollow(String currentUserId, String targetUserId) async {
    try {
      await profileRepo.toggleFollow(currentUserId, targetUserId);
      // await fetchUserProfile(targetUserId);
    } catch (e) {
      emit(ProfileError("Error toggling error: $e"));
    }
  }
}
