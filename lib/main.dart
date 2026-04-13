import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'config/dependencies.dart';
import 'ui/app.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [...providersLocal, ...sharedProviders],
      child: const YoloApp(),
    ),
  );
}
