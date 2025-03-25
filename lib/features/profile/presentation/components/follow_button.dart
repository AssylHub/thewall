/* 

FOLLOW BUTTON

This is a follow / unfollow button.

-------------------------------------------------------------

To use this widget, you need:

- a function ( e.g toggleFollow() ),
- isFollowing ( e.g false -> then we will show follow button istead of unfollow button )

*/

import 'package:flutter/material.dart';

class FollowButton extends StatelessWidget {
  final void Function()? onPressed;
  final bool isFollowing;
  const FollowButton({
    super.key,
    required this.onPressed,
    required this.isFollowing,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),

        child: MaterialButton(
          onPressed: onPressed,
          padding: EdgeInsets.all(25),
          color:
              isFollowing ? Theme.of(context).colorScheme.primary : Colors.blue,
          child: Text(
            isFollowing ? "Unfollow" : "Follow",
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
