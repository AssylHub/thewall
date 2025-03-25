import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/data/firebase_aurh_repo.dart';
import 'package:social_media_app/features/auth/presentation/components/show_message.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_states.dart';
import 'package:social_media_app/features/auth/presentation/pages/auth_page.dart';
import 'package:social_media_app/features/home/presentation/pages/home_page.dart';
import 'package:social_media_app/features/post/data/firebase_post_repo.dart';
import 'package:social_media_app/features/post/presentation/cubits/post_cubit.dart';
import 'package:social_media_app/features/profile/data/firebase_profile_repo.dart';
import 'package:social_media_app/features/profile/presentation/cubits/profile_cubit.dart';
import 'package:social_media_app/features/search/data/firebase_search_repo.dart';
import 'package:social_media_app/features/search/presentation/cubits/search_cubit.dart';
import 'package:social_media_app/features/storage/data/firebase_storage_repo.dart';
import 'package:social_media_app/themes/theme_cubit.dart';

/* 

APP - Root Level

----------------------------

Repositories: for the database 
 - firebase 

Bloc Providers: for state management 
 - auth
 - profile 
 - post 
 - search
 - theme


Check Auth State
 - unauthenticated -> auth page (login/register)
 - authenticated -> home page
*/
class MyApp extends StatelessWidget {
  // auth repo
  final firebaseAuthRepo = FirebaseAurhRepo();

  // profile repo
  final firebaseProfileRepo = FirebaseProfileRepo();

  // storage repo
  final firebaseStorageRepo = FirebaseStorageRepo();

  // post repo
  final firebasePostRepo = FirebasePostRepo();

  // search repo
  final firebaseSearchRepo = FirebaseSearchRepo();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // auth cubit
        BlocProvider<AuthCubit>(
          create:
              (context) => AuthCubit(authRepo: firebaseAuthRepo)..checkAuth(),
        ),

        // profile cubit
        BlocProvider<ProfileCubit>(
          create:
              (context) => ProfileCubit(
                profileRepo: firebaseProfileRepo,
                storageRepo: firebaseStorageRepo,
              ),
        ),

        // post cubit
        BlocProvider<PostCubit>(
          create:
              (context) => PostCubit(
                postRepo: firebasePostRepo,
                storageRepo: firebaseStorageRepo,
              ),
        ),

        // theme cubit
        BlocProvider<ThemeCubit>(create: (context) => ThemeCubit()),

        BlocProvider(
          create: (context) => SearchCubit(searchRepo: firebaseSearchRepo),
        ),
      ],
      // bloc builder: themes
      child: BlocBuilder<ThemeCubit, ThemeData>(
        builder: (context, curretnTheme) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            theme: curretnTheme,
            // bloc builder: check current auth state
            home: BlocConsumer<AuthCubit, AuthState>(
              builder: (context, authState) {
                print(authState);

                //   - unauthenticated -> auth page (login/register)
                if (authState is Unauthenticated) {
                  return AuthPage();
                }

                //  - authenticated -> home page
                if (authState is Authenticated) {
                  return HomePage();
                }
                // loading ..
                else {
                  return Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }
              },

              // listen for errors
              listener: (context, state) {
                if (state is AuthError) {
                  displayMessageToUser(state.message, context);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
