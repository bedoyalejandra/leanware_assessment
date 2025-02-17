import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyDEXk7bNvY_eBHaWbep9ItWO6e5R7ofxME',
    appId: '1:214026565751:web:5eef80b871335ba120ee72',
    messagingSenderId: '214026565751',
    projectId: 'leanware-assessment',
    authDomain: 'leanware-assessment.firebaseapp.com',
    storageBucket: 'leanware-assessment.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCIhv_tVZc43OhsQpdfSONaxt921fvZX94',
    appId: '1:214026565751:android:145ff2346fc0715e20ee72',
    messagingSenderId: '214026565751',
    projectId: 'leanware-assessment',
    storageBucket: 'leanware-assessment.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDb_YrBFQy8u2EDsatl1LEY39BqytXtar0',
    appId: '1:214026565751:ios:e013703a1136aada20ee72',
    messagingSenderId: '214026565751',
    projectId: 'leanware-assessment',
    storageBucket: 'leanware-assessment.firebasestorage.app',
    iosBundleId: 'com.example.leanwareAssessment',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyDb_YrBFQy8u2EDsatl1LEY39BqytXtar0',
    appId: '1:214026565751:ios:e013703a1136aada20ee72',
    messagingSenderId: '214026565751',
    projectId: 'leanware-assessment',
    storageBucket: 'leanware-assessment.firebasestorage.app',
    iosBundleId: 'com.example.leanwareAssessment',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDEXk7bNvY_eBHaWbep9ItWO6e5R7ofxME',
    appId: '1:214026565751:web:e2ee3712a4a57df320ee72',
    messagingSenderId: '214026565751',
    projectId: 'leanware-assessment',
    authDomain: 'leanware-assessment.firebaseapp.com',
    storageBucket: 'leanware-assessment.firebasestorage.app',
  );
}
