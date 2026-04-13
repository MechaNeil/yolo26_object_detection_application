import '../../../domain/models/inference/inference_models.dart';
import '../../../utils/result.dart';

abstract class ModelRepository {
  Future<Result<String>> getModelPath({
    required ModelType modelType,
    void Function(double progress)? onDownloadProgress,
    void Function(String message)? onStatusUpdate,
  });
}
