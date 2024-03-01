import 'package:flutter/material.dart';
import 'package:flutter_messenger/data/models/apis.dart';
import 'package:flutter_messenger/utils/routes/routes_name.dart';
import 'package:flutter_messenger/view/auth/login_screen.dart';
import 'package:flutter_messenger/view/splash_screen.dart';

import '../../view/home_screen.dart';
import '../../view/profile_screen.dart';

class Routes {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case RoutesName.splash:
        return MaterialPageRoute(
            builder: (BuildContext context) => const SplashScreen());

      case RoutesName.login:
        return MaterialPageRoute(
            builder: (BuildContext context) => const LoginScreen());
      case RoutesName.home:
        return MaterialPageRoute(
            builder: (BuildContext context) => const HomeScreen());

      case RoutesName.profile:
        return MaterialPageRoute(
            builder: (BuildContext context) => ProfileScreen(user: APIs.me));

      default:
        return MaterialPageRoute(builder: (_) {
          return const Scaffold(body: Center(child: Text('No route defined')));
        });
    }
  }
}
