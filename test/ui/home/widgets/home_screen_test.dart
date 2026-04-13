import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:yolo26_object_detection_application/ui/home/widgets/home_screen.dart';

void main() {
  testWidgets('renders navigation buttons', (WidgetTester tester) async {
    await tester.pumpWidget(const MaterialApp(home: HomeScreen()));

    expect(find.text('Choose an inference mode'), findsOneWidget);
    expect(find.text('Camera Inference'), findsOneWidget);
    expect(find.text('Single Image Inference'), findsOneWidget);
  });
}
