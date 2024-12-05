import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:mob3_uas_klp_01/components/custom_elevated_btn.dart';
import 'package:mob3_uas_klp_01/components/custom_snackbar.dart';
import 'package:mob3_uas_klp_01/components/custom_textform.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future passwordReset(ScaffoldMessengerState scaffoldMessenger) async {
    try {
      await FirebaseAuth.instance
          .sendPasswordResetEmail(email: _emailController.text.trim());
      scaffoldMessenger.clearSnackBars();
      scaffoldMessenger.showSnackBar(const CustomSnackBar(
          content: Text("Password reset link sent! Please check your email."),
          color: Colors.green));
    } on FirebaseAuthException catch (e) {
      if (e.code == 'firebase_auth/invalid_email') {
        scaffoldMessenger.clearSnackBars();
        scaffoldMessenger.showSnackBar(const CustomSnackBar(
            content: Text("No account found with this email."),
            color: Colors.red));
      } else {
        scaffoldMessenger.clearSnackBars();
        scaffoldMessenger.showSnackBar(
            CustomSnackBar(content: Text(e.message!), color: Colors.red));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              icon: const Icon(Icons.subdirectory_arrow_left))
        ],
        leadingWidth: double.infinity,
        leading: Padding(
          padding: const EdgeInsets.only(left: 20),
          child: Row(
            children: [
              Image.asset(
                'assets/images/letter-p.png',
                height: 30,
              ),
              const SizedBox(width: 10),
              const Text(
                "PinjamDulu",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
              )
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 60),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Reset Your Password",
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 30),
              ),
              const SizedBox(height: 10),
              const Text("Enter the email address you used to register."),
              const SizedBox(height: 30),
              CustomTextFormField(
                labelText: "email address",
                controller: _emailController,
              ),
              const SizedBox(height: 20),
              CustomElevatedBtn(
                onPressed: () {
                  passwordReset(scaffoldMessenger);
                },
                child: const Text(
                  "Send Verification Email",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
