import 'package:firebase_core/firebase_core.dart';
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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyAWH4-bsfxVCCGoGOIrynPWzH1x8fGgSUE',
    appId: '1:966845611968:web:562be9f1436670e56f5225',
    messagingSenderId: '966845611968',
    projectId: 'mytaskmanager-8c408',
    authDomain: 'mytaskmanager-8c408.firebaseapp.com',
    storageBucket: 'mytaskmanager-8c408.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAWH4-bsfxVCCGoGOIrynPWzH1x8fGgSUE',
    appId: '1:966845611968:android:CHANGE_THIS',
    messagingSenderId: '966845611968',
    projectId: 'mytaskmanager-8c408',
    storageBucket: 'mytaskmanager-8c408.firebasestorage.app',
  );
}
