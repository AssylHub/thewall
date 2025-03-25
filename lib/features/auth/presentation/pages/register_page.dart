import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/components/my_button.dart';
import 'package:social_media_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media_app/features/auth/presentation/components/show_message.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/responsive/constrainded_scaffol.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? togglePages;
  const RegisterPage({super.key, required this.togglePages});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  // text controller
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final pwController = TextEditingController();
  final confirmPwController = TextEditingController();

  // register button pressed
  void register() {
    // prepare info
    final String username = nameController.text.trim();
    final String email = emailController.text.trim();
    final String password = pwController.text.trim();
    final String confirmPassword = confirmPwController.text.trim();

    // auth cubit
    final authCubit = context.read<AuthCubit>();

    // ensure that field are not empty
    if (email.isNotEmpty &&
        username.isNotEmpty &&
        password.isNotEmpty &&
        confirmPassword.isNotEmpty) {
      // ensure passwords match
      if (password == confirmPassword) {
        // do something
        authCubit.register(username, email, password);
      }
      // passwords do not match
      else {
        displayMessageToUser("Passwords do not match!", context);
      }
    }
    // fields are empty -> display error
    else {
      displayMessageToUser("Please complete all the fields.", context);
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    nameController.dispose();
    pwController.dispose();
    confirmPwController.dispose();
    super.dispose();
  }

  // BUILD UI
  @override
  Widget build(BuildContext context) {
    // SCAFFOLD
    return ConstraindedScaffold(
      // BODY
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // logo
                Icon(
                  Icons.lock_open_rounded,
                  size: 80,
                  color: Theme.of(context).colorScheme.primary,
                ),

                const SizedBox(height: 50),

                // create account message
                Text(
                  "Let's create an account for you.",
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.primary,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                // name texfield
                MyTextField(
                  controller: nameController,
                  hintText: "Username",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // email texfield
                MyTextField(
                  controller: emailController,
                  hintText: "Email",
                  obscureText: false,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: pwController,
                  hintText: "Password",
                  obscureText: true,
                ),

                const SizedBox(height: 10),

                // password textfield
                MyTextField(
                  controller: confirmPwController,
                  hintText: "Confirm password",
                  obscureText: true,
                ),

                const SizedBox(height: 25),

                // login button
                MyButton(onTap: register, text: "Register"),

                const SizedBox(height: 50),

                // already have account yet? login now
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "Already member?",
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 5),
                    GestureDetector(
                      onTap: widget.togglePages,
                      child: Text(
                        "Login now.",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.inversePrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
