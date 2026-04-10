// lib/test_yolo.dart
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ultralytics_yolo/yolo.dart';

void main() {
  testWidgets('renders YOLO test button', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: TestYOLO(),
      ),
    );

    expect(find.text('YOLO Test'), findsOneWidget);
    expect(find.text('Test YOLO'), findsOneWidget);
  });
}

class TestYOLO extends StatelessWidget {
  const TestYOLO({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('YOLO Test')),
      body: Center(
        child: ElevatedButton(
          child: Text('Test YOLO'),
          onPressed: () async {
            try {
              final yolo = YOLO(
                modelPath: 'yolo26n_int8',
                task: YOLOTask.detect,
              );

              await yolo.loadModel();
              print('✅ YOLO loaded successfully!');

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('YOLO plugin working!')),
              );
            } catch (e) {
              print('❌ Error: $e');
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error: $e')),
              );
            }
          },
        ),
      ),
    );
  }
}