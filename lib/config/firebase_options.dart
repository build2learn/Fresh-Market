import 'package:firebase_core/firebase_core.dart';
import 'env_config.dart';

abstract final class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    return _optionsFor(EnvConfig.flavor);
  }

  static FirebaseOptions _optionsFor(Flavor flavor) {
    switch (flavor) {
      case Flavor.development:
        return _devOptions;
      case Flavor.staging:
        return _stagingOptions;
      case Flavor.production:
        return _prodOptions;
    }
  }

  static const FirebaseOptions _devOptions = FirebaseOptions(
    apiKey: 'dev-api-key',
    appId: 'dev-app-id',
    messagingSenderId: 'dev-sender-id',
    projectId: 'fresh-market-dev',
    authDomain: 'fresh-market-dev.firebaseapp.com',
    storageBucket: 'fresh-market-dev.appspot.com',
  );

  static const FirebaseOptions _stagingOptions = FirebaseOptions(
    apiKey: 'staging-api-key',
    appId: 'staging-app-id',
    messagingSenderId: 'staging-sender-id',
    projectId: 'fresh-market-staging',
    authDomain: 'fresh-market-staging.firebaseapp.com',
    storageBucket: 'fresh-market-staging.appspot.com',
  );

  static const FirebaseOptions _prodOptions = FirebaseOptions(
    apiKey: 'prod-api-key',
    appId: 'prod-app-id',
    messagingSenderId: 'prod-sender-id',
    projectId: 'fresh-market-prod',
    authDomain: 'fresh-market-prod.firebaseapp.com',
    storageBucket: 'fresh-market-prod.appspot.com',
  );
}
