/* 

POST STATES

*/

import 'package:social_media_app/features/post/domain/entities/post.dart';

abstract class PostState {}

// initial
class PostsInitial extends PostState {}

// loading
class PostsLoading extends PostState {}

// uploading
class PostUploading extends PostState {}

// error
class PostsError extends PostState {
  final String message;
  PostsError(this.message);
}

// loaded
class PostLoaded extends PostState {
  final List<Post> posts;

  PostLoaded({required this.posts});
}
