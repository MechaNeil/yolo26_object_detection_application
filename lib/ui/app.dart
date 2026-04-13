import 'package:flutter/material.dart';

import '../routing/router.dart';
import '../routing/routes.dart';

class YoloApp extends StatelessWidget {
  const YoloApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'YOLO MVVM Example',
      initialRoute: Routes.home,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
