import '../../services/api/api_client.dart';
import '../../../domain/models/inference/inference_models.dart';
import '../../../utils/result.dart';
import 'model_repository.dart';

class ModelRepositoryRemote implements ModelRepository {
  ModelRepositoryRemote({
    required ApiClient apiClient,
    required ModelRepository fallbackRepository,
  }) : _apiClient = apiClient,
       _fallbackRepository = fallbackRepository;

  final ApiClient _apiClient;
  final ModelRepository _fallbackRepository;

  @override
  Future<Result<String>> getModelPath({
    required ModelType modelType,
    void Function(double progress)? onDownloadProgress,
    void Function(String message)? onStatusUpdate,
  }) async {
    // Placeholder for remote model negotiation.
    // Until a backend contract exists, mirror local behavior.
    final _ = _apiClient;
    return _fallbackRepository.getModelPath(
      modelType: modelType,
      onDownloadProgress: onDownloadProgress,
      onStatusUpdate: onStatusUpdate,
    );
  }
}
