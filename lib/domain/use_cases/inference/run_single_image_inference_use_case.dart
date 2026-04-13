import 'dart:typed_data';

import '../../../data/repositories/inference/single_image_inference_repository.dart';
import '../../../utils/result.dart';
import '../../models/inference/single_image_prediction.dart';

class RunSingleImageInferenceUseCase {
  RunSingleImageInferenceUseCase({
    required SingleImageInferenceRepository repository,
  }) : _repository = repository;

  final SingleImageInferenceRepository _repository;

  Future<Result<SingleImagePrediction>> execute(Uint8List imageBytes) {
    return _repository.predict(imageBytes);
  }
}
