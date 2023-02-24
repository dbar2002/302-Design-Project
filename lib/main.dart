import 'package:avandra/screens/edit_profile.dart';

import '../utils/colors.dart';
import '../screens/sign_up.dart';
import '../screens/profile.dart';
import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  //This following will be uncommented when we add firebase, but it is here
  //for now

  /* WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
  */

  runApp(MyApp());
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

      home: SettingUI(),
      // home: ProfilePage(),
      /*routes: {
        '/SignUp': (context) => const SignUpScreen(),
        //'/home': (context) => const HomeScreen(),
        //etc.
        //etc.
      },
      */

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
