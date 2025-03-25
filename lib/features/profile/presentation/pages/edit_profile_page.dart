import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media_app/features/profile/domain/entities/profile_user.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_states.dart';
import 'package:social_media_app/responsive/constrainded_scaffol.dart';

class EditProfilePage extends StatefulWidget {
  final ProfileUser user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // mobile image picker
  PlatformFile? imagePickedFile;

  // web image picker
  Uint8List? webImage;

  // bio text controller
  final bioTextController = TextEditingController();

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

  // update profile button pressed
  void updateProfile() {
    // profile cubit
    final profileCubit = context.read<ProfileCubit>();

    // prepare images & data
    final String uid = widget.user.uid;
    final String? newBio =
        bioTextController.text.isNotEmpty ? bioTextController.text : null;
    final imageMobilePath = kIsWeb ? null : imagePickedFile?.path;
    final imageWebBytes = kIsWeb ? imagePickedFile?.bytes : null;

    // only update profile if there is something to update
    if (imagePickedFile != null || newBio != null) {
      profileCubit.updateProfile(
        uid: uid,
        newBio: newBio,
        imageMobilePath: imageMobilePath,
        imageWebBytes: imageWebBytes,
      );
    }
    // noting to update -> go to prrevioud page
    else {
      Navigator.of(context).pop();
    }
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ProfileCubit, ProfileState>(
      builder: (context, state) {
        // profile loading..
        if (state is ProfileLoading) {
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator(), Text("Uploading...")],
              ),
            ),
          );
        } else {
          return buildEditPage();
        }

        // edit form
        // return buildEditPage();
      },
      listener: (context, state) {
        if (state is ProfileLoaded) {
          Navigator.of(context).pop();
        }
      },
    );
  }

  Widget buildEditPage() {
    return ConstraindedScaffold(
      appBar: AppBar(
        title: Text("Edit profile."),
        foregroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: updateProfile, icon: Icon(Icons.upload)),
        ],
      ),
      body: Column(
        children: [
          // profile picture
          Center(
            child: Container(
              width: 200,
              height: 200,
              clipBehavior: Clip.hardEdge,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary,
                shape: BoxShape.circle,
              ),
              child:
                  // display selected image for mobile
                  (!kIsWeb && imagePickedFile != null)
                      ? Image.file(
                        File(imagePickedFile!.path!),
                        fit: BoxFit.cover,
                      )
                      :
                      // display selected image for web
                      (kIsWeb && webImage != null)
                      ? Image.memory(webImage!)
                      :
                      // no image selected -> display existing profile pic
                      CachedNetworkImage(
                        imageUrl: widget.user.profileImageUrl,

                        // loading
                        placeholder:
                            (context, url) => CircularProgressIndicator(),

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
          ),

          SizedBox(height: 25),

          // pick image button
          Center(
            child: MaterialButton(
              onPressed: pickImage,
              color: Colors.blue,
              child: Text("Pick Image"),
            ),
          ),

          // bio
          Text("Bio"),

          const SizedBox(height: 15),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 25),
            child: MyTextField(
              controller: bioTextController,
              hintText: widget.user.bio,
              obscureText: false,
            ),
          ),
        ],
      ),
    );
  }
}
