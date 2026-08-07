// File generated manually for project urplant-app.
// To auto-generate: run `flutterfire configure --project=urplant-app`

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCNxa0rLj3c5SJynx3qCjHJ1ErIiDaaUug',
    appId: '1:203351109777:web:e12b258409d3d982898f30',
    messagingSenderId: '203351109777',
    projectId: 'urplant-app',
    authDomain: 'urplant-app.firebaseapp.com',
    storageBucket: 'urplant-app.firebasestorage.app',
  );
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBIgPsy7Hwe1AfFt7IKW6yaSzqyNJ-KcHg',
    appId: '1:203351109777:android:cf9289a64207f799898f30',
    messagingSenderId: '203351109777',
    projectId: 'urplant-app',
    storageBucket: 'urplant-app.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDJjD3nNPh8xbTx-RiotWjgipVsvTkttw8',
    appId: '1:203351109777:ios:487946b3ca727f11898f30',
    messagingSenderId: '203351109777',
    projectId: 'urplant-app',
    storageBucket: 'urplant-app.firebasestorage.app',
    iosClientId: '203351109777-mb0359l92f9bgh5c6nc3jb12s0bm376b.apps.googleusercontent.com',
    iosBundleId: 'com.urplant.app',
  );
}
