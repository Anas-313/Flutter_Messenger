import 'package:flutter/material.dart';
import 'package:flutter_messenger/utils/colors.dart';
import 'package:flutter_messenger/utils/routes/routes_name.dart';

import '../data/models/apis.dart';
import '../main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, RoutesName.login);

      if (APIs.fAuth.currentUser != null) {
        // NAVIGATE TO HOME SCREEN
        Navigator.pushReplacementNamed(context, RoutesName.home);
      } else {
        // NAVIGATE TO LOGIN SCREEN
        Navigator.pushReplacementNamed(context, RoutesName.login);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // INITIALIZING MEDIA QUERY
    mq = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        children: [
          Positioned(
            top: mq.height * .30,
            right: mq.width * .25,
            width: mq.width * .5,
            child: const Hero(
              tag: 'chat',
              child: Image(
                image: AssetImage('assets/images/whatsapp.png'),
                height: 100,
                width: 100,
              ),
            ),
          ),
          Positioned(
            bottom: mq.height * .15,
            width: mq.width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  'from',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w300,
                    letterSpacing: .5,
                  ),
                ),
                SizedBox(height: mq.height * .01),
                const Text(
                  'Anas Patrawala',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 16,
                    letterSpacing: .5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
