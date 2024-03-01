import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_messenger/utils/colors.dart';
import 'package:flutter_messenger/utils/routes/routes.dart';
import 'package:flutter_messenger/utils/routes/routes_name.dart';

import 'firebase_options.dart';

//GLOBAL OBJECT FOR ACCESSING SCREEN SIZE
late Size mq;
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Messenger',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: RoutesName.splash,
      onGenerateRoute: Routes.generateRoute,
    );
  }
}
