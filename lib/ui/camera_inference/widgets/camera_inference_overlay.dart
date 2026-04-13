import 'package:flutter/material.dart';

import '../../../domain/models/inference/inference_models.dart';
import '../view_models/camera_inference_viewmodel.dart';
import 'detection_stats_display.dart';
import 'model_selector.dart';
import 'threshold_pill.dart';

class CameraInferenceOverlay extends StatelessWidget {
  const CameraInferenceOverlay({
    super.key,
    required this.viewModel,
    required this.isLandscape,
  });

  final CameraInferenceViewModel viewModel;
  final bool isLandscape;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + (isLandscape ? 8 : 16),
      left: isLandscape ? 8 : 16,
      right: isLandscape ? 8 : 16,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          ModelSelector(
            selectedModel: viewModel.selectedModel,
            isModelLoading: viewModel.isModelLoading,
            onModelChanged: viewModel.changeModelRequested,
          ),
          SizedBox(height: isLandscape ? 8 : 12),
          DetectionStatsDisplay(
            detectionCount: viewModel.detectionCount,
            currentFps: viewModel.currentFps,
          ),
          const SizedBox(height: 8),
          _buildThresholdPills(),
        ],
      ),
    );
  }

  Widget _buildThresholdPills() {
    if (viewModel.activeSlider == SliderType.confidence) {
      return ThresholdPill(
        label:
            'CONFIDENCE THRESHOLD: ${viewModel.confidenceThreshold.toStringAsFixed(2)}',
      );
    }

    if (viewModel.activeSlider == SliderType.iou) {
      return ThresholdPill(
        label: 'IOU THRESHOLD: ${viewModel.iouThreshold.toStringAsFixed(2)}',
      );
    }

    if (viewModel.activeSlider == SliderType.numItems) {
      return ThresholdPill(label: 'ITEMS MAX: ${viewModel.numItemsThreshold}');
    }

    return const SizedBox.shrink();
  }
}
