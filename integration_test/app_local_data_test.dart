import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:provider/provider.dart';

import 'package:yolo26_object_detection_application/config/dependencies.dart';
import 'package:yolo26_object_detection_application/ui/app.dart';
import 'package:yolo26_object_detection_application/ui/home/widgets/home_screen.dart';
import 'package:yolo26_object_detection_application/ui/single_image/widgets/single_image_screen.dart';

/// Integration tests for the local app configuration.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('local integration test', () {
    testWidgets('loads home screen with local providers', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [...providersLocal, ...sharedProviders],
          child: const YoloApp(),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('YOLO Demo Home'), findsOneWidget);
      expect(find.text('Camera Inference'), findsOneWidget);
      expect(find.text('Single Image Inference'), findsOneWidget);
    });

    testWidgets('navigates to single image screen and back', (tester) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [...providersLocal, ...sharedProviders],
          child: const YoloApp(),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.text('Single Image Inference'));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(SingleImageScreen), findsOneWidget);
      expect(find.text('Pick Image & Run Inference'), findsOneWidget);
      expect(find.text('Detections:'), findsOneWidget);

      await tester.tap(find.byType(BackButton));
      await tester.pump(const Duration(milliseconds: 500));

      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.text('YOLO Demo Home'), findsOneWidget);
    });
  });
}
