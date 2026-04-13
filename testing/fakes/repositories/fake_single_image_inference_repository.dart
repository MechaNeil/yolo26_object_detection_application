import 'dart:typed_data';

import 'package:yolo26_object_detection_application/data/repositories/inference/single_image_inference_repository.dart';
import 'package:yolo26_object_detection_application/domain/models/inference/inference_models.dart';
import 'package:yolo26_object_detection_application/domain/models/inference/single_image_prediction.dart';
import 'package:yolo26_object_detection_application/utils/result.dart';

class FakeSingleImageInferenceRepository
    implements SingleImageInferenceRepository {
  FakeSingleImageInferenceRepository({
    this.loadResult = const Result.ok(null),
    this.predictResult,
  });

  Result<void> loadResult;
  Result<SingleImagePrediction>? predictResult;

  @override
  Future<Result<void>> loadModel({
    required String modelPath,
    required ModelType modelType,
  }) async {
    return loadResult;
  }

  @override
  Future<Result<SingleImagePrediction>> predict(Uint8List imageBytes) async {
    return predictResult ??
        Result.ok(
          SingleImagePrediction(
            sourceImage: imageBytes,
            detections: <Map<String, dynamic>>[
              <String, dynamic>{'class': 'object', 'confidence': 0.9},
            ],
            annotatedImage: null,
          ),
        );
  }
}
