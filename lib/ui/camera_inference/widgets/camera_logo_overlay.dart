import 'package:flutter/material.dart';

import '../view_models/camera_inference_viewmodel.dart';

class CameraLogoOverlay extends StatelessWidget {
  const CameraLogoOverlay({
    super.key,
    required this.viewModel,
    required this.isLandscape,
  });

  final CameraInferenceViewModel viewModel;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    if (viewModel.modelPath == null || viewModel.isModelLoading) {
      return const SizedBox.shrink();
    }

    return Positioned.fill(
      child: IgnorePointer(
        child: Align(
          alignment: Alignment.center,
          child: FractionallySizedBox(
            widthFactor: isLandscape ? 0.3 : 0.5,
            heightFactor: isLandscape ? 0.3 : 0.5,
            child: Image.asset(
              'assets/logo.png',
              color: Colors.white.withValues(alpha: 0.4),
            ),
          ),
        ),
      ),
    );
  }
}
