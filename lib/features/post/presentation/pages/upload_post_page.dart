import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/domain/entities/app_user.dart';
import 'package:social_media_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/post/domain/entities/post.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_states.dart';
import 'package:social_media_app/responsive/constrainded_scaffol.dart';

class UploadPostPage extends StatefulWidget {
  const UploadPostPage({super.key});

  @override
  State<UploadPostPage> createState() => _UploadPostPageState();
}

class _UploadPostPageState extends State<UploadPostPage> {
  // mobile image pick
  PlatformFile? imagePickedFile;

  // web image pick
  Uint8List? webImage;

  // text controller -> caption
  final textController = TextEditingController();

  // current User
  AppUser? currentUser;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getCurrentUser();
  }

  // get current user
  void getCurrentUser() async {
    final authCubit = context.read<AuthCubit>();
    currentUser = authCubit.currentUser;
  }

  // pick image
  Future<void> pickImage() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      withData: kIsWeb,
    );

    if (result != null) {
      setState(() {
        imagePickedFile = result.files.first;
        if (kIsWeb) {
          webImage = imagePickedFile!.bytes;
        }
      });
    }
  }

  // create and upload post
  void uploadPost() {
    // check if both image and caption are provided
    if (imagePickedFile == null || textController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Both image and caption are required.")),
      );
      return;
    }

    // create a new post object
    final newPost = Post(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      userId: currentUser!.uid,
      userName: currentUser!.name,
      text: textController.text,
      imageUrl: "",
      timestamp: DateTime.now(),
      likes: [],
      comments: [],
    );

    // post cubit
    final postCubit = context.read<PostCubit>();

    // web upload
    if (kIsWeb) {
      postCubit.createPost(newPost, imageBytes: imagePickedFile!.bytes);
    }
    // mobile upload
    else {
      postCubit.createPost(newPost, imagePath: imagePickedFile!.path);
    }
  }

  @override
  void dispose() {
    textController.dispose();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<PostCubit, PostState>(
      builder: (context, state) {
        print(state);
        // loading or uploading
        if (state is PostsLoading || state is PostsLoading) {
          return ConstraindedScaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        // build upload page
        return buildUploadPage();
      },
      // go to the previoud page when upload is done & posts are loaded
      listener: (context, state) {
        if (state is PostLoaded) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget buildUploadPage() {
    return ConstraindedScaffold(
      appBar: AppBar(
        title: Text("Create post"),
        foregroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        actions: [
          // upload button
          IconButton(onPressed: uploadPost, icon: Icon(Icons.upload)),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            // image preview for web
            if (kIsWeb && webImage != null) Image.memory(webImage!),

            // image preview for mobile
            if (!kIsWeb && imagePickedFile != null)
              Image.file(File(imagePickedFile!.path!)),

            // pick image button
            Center(
              child: MaterialButton(
                onPressed: pickImage,
                color: Colors.blue,
                child: Text("Pick Image"),
              ),
            ),

            // caption text box
            MyTextField(
              controller: textController,
              hintText: "Caption",
              obscureText: false,
            ),
          ],
        ),
      ),
    );
  }
}
