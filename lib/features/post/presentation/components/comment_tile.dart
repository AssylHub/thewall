import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/post/domain/entities/comment.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubit.dart';

class CommentTile extends StatefulWidget {
  const CommentTile({super.key, required this.comment});
  final Comment comment;

  @override
  State<CommentTile> createState() => _CommentTileState();
}

class _CommentTileState extends State<CommentTile> {
  // current user
  AppUser? currentUser;
  bool isOwnPost = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
    isOwnPost = widget.comment.userId == currentUser!.uid;
  }

  // show options for deletion
  void showOptions() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text("Delete comment?"),
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
                  context.read<PostCubit>().deleteComment(
                    widget.comment.postId,
                    widget.comment.id,
                  );
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // name
          Text(
            widget.comment.userName,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),

          SizedBox(width: 10),

          // comment text
          Text(widget.comment.text),

          Spacer(),

          // delete button
          if (isOwnPost)
            GestureDetector(
              onTap: showOptions,
              child: Icon(
                Icons.more_horiz,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
        ],
      ),
    );
  }
}
