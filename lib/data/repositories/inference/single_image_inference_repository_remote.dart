import 'dart:typed_data';

import '../../services/api/api_client.dart';
import '../../../domain/models/inference/inference_models.dart';
import '../../../domain/models/inference/single_image_prediction.dart';
import '../../../utils/result.dart';
import 'single_image_inference_repository.dart';

class SingleImageInferenceRepositoryRemote
    implements SingleImageInferenceRepository {
  SingleImageInferenceRepositoryRemote({
    required ApiClient apiClient,
    required SingleImageInferenceRepository fallbackRepository,
  }) : _apiClient = apiClient,
       _fallbackRepository = fallbackRepository;

  final ApiClient _apiClient;
  final SingleImageInferenceRepository _fallbackRepository;

  @override
  Future<Result<void>> loadModel({
    required String modelPath,
    required ModelType modelType,
  }) async {
    final _ = _apiClient;
    return _fallbackRepository.loadModel(
      modelPath: modelPath,
      modelType: modelType,
    );
  }

  @override
  Future<Result<SingleImagePrediction>> predict(Uint8List imageBytes) async {
    final _ = _apiClient;
    return _fallbackRepository.predict(imageBytes);
  }
}
