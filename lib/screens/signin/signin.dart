import '/authmanagement/auth_manage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_signin_button/flutter_signin_button.dart';

class SigninScreen extends StatefulWidget {
  const SigninScreen({super.key});

  @override
  State<SigninScreen> createState() => _SigninScreenState();
}

class _SigninScreenState extends State<SigninScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          children: [
            SizedBox(
              height: 350,
              child: Image.asset("assets/images/login.png"),
            ),
            Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Text(
                  "  Welcome to \nKumar Brooms",
                  style: TextStyle(fontSize: 25),
                ),
              ),
            ),
            SizedBox(height: 30),
            // Google Sign-In Button
            buildCustomButton(),
          ],
        ),
      ),
    );
  }

  Widget buildCustomButton() {
    return Padding(
      padding: const EdgeInsets.only(left: 50, right: 50),
      child: SizedBox(
        height: 60,
        child: SignInButton(
          Buttons.Google,
          mini: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          onPressed: () async {
            try {
              await AuthManage().LoginWithGoogle();
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  backgroundColor: Colors.red,
                  content: Text(
                    "Google Sign-In failed: ${e.toString()}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
