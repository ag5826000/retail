import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shop_app/routes.dart';
import 'package:shop_app/screens/home/home_screen.dart';
import 'package:shop_app/screens/splash/splash_screen.dart';
import 'package:shop_app/screens/wrapper/wrapper.dart';
import 'package:shop_app/theme.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  User? user = FirebaseAuth.instance.currentUser;
  print(user);
  runApp(MyApp(isAuthenticated: user != null));
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  final bool isAuthenticated;
  MyApp({required this.isAuthenticated});
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'hisaaab.com',
      theme: AppTheme.lightTheme(context),
      initialRoute: isAuthenticated ? WrapperScreen.routeName : SplashScreen.routeName,
      routes: routes,
    );
  }
}
