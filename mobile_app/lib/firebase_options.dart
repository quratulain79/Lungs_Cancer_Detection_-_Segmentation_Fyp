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
        return windows;
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
    apiKey: 'AIzaSyCNRH-V65-kUtVXzCAHdd_ukoTfbzLp87I',
    appId: '1:287225977822:web:1070580a5cf7bdce299b4f',
    messagingSenderId: '287225977822',
    projectId: 'lung-cancer-app-77aff',
    authDomain: 'lung-cancer-app-77aff.firebaseapp.com',
    storageBucket: 'lung-cancer-app-77aff.firebasestorage.app',
    measurementId: 'G-EE82JC3W5F',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB7IzeOJQ8SgUFK2CU6BXSISzS1NyYlPuk',
    appId: '1:287225977822:android:66f16fef625878f9299b4f',
    messagingSenderId: '287225977822',
    projectId: 'lung-cancer-app-77aff',
    storageBucket: 'lung-cancer-app-77aff.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXjy7VqEencYG0doFHDBkpQ6PBdEHlvlc',
    appId: '1:287225977822:ios:7f169ec64e6d55d3299b4f',
    messagingSenderId: '287225977822',
    projectId: 'lung-cancer-app-77aff',
    storageBucket: 'lung-cancer-app-77aff.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication2',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAXjy7VqEencYG0doFHDBkpQ6PBdEHlvlc',
    appId: '1:287225977822:ios:7f169ec64e6d55d3299b4f',
    messagingSenderId: '287225977822',
    projectId: 'lung-cancer-app-77aff',
    storageBucket: 'lung-cancer-app-77aff.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplication2',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCNRH-V65-kUtVXzCAHdd_ukoTfbzLp87I',
    appId: '1:287225977822:web:8010d9c4b0f4da04299b4f',
    messagingSenderId: '287225977822',
    projectId: 'lung-cancer-app-77aff',
    authDomain: 'lung-cancer-app-77aff.firebaseapp.com',
    storageBucket: 'lung-cancer-app-77aff.firebasestorage.app',
    measurementId: 'G-BKCC4Z270X',
  );
}
