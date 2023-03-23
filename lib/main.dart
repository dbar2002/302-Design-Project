
import 'package:avandra/screens/add_new_org.dart';
import 'package:avandra/screens/edit_profile.dart';
import 'package:avandra/screens/menu.dart';
import 'package:avandra/screens/select_map.dart';
import 'package:avandra/screens/sign_in.dart';
import 'package:avandra/screens/splash_page.dart';
import 'package:avandra/widgets/maps.dart';

import '../utils/colors.dart';
import '../screens/sign_up.dart';
import '../screens/profile.dart';

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
      //home: SplashScreen(),
      home: MenuScreen(), //MY MENU TEST
      //home: SignUpScreen(),

      routes: {
        '/Login': (context) => const LoginScreen(title: ''),
        '/SignUp': (context) => const SignUpScreen(),
        '/Menu': (context) => const MenuScreen(),
        '/profile': (context) => const ProfilePage(),
        '/selectMap': (context) => const SelectMapScreen(),
        '/map': (context) => const MenuScreen(),
        '/addNewOrg': (context) => const AddNewOrgScreen(),
      },
      

      //This is for persistent state, which we will need, but not quite yet
      //It also needs to be adjusted to allow for the splash page

      /*home: StreamBuilder(
        stream: AuthMethods().authChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasData) {
            return const HomeScreen();
          }

          return const LoginScreen();
        },
      ),*/
    );
  }
}

