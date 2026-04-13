import 'package:flutter/material.dart';

import '../../../routing/routes.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YOLO Demo Home')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 12),
            const Text(
              'Choose an inference mode',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.cameraInference),
              icon: const Icon(Icons.videocam),
              label: const Text('Camera Inference'),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () =>
                  Navigator.of(context).pushNamed(Routes.singleImage),
              icon: const Icon(Icons.image),
              label: const Text('Single Image Inference'),
            ),
          ],
        ),
      ),
    );
  }
}
