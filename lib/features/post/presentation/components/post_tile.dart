import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:social_media_app/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/post/domain/entities/comment.dart';
import 'package:social_media_app/features/post/domain/entities/post.dart';
import 'package:social_media_app/features/post/presentation/components/comment_tile.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app/features/profile/presentation/pages/profile_page.dart';

class PostTile extends StatefulWidget {
  final Post post;
  final void Function()? onDeletePressed;
  const PostTile({
    super.key,
    required this.post,
    required this.onDeletePressed,
  });

  @override
  State<PostTile> createState() => _PostTileState();
}

class _PostTileState extends State<PostTile> {
  // cubits
  late final postCubit = context.read<PostCubit>();
  late final profileCubit = context.read<ProfileCubit>();

  bool isOwnFalse = false;

  // current user
  AppUser? currentUser;

  // post user
  ProfileUser? postUser;

  // onstartup,
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
    fetchPostUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnFalse = (widget.post.userId == currentUser!.uid);
  }

  Future<void> fetchPostUser() async {
    final fetchedUser = await profileCubit.getUserProfile(widget.post.userId);
    if (fetchedUser != null) {
      setState(() {
        postUser = fetchedUser;
      });
    }
  }

  /* 
  
  LIKES
  
  */

  // user tapped like button
  void toggleLikePost() {
    // current like status
    final isLiked = widget.post.likes.contains(currentUser!.uid);

    setState(() {
      if (isLiked) {
        widget.post.likes.remove(currentUser!.uid); // unlike
      } else {
        widget.post.likes.add(currentUser!.uid); // like
      }
    });

    // update like
    postCubit.toggleLikePost(widget.post.id, currentUser!.uid).catchError((
      error,
    ) {
      // if there's an error, revert back to original values
      setState(() {
        if (isLiked) {
          widget.post.likes.add(currentUser!.uid); // revert unlike
        } else {
          widget.post.likes.remove(currentUser!.uid); // revert like
        }
      });
    });
  }

  /* 
  
  COMMENTS
  
  */

  // comment text controller
  final commentTextController = TextEditingController();

  // open comment box -> user wants to type a new comment
  void openNewCommentBox() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Add a new comment."),
            content: MyTextField(
              controller: commentTextController,
              hintText: "Type a comment",
              obscureText: false,
            ),

            actions: [
              // cancel button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),

              // save button
              TextButton(
                onPressed: () {
                  addComment();
                  Navigator.of(context).pop();
                },
                child: Text("Add"),
              ),
            ],
          ),
    );
  }

  void addComment() {
    // create a new comment
    final newComment = Comment(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      postId: widget.post.id,
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: commentTextController.text,
      timestamp: DateTime.now(),
    );

    // add comment using cubit
    if (commentTextController.text.isNotEmpty) {
      postCubit.addComment(widget.post.id, newComment);
    }
  }

  @override
  void dispose() {
    commentTextController.dispose();
    super.dispose();
  }

  // show options for deletion
  void showOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Delete post?"),
            actions: [
              // cancel button
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text("Cancel"),
              ),

              // delete button
              TextButton(
                onPressed: () {
                  widget.onDeletePressed!();
                  Navigator.of(context).pop();
                },
                child: Text("Delete"),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(color: Theme.of(context).colorScheme.secondary),
      child: Column(
        children: [
          // TOP SECTION: profile pic / name / delete button
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => ProfilePage(uid: widget.post.userId),
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  // profile pic
                  postUser?.profileImageUrl != null
                      ? CachedNetworkImage(
                        imageUrl: postUser!.profileImageUrl,
                        errorWidget:
                            (context, url, error) => Icon(Icons.person),
                        imageBuilder:
                            (context, imageProvider) => Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,

                                image: DecorationImage(
                                  image: imageProvider,
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                      )
                      : Icon(Icons.person),

                  SizedBox(width: 10),

                  // name
                  Text(
                    widget.post.userName,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Spacer(),

                  // delete button
                  if (isOwnFalse)
                    GestureDetector(
                      onTap: showOptions,
                      child: Icon(
                        Icons.delete,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                ],
              ),
            ),
          ),
          CachedNetworkImage(
            imageUrl: widget.post.imageUrl,
            height: 430,
            width: double.infinity,
            fit: BoxFit.cover,
            placeholder: (context, url) => SizedBox(height: 430),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),

          // buttons -> like, comment, timestamp
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                SizedBox(
                  width: 50,
                  child: Row(
                    children: [
                      // like button
                      GestureDetector(
                        onTap: toggleLikePost,
                        child:
                            widget.post.likes.contains(currentUser!.uid)
                                ? Icon(Icons.favorite, color: Colors.red)
                                : Icon(
                                  Icons.favorite_border,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                      ),

                      SizedBox(width: 5),

                      // like count
                      Text(
                        widget.post.likes.length.toString(),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),

                SizedBox(width: 20),

                // comment button
                GestureDetector(
                  onTap: openNewCommentBox,
                  child: Icon(
                    Icons.comment,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(width: 5),

                Text(
                  widget.post.comments.length.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

                SizedBox(width: 20),

                Spacer(),

                // timestamp
                Text(
                  widget.post.timestamp.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),

          // CAPTION
          Padding(
            padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
            child: Row(
              children: [
                // username
                Text(
                  widget.post.userName,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),

                SizedBox(width: 10),

                // text
                Text(widget.post.text),
              ],
            ),
          ),

          // COMMENT SECTION
          BlocBuilder<PostCubit, PostState>(
            builder: (context, state) {
              // LOADED
              if (state is PostLoaded) {
                // individual post
                final post = state.posts.firstWhere(
                  (post) => (post.id == widget.post.id),
                );

                if (post.comments.isNotEmpty) {
                  // how many comments show
                  int showCommentCount = post.comments.length;

                  // comment section
                  return ListView.builder(
                    itemCount: showCommentCount,
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      // get individual post
                      final comment = post.comments[index];

                      // comment tile UI
                      return CommentTile(comment: comment);
                    },
                  );
                }
              }

              // LOADING

              if (state is PostsLoading) {
                return Center(child: CircularProgressIndicator());
              }

              // ERROR
              if (state is PostsError) {
                return Center(child: Text(state.message));
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
    );
  }
}
