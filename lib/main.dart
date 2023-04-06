import 'package:avandra/screens/add_new_org.dart';
import 'package:avandra/screens/menu.dart';
import 'package:avandra/screens/navigation_page.dart';
import 'package:avandra/screens/select_map.dart';
import 'package:avandra/screens/sign_in.dart';
import 'package:avandra/screens/splash_page.dart';
import 'package:avandra/screens/user_pins.dart';
import 'package:avandra/screens/user_prof.dart';

import '../utils/colors.dart';
import '../screens/sign_up.dart';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';

Future<void> main() async {
  //This following will be uncommented when we add firebase, but it is here
  //for now

  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Avandra',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: splashpageColor,
      ),
      // home: SignUpScreen(),

      // home: SettingUI(),
      home: SplashScreen(),

      routes: {
        '/Login': (context) => const LoginScreen(title: ''),
        '/SignUp': (context) => const SignUpScreen(),
        '/Menu': (context) => const MenuScreen(),
        '/userProf': (context) => UserProfPage(),
        '/nav': (context) => const NavScreen(),
        '/selectMap': (context) => const SelectMapScreen(),
        '/addNewOrg': (context) => const AddNewOrgScreen(),
        '/pins': (context) => UserMarkersScreen(),
      },
    );
  }
}
