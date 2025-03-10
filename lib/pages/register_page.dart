import 'package:chat_app/components/chat_text.dart';
import 'package:chat_app/services/auth/auth_service.dart';
import 'package:chat_app/components/chat_button.dart';
import 'package:chat_app/components/chat_text_field.dart';
import 'package:flutter/material.dart';

class RegisterPage extends StatelessWidget {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  final void Function()? onLoginTap;

  RegisterPage({super.key, required this.onLoginTap});

  void register(BuildContext context) async {
    final authService = AuthService();

    if (_passwordController.text == _confirmPasswordController.text) {
      try {
        await authService.signUpWithEmailPassword(_nameController.text,
            _emailController.text, _passwordController.text);
      } catch (e) {
              print(e);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
      }
    } else {
      showDialog(
        context: context,
        builder: (context) => const AlertDialog(
          title: Text("Passwords don't match"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 60),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.person_add_alt_1,
                size: 80,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(height: 10),
              ChatText(
                text: "Create a new account",
                size: 25,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.tertiary,
              ),
              const SizedBox(height: 50),
              ChatTextField(
                controller: _nameController,
                hintText: 'Username',
                obscureText: false,
                padding: 0,
              ),
              const SizedBox(height: 20),
              ChatTextField(
                controller: _emailController,
                hintText: 'Email',
                obscureText: false,
                padding: 0,
              ),
              const SizedBox(height: 20),
              ChatTextField(
                controller: _passwordController,
                hintText: 'Password',
                obscureText: true,
                padding: 0,
              ),
              const SizedBox(height: 20),
              ChatTextField(
                controller: _confirmPasswordController,
                hintText: 'Confirm Password',
                obscureText: true,
                padding: 0,
              ),
              const SizedBox(height: 20),
              ChatButton(
                onTap: () => register(context),
                label: 'Register',
                padding: 15,
                margin: 0,
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ChatText(
                    text: 'Already have an account? ',
                    size: 15,
                    color: Theme.of(context).colorScheme.tertiary,
                  ),
                  GestureDetector(
                    onTap: onLoginTap,
                    child: ChatText(
                      text: ' Login',
                      size: 15,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.tertiary,
                    ),
                  ),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
