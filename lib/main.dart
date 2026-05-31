import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'config/env_config.dart';
import 'data/datasources/local/auth_local_datasource.dart';
import 'data/datasources/local/product_local_datasource.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  EnvConfig.init(Flavor.development);

  await Firebase.initializeApp();
  await AuthLocalDataSourceImpl.init();
  await ProductLocalDataSourceImpl.init();

  runApp(
    const ProviderScope(
      child: FreshMarketApp(),
    ),
  );
}
