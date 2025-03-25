import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/domain/repos/profile_repo.dart';

class FirebaseProfileRepo implements ProfileRepo {
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
  @override
  Future<ProfileUser?> fetchUserProfile(String uid) async {
    try {
      print("🔍 Fetching profile for UID: $uid");

      // Get user document from Firestore
      final userDoc = await firebaseFirestore.collection("User").doc(uid).get();

      if (userDoc.exists) {
        final userData = userDoc.data();
        print("✅ User found: $userData"); // 🔥 See exact data from Firestore

        if (userData != null) {
          // fetch follwers & following
          final followers = List<String>.from(userData["followers"] ?? []);
          final following = List<String>.from(userData["following"] ?? []);

          return ProfileUser(
            uid: uid,
            email: userData["email"] ?? "No Email", // 🔥 Prevents crash if null
            name: userData["name"] ?? "Unknown User",
            bio: userData["bio"] ?? "",
            profileImageUrl: userData["profileImageUrl"]?.toString() ?? "",
            followers: followers,
            following: following,
          );
        }
      } else {
        print("❌ No user document found in Firestore!");
      }

      return null;
    } catch (e) {
      print("❌ Firestore error: $e");
      return null;
    }
  }

  @override
  Future<void> updateProfile(ProfileUser updatedProfile) async {
    try {
      // converts updated profile to json to store in firestore
      await firebaseFirestore
          .collection("User")
          .doc(updatedProfile.uid)
          .update({
            "bio": updatedProfile.bio,
            "profileImageUrl": updatedProfile.profileImageUrl,
          });
    } catch (e) {
      throw Exception();
    }
  }

  @override
  Future<void> toggleFollow(String currentUid, String targetUid) async {
    try {
      final currentUserDoc =
          await firebaseFirestore.collection("User").doc(currentUid).get();
      final targetUserDoc =
          await firebaseFirestore.collection("User").doc(targetUid).get();
      if (currentUserDoc.exists && targetUserDoc.exists) {
        final currentUserData = currentUserDoc.data();
        final targetUserData = targetUserDoc.data();
        if (currentUserData != null ||
            currentUserData!.isEmpty && targetUserData != null ||
            targetUserData!.isEmpty) {
          final List<String> currentFollowing = List<String>.from(
            currentUserData["following"] ?? [],
          );

          // check if current user already following the target user
          if (currentFollowing.contains(targetUid)) {
            // unfollow
            await firebaseFirestore.collection("User").doc(currentUid).update({
              "following": FieldValue.arrayRemove([targetUid]),
            });

            await firebaseFirestore.collection("User").doc(targetUid).update({
              "followers": FieldValue.arrayRemove([currentUid]),
            });
          } else {
            // follow

            await firebaseFirestore.collection("User").doc(currentUid).update({
              "following": FieldValue.arrayUnion([targetUid]),
            });

            await firebaseFirestore.collection("User").doc(targetUid).update({
              "followers": FieldValue.arrayUnion([currentUid]),
            });
          }
        }
      }
    } catch (e) {}
  }
}
