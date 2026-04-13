import 'dart:typed_data';

import 'package:ultralytics_yolo/utils/map_converter.dart';

import '../../../domain/models/inference/inference_models.dart';
import '../../../domain/models/inference/single_image_prediction.dart';
import '../../../utils/result.dart';
import '../../services/local/yolo_inference_local_service.dart';
import 'single_image_inference_repository.dart';

class SingleImageInferenceRepositoryLocal
    implements SingleImageInferenceRepository {
  SingleImageInferenceRepositoryLocal({
    required YoloInferenceLocalService inferenceService,
  }) : _inferenceService = inferenceService;

  final YoloInferenceLocalService _inferenceService;

  @override
  Future<Result<void>> loadModel({
    required String modelPath,
    required ModelType modelType,
  }) async {
    try {
      await _inferenceService.loadModel(
        modelPath: modelPath,
        task: modelType.task,
      );
      return const Result.ok(null);
    } catch (error) {
      return Result.error(error);
    }
  }

  @override
  Future<Result<SingleImagePrediction>> predict(Uint8List imageBytes) async {
    try {
      final result = await _inferenceService.predict(imageBytes);

      final detections = result['boxes'] is List
          ? MapConverter.convertBoxesList(result['boxes'] as List)
          : <Map<String, dynamic>>[];

      return Result.ok(
        SingleImagePrediction(
          sourceImage: imageBytes,
          detections: detections,
          annotatedImage: result['annotatedImage'] as Uint8List?,
        ),
      );
    } catch (error) {
      return Result.error(error);
    }
  }
}
