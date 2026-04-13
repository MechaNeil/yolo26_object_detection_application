import '../../../data/repositories/inference/model_repository.dart';
import '../../../utils/result.dart';
import '../../models/inference/inference_models.dart';

class LoadModelUseCase {
  LoadModelUseCase({required ModelRepository modelRepository})
    : _modelRepository = modelRepository;

  final ModelRepository _modelRepository;

  Future<Result<String>> execute({
    required ModelType modelType,
    void Function(double progress)? onDownloadProgress,
    void Function(String message)? onStatusUpdate,
  }) {
    return _modelRepository.getModelPath(
      modelType: modelType,
      onDownloadProgress: onDownloadProgress,
      onStatusUpdate: onStatusUpdate,
    );
  }
}
