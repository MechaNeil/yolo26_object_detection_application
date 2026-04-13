import 'package:ultralytics_yolo/models/yolo_task.dart';

enum ModelType {
  detect('yolo11n', YOLOTask.detect),
  segment('yolo11n-seg', YOLOTask.segment),
  classify('yolo11n-cls', YOLOTask.classify),
  pose('yolo11n-pose', YOLOTask.pose),
  obb('yolo11n-obb', YOLOTask.obb);

  const ModelType(this.modelName, this.task);

  final String modelName;
  final YOLOTask task;
}

enum SliderType { none, numItems, confidence, iou }

class ThresholdConfig {
  const ThresholdConfig({
    this.confidenceThreshold = 0.5,
    this.iouThreshold = 0.45,
    this.numItemsThreshold = 30,
  });

  final double confidenceThreshold;
  final double iouThreshold;
  final int numItemsThreshold;

  ThresholdConfig copyWith({
    double? confidenceThreshold,
    double? iouThreshold,
    int? numItemsThreshold,
  }) {
    return ThresholdConfig(
      confidenceThreshold: confidenceThreshold ?? this.confidenceThreshold,
      iouThreshold: iouThreshold ?? this.iouThreshold,
      numItemsThreshold: numItemsThreshold ?? this.numItemsThreshold,
    );
  }
}
