import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:mob3_uas_klp_01/components/random_avatar.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/components/custom_snackbar.dart';

final firebaseAuth = FirebaseAuth.instance;
final googleSignIn = GoogleSignIn();

Future<void> signInWithGoogle({
  required BuildContext context,
  required ScaffoldMessengerState scaffoldMessenger,
  required Function(bool) setAuthenticating,
  required Function() updateUserProvider,
}) async {
  try {
    setAuthenticating(true);

    final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
    if (googleUser == null) {
      setAuthenticating(false);
      return; // The user canceled the sign-in
    }

    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;
    final AuthCredential credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final userCredential = await firebaseAuth.signInWithCredential(credential);

    // Check if the user already exists in Firestore
    final userDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (!userDoc.exists) {
      // Add the user to Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userCredential.user!.uid)
          .set(
        {
          'username': googleUser.displayName,
          'email': googleUser.email,
          'profile-pict': getRandomAvatar()
        },
      );
    }

    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      const CustomSnackBar(
          content: Text('Login Successful!'), color: Colors.green),
    );
  } on FirebaseAuthException catch (error) {
    scaffoldMessenger.clearSnackBars();
    scaffoldMessenger.showSnackBar(
      CustomSnackBar(
        color: Colors.red,
        content: Text(error.message ?? 'Authentication failed'),
      ),
    );
  } finally {
    setAuthenticating(false);
    updateUserProvider();
  }
}

Future<void> loginOrRegister({
  required BuildContext context,
  required ScaffoldMessengerState scaffoldMessenger,
  required bool isLogin,
  required String enteredEmail,
  required String enteredPassword,
  required String enteredUsername,
  required Function(bool) setAuthenticating,
  required Function(bool) setIsLogin,
  required Function() updateUserProvider,
  required bool rememberMe,
}) async {
  try {
    setAuthenticating(true);
    if (isLogin) {
      // Log user in
      if (firebaseAuth.currentUser != null) {
        scaffoldMessenger.clearSnackBars();
        scaffoldMessenger.showSnackBar(const CustomSnackBar(
            content: Text("User already logged in"), color: Colors.red));
      } else {
        await firebaseAuth.signInWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );

        scaffoldMessenger.clearSnackBars();
        scaffoldMessenger.showSnackBar(const CustomSnackBar(
          content: Text('Login Successful!'),
          color: Colors.green,
        ));
      }
    } else {
      // Sign user up
      if (firebaseAuth.currentUser != null) {
        scaffoldMessenger.clearSnackBars();
        scaffoldMessenger.showSnackBar(const CustomSnackBar(
            content: Text("User already logged in"), color: Colors.red));
      } else {
        final userCredential =
            await firebaseAuth.createUserWithEmailAndPassword(
          email: enteredEmail,
          password: enteredPassword,
        );

        await FirebaseFirestore.instance
            .collection('users')
            .doc(userCredential.user!.uid)
            .set(
          {
            'username': enteredUsername,
            'email': enteredEmail,
            'profile-pict': getRandomAvatar()
          },
        );

        // Sign out the user after registration
        await firebaseAuth.signOut();

        // Show a success message
        scaffoldMessenger.clearSnackBars();
        scaffoldMessenger.showSnackBar(
          const CustomSnackBar(
            content: Text('Account created successfully! Please log in.'),
            color: Colors.green,
          ),
        );

        // Delay to ensure the SnackBar is shown
        await Future.delayed(const Duration(seconds: 3));

        // Navigate back to the login screen
        setIsLogin(true);
      }
    }
  } on FirebaseAuthException catch (error) {
    scaffoldMessenger.clearSnackBars();
    if (error.code == 'email-already-in-use') {
      scaffoldMessenger.showSnackBar(
        const CustomSnackBar(
          color: Colors.red,
          content: Text('This email is already in use.'),
        ),
      );
    } else {
      scaffoldMessenger.showSnackBar(
        CustomSnackBar(
          color: Colors.red,
          content: Text(error.message ?? 'Authentication failed'),
        ),
      );
    }
  } finally {
    setAuthenticating(false);
    updateUserProvider();
    final prefs = await SharedPreferences.getInstance();
    if (rememberMe) {
      prefs.setBool('remember_me', true);
      prefs.setString('email', enteredEmail);
      prefs.setString('password', enteredPassword);
    } else {
      prefs.setBool('remember_me', false);
      prefs.remove('email');
      prefs.remove('password');
    }
  }
}

Future<Map<String, String>> loadCredentials() async {
  final prefs = await SharedPreferences.getInstance();
  final bool? rememberMe = prefs.getBool('remember_me');
  if (rememberMe == true) {
    final String? email = prefs.getString('email');
    final String? password = prefs.getString('password');
    return {'email': email!, 'password': password!};
  }
  return {'email': '', 'password': ''};
}
