import 'package:yolo26_object_detection_application/data/repositories/inference/model_repository.dart';
import 'package:yolo26_object_detection_application/domain/models/inference/inference_models.dart';
import 'package:yolo26_object_detection_application/utils/result.dart';

class FakeModelRepository implements ModelRepository {
  FakeModelRepository({required Result<String> defaultResult})
    : _defaultResult = defaultResult;

  final Result<String> _defaultResult;
  final Map<ModelType, Result<String>> _overrides =
      <ModelType, Result<String>>{};

  void setResult(ModelType modelType, Result<String> result) {
    _overrides[modelType] = result;
  }

  @override
  Future<Result<String>> getModelPath({
    required ModelType modelType,
    void Function(double progress)? onDownloadProgress,
    void Function(String message)? onStatusUpdate,
  }) async {
    onStatusUpdate?.call('Loading ${modelType.modelName}...');
    onDownloadProgress?.call(1.0);
    return _overrides[modelType] ?? _defaultResult;
  }
}
