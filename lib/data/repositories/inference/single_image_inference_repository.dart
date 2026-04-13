import 'dart:typed_data';

import '../../../domain/models/inference/inference_models.dart';
import '../../../domain/models/inference/single_image_prediction.dart';
import '../../../utils/result.dart';

abstract class SingleImageInferenceRepository {
  Future<Result<void>> loadModel({
    required String modelPath,
    required ModelType modelType,
  });

  Future<Result<SingleImagePrediction>> predict(Uint8List imageBytes);
}
