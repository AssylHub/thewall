/*

LOGIN PAGE:

On this page, an existing user can login with their:

 - email
 - password


-------------------------------------------------

Once the user successfully logs in, they will be redirected to home page.

If user doesn't have an account yet, they can go to register page from here to create one.


*/

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:social_media_app/features/auth/presentation/components/my_button.dart';
import 'package:social_media_app/features/auth/presentation/components/my_text_field.dart';
import 'package:social_media_app/features/auth/presentation/cubits/auth_cubit.dart';
import 'package:social_media_app/responsive/constrainded_scaffol.dart';

class LoginPage extends StatefulWidget {
  final void Function()? togglePages;
  const LoginPage({super.key, required this.togglePages});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  // text controllers
  final emailController = TextEditingController();
  final pwController = TextEditingController();

  // login button pressed
  void login() {
    // preare email pw
    final String email = emailController.text.trim();
    final String password = pwController.text.trim();

    // auth cubit
    final authCubit = context.read<AuthCubit>();

    // ensure that the email & pw field are filled
    if (email.isNotEmpty && password.isNotEmpty) {
      // login !
      authCubit.login(email, password);
    }
    // dispaly error if some fields are empty
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill both email and password!")),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    pwController.dispose();
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

              // welcome back msg
              Text(
                "Welcome back, you've been missed!",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 25),

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

              const SizedBox(height: 25),

              // login button
              MyButton(onTap: login, text: "Login"),

              const SizedBox(height: 50),

              // not have account yet? register now
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "Not a member?",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(width: 5),
                  GestureDetector(
                    onTap: widget.togglePages,
                    child: Text(
                      "Register now.",
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
    );
  }
}
