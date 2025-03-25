import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/home/presentation/components/my_drawer.dart';
import 'package:social_media_app/features/post/presentation/components/post_tile.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_media_app/features/post/presentation/pages/upload_post_page.dart';
import 'package:social_media_app/responsive/constrainded_scaffol.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // post cubit
  late final postCubit = context.read<PostCubit>();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    // fetch all posts
    fetchAllPosts();
  }

  void fetchAllPosts() {
    postCubit.fetchAllPosts();
  }

  void deletePost(String postId) {
    postCubit.deletePost(postId);
    fetchAllPosts();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return ConstraindedScaffold(
      // APPBAR
      appBar: AppBar(
        title: Text("Home"),
        centerTitle: true,
        actions: [
          // upload new post button
          IconButton(
            onPressed: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (context) => UploadPostPage()));
            },
            icon: Icon(Icons.add),
          ),

          // logout button
          IconButton(
            onPressed: () {
              context.read<AuthCubit>().logout();
            },
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      drawer: MyDrawer(),
      body: BlocBuilder<PostCubit, PostState>(
        builder: (context, state) {
          // loading
          if (state is PostsLoading || state is PostUploading) {
            return Center(child: CircularProgressIndicator());
          }
          // loaded
          else if (state is PostLoaded) {
            final allPosts = state.posts;
            if (allPosts.isEmpty) {
              return Center(child: Text("No posts available"));
            }

            return ListView.builder(
              itemCount: allPosts.length,
              itemBuilder: (context, index) {
                // get individual post
                final post = allPosts[index];

                // image
                return PostTile(
                  post: post,
                  onDeletePressed: () => deletePost(post.id),
                );
              },
            );
          }
          // error
          else if (state is PostsError) {
            return Center(child: Text(state.message));
          } else {
            return SizedBox();
          }
        },
      ),
    );
  }
}
