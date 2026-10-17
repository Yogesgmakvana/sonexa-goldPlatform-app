import 'app/app.dart';
export 'app/app.dart';

import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var storageAvailable = false;
  try {
    await GetStorage.init();
    storageAvailable = true;
  } catch (error) {
    debugPrint(
      'Sonexa storage is unavailable; using an in-memory cache: $error',
    );
  }
  runApp(SonexaApp(storageAvailable: storageAvailable));
}
