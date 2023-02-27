// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAB3CezSTFXnJlQoCl8i8tNgKxzjEMmYv0',
    appId: '1:53447629858:web:1fec0bf090a9bc82567e7b',
    messagingSenderId: '53447629858',
    projectId: 'avandra2023',
    authDomain: 'avandra2023.firebaseapp.com',
    storageBucket: 'avandra2023.appspot.com',
    measurementId: 'G-0PG6MMKZW0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBP1SKb2ocDhsZTycw18RXtvQBEDs176C4',
    appId: '1:53447629858:android:a89c3ad0c728382b567e7b',
    messagingSenderId: '53447629858',
    projectId: 'avandra2023',
    storageBucket: 'avandra2023.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAC2o_33YwfY8-Ix3OtD_v-Clxyq-uAFQM',
    appId: '1:53447629858:ios:8b40a1a02a7ad99c567e7b',
    messagingSenderId: '53447629858',
    projectId: 'avandra2023',
    storageBucket: 'avandra2023.appspot.com',
    androidClientId: '53447629858-jjqvdoqttq4d3fik7n0dlu893oklsri3.apps.googleusercontent.com',
    iosClientId: '53447629858-s64futdc1r552lamrsn1pd391tr449a1.apps.googleusercontent.com',
    iosBundleId: 'com.example.avandra',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAC2o_33YwfY8-Ix3OtD_v-Clxyq-uAFQM',
    appId: '1:53447629858:ios:8b40a1a02a7ad99c567e7b',
    messagingSenderId: '53447629858',
    projectId: 'avandra2023',
    storageBucket: 'avandra2023.appspot.com',
    androidClientId: '53447629858-jjqvdoqttq4d3fik7n0dlu893oklsri3.apps.googleusercontent.com',
    iosClientId: '53447629858-s64futdc1r552lamrsn1pd391tr449a1.apps.googleusercontent.com',
    iosBundleId: 'com.example.avandra',
  );
}