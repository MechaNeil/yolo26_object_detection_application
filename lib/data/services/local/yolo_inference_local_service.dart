import 'dart:typed_data';

import 'package:ultralytics_yolo/utils/map_converter.dart';
import 'package:ultralytics_yolo/yolo.dart';

class YoloInferenceLocalService {
  YOLO? _yolo;

  Future<void> loadModel({
    required String modelPath,
    required YOLOTask task,
  }) async {
    _yolo = YOLO(modelPath: modelPath, task: task);
    await _yolo!.loadModel();
  }

  Future<Map<String, dynamic>> predict(Uint8List imageBytes) async {
    final model = _yolo;
    if (model == null) {
      throw StateError('Model must be loaded before running inference.');
    }

    final rawResult = await model.predict(imageBytes);
    return MapConverter.convertToTypedMap(rawResult);
  }
}
