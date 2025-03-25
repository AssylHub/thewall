import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/post/presentation/components/post_tile.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_media_app/features/profile/presentation/components/bio_box.dart';
import 'package:social_media_app/features/profile/presentation/components/follow_button.dart';
import 'package:social_media_app/features/profile/presentation/components/profile_stats.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media_app/features/profile/presentation/pages/edit_profile_page.dart';
import 'package:social_media_app/features/profile/presentation/pages/follower_page.dart';
import 'package:social_media_app/responsive/constrainded_scaffol.dart';

class ProfilePage extends StatefulWidget {
  final String uid;
  const ProfilePage({super.key, required this.uid});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // cubits
  late final authCubit = context.read<AuthCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  // current user
  late AppUser? currentUser = authCubit.currentUser;

  // posty
  int postCount = 0;

  // on startup
  @override
  void initState() {
    super.initState();
    // load user profile data
    profileCubit.fetchUserProfile(widget.uid);
  }

  /* 
  
  FOLLOW / UNFOLLOW
  
  */

  void followButtonPressed() {
    final profileState = profileCubit.state;
    if (profileState is! ProfileLoaded) {
      return; // return if profile is loaded
    }

    final profileUser = profileState.profileUser;
    final isFollowing = profileUser.followers.contains(currentUser!.uid);

    // optimistically update UI
    setState(() {
      // unfollow
      if (isFollowing) {
        profileUser.followers.remove(currentUser!.uid);
      }
      // follow
      else {
        profileUser.followers.add(currentUser!.uid);
      }
    });

    // perform actual toggle in cubit
    profileCubit.toggleFollow(currentUser!.uid, widget.uid).catchError((error) {
      // revert update if there's an error
      setState(() {
        // unfollow
        if (isFollowing) {
          profileUser.followers.add(currentUser!.uid);
        }
        // follow
        else {
          profileUser.followers.remove(currentUser!.uid);
        }
      });
    });
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // is own post
    bool isOwnPost = (widget.uid == currentUser!.uid);

    return BlocBuilder<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // loaded
        if (state is ProfileLoaded) {
          // get loaded user
          final user = state.profileUser;

          return ConstraindedScaffold(
            // APP BAR
            appBar: AppBar(
              title: Text(user.name),
              centerTitle: true,
              foregroundColor: Theme.of(context).colorScheme.primary,
              actions: [
                // edit profile button
                if (isOwnPost)
                  IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(user: user),
                        ),
                      );
                    },
                    icon: Icon(Icons.settings),
                  ),
              ],
            ),

            // BODY
            body: ListView(
              children: [
                // email
                Center(
                  child: Text(
                    user.email,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                // profile pic
                Container(
                  width: 200,
                  height: 200,
                  clipBehavior: Clip.hardEdge,
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    shape: BoxShape.circle,
                  ),
                  child: CachedNetworkImage(
                    imageUrl: user.profileImageUrl,

                    // loading
                    placeholder: (context, url) => CircularProgressIndicator(),

                    // error -> failed to load
                    errorWidget:
                        (context, url, error) => Icon(
                          Icons.person,
                          size: 72,
                          color: Theme.of(context).colorScheme.primary,
                        ),

                    imageBuilder:
                        (context, imageProvider) =>
                            Image(image: imageProvider, fit: BoxFit.cover),
                  ),
                ),

                const SizedBox(height: 25),

                // profile stats
                ProfileStats(
                  postCount: postCount,
                  followerCount: user.followers.length,
                  followingCount: user.following.length,
                  onTap:
                      () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder:
                              (context) => FollowerPage(
                                followers: user.followers,
                                following: user.following,
                              ),
                        ),
                      ),
                ),

                const SizedBox(height: 25),

                // follow button
                if (!isOwnPost)
                  FollowButton(
                    onPressed: followButtonPressed,
                    isFollowing: user.followers.contains(currentUser!.uid),
                  ),

                const SizedBox(height: 25),

                // bio box
                Row(
                  children: [
                    const SizedBox(width: 25),

                    Text(
                      "Bio",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 10),

                BioBox(text: user.bio),

                const SizedBox(height: 25),

                // posts
                Row(
                  children: [
                    const SizedBox(width: 25),

                    Text(
                      "Posts",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // list of posts from this user
                BlocBuilder<PostCubit, PostState>(
                  builder: (context, state) {
                    // posts loaded
                    if (state is PostLoaded) {
                      // filter posts by user id
                      final userPosts =
                          state.posts
                              .where((post) => post.userId == widget.uid)
                              .toList();

                      postCount = userPosts.length;
                      return ListView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: postCount,
                        itemBuilder: (context, index) {
                          // get individual post
                          final post = userPosts[index];

                          // return post tile UI
                          return PostTile(
                            post: post,
                            onDeletePressed:
                                () => context.read<PostCubit>().deletePost(
                                  post.id,
                                ),
                          );
                        },
                      );
                    }
                    // posts loading
                    else if (state is PostsLoading) {
                      return Center(child: CircularProgressIndicator());
                    } else {
                      return Center(child: Text("No posts.."));
                    }
                  },
                ),
              ],
            ),
          );
        }
        // loading
        else if (state is ProfileLoading) {
          return Scaffold(body: Center(child: CircularProgressIndicator()));
        } else {
          return const Center(child: Text("No profile found.."));
        }
      },
    );
  }
}
