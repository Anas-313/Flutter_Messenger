import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/utils/routes/routes_name.dart';
import 'package:flutter_messenger/utils/utils.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/models/apis.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<UserCredential?> _signInWithGoogle() async {
    try {
      await InternetAddress.lookup('google.com');
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      // Once signed in, return the UserCredential
      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
      if (mounted) {
        Utils.toastMessage('something went wrong (No Internet)');
      }

      return null;
    }
  }

  handleGoogleBtnClick() {
    //FOR SHOWING PROGRESS BAR
    Utils.showProgressBar(context);

    _signInWithGoogle().then((user) async {
      //FOR HIDING PROGRESS BAR
      Navigator.pop(context);
      if (user != null) {
        if ((await APIs.userExits())) {
          if (mounted) {
            Navigator.pushReplacementNamed(context, RoutesName.home);
          }
        } else {
          await APIs.createUser().then((value) {
            Navigator.pushReplacementNamed(context, RoutesName.home);
          });
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          //APP LOGO
          Positioned(
            top: mq.height * 0.15,
            right: mq.width * 0.25,
            width: mq.width * 0.50,
            child: const Hero(
              tag: 'chat',
              child: Image(
                image: AssetImage('assets/images/whatsapp.png'),
                height: 200,
                width: 200,
              ),
            ),
          ),

          //GOOGLE LOGIN BUTTON
          Positioned(
            bottom: mq.height * 0.15,
            left: mq.width * 0.05,
            height: mq.height * 0.06,
            width: mq.width * 0.9,
            child: ElevatedButton.icon(
              style:
                  ElevatedButton.styleFrom(backgroundColor: Colors.teal[100]),
              onPressed: () {
                handleGoogleBtnClick();
              },
              icon: Image(
                image: const AssetImage('assets/images/google.png'),
                height: mq.height * 0.04,
              ),
              label: RichText(
                text: const TextSpan(
                  style: TextStyle(color: Colors.black, fontSize: 16),
                  children: [
                    TextSpan(text: ' Login in with '),
                    TextSpan(
                        text: 'Google',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
    );
  }
}
