import '../../../data/repositories/inference/single_image_inference_repository.dart';
import '../../../utils/result.dart';
import '../../models/inference/inference_models.dart';
import 'load_model_use_case.dart';

class LoadSingleImageModelUseCase {
  LoadSingleImageModelUseCase({
    required LoadModelUseCase loadModelUseCase,
    required SingleImageInferenceRepository repository,
  }) : _loadModelUseCase = loadModelUseCase,
       _repository = repository;

  final LoadModelUseCase _loadModelUseCase;
  final SingleImageInferenceRepository _repository;

  Future<Result<void>> execute({required ModelType modelType}) async {
    final modelPathResult = await _loadModelUseCase.execute(
      modelType: modelType,
    );

    switch (modelPathResult) {
      case Ok<String>():
        return _repository.loadModel(
          modelPath: modelPathResult.value,
          modelType: modelType,
        );
      case Error<String>():
        return Result.error(modelPathResult.error);
    }
  }
}
