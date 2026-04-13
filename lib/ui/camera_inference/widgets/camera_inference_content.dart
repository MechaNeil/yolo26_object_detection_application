import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/yolo_streaming_config.dart';
import 'package:ultralytics_yolo/yolo_view.dart';

import '../view_models/camera_inference_viewmodel.dart';
import 'model_loading_overlay.dart';

class CameraInferenceContent extends StatelessWidget {
  const CameraInferenceContent({
    super.key,
    required this.viewModel,
    this.rebuildKey = 0,
  });

  final CameraInferenceViewModel viewModel;
  final int rebuildKey;

  @override
  Widget build(BuildContext context) {
    if (viewModel.modelPath != null && !viewModel.isModelLoading) {
      return YOLOView(
        key: ValueKey(
          'yolo_view_${viewModel.modelPath}_${viewModel.selectedModel.task.name}_$rebuildKey',
        ),
        controller: viewModel.yoloController,
        modelPath: viewModel.modelPath!,
        task: viewModel.selectedModel.task,
        streamingConfig: const YOLOStreamingConfig.minimal(),
        onResult: viewModel.onDetectionResults,
        onPerformanceMetrics: (metrics) =>
            viewModel.onPerformanceMetrics(metrics.fps),
        onZoomChanged: viewModel.onZoomChanged,
        lensFacing: viewModel.lensFacing,
      );
    }

    if (viewModel.isModelLoading) {
      return ModelLoadingOverlay(
        loadingMessage: viewModel.loadingMessage,
        downloadProgress: viewModel.downloadProgress,
      );
    }

    return const Center(
      child: Text('No model loaded', style: TextStyle(color: Colors.white)),
    );
  }
}
