import '../../../utils/result.dart';
import '../../../domain/models/inference/inference_models.dart';
import '../../services/local/model_local_service.dart';
import 'model_repository.dart';

class ModelRepositoryLocal implements ModelRepository {
  ModelRepositoryLocal({required ModelLocalService localService})
    : _localService = localService;

  final ModelLocalService _localService;

  @override
  Future<Result<String>> getModelPath({
    required ModelType modelType,
    void Function(double progress)? onDownloadProgress,
    void Function(String message)? onStatusUpdate,
  }) async {
    try {
      final modelPath = await _localService.getModelPath(
        modelType: modelType,
        onDownloadProgress: onDownloadProgress,
        onStatusUpdate: onStatusUpdate,
      );

      if (modelPath == null) {
        return Result.error(
          Exception('Failed to resolve ${modelType.modelName} model path.'),
        );
      }

      return Result.ok(modelPath);
    } catch (error) {
      return Result.error(error);
    }
  }
}
