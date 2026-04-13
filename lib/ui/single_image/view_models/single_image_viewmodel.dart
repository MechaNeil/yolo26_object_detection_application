import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../domain/models/inference/inference_models.dart';
import '../../../domain/use_cases/inference/load_single_image_model_use_case.dart';
import '../../../domain/use_cases/inference/run_single_image_inference_use_case.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class SingleImageViewModel extends ChangeNotifier {
  SingleImageViewModel({
    required LoadSingleImageModelUseCase loadSingleImageModelUseCase,
    required RunSingleImageInferenceUseCase runSingleImageInferenceUseCase,
    ImagePicker? imagePicker,
  }) : _loadSingleImageModelUseCase = loadSingleImageModelUseCase,
       _runSingleImageInferenceUseCase = runSingleImageInferenceUseCase,
       _imagePicker = imagePicker ?? ImagePicker() {
    loadModelCommand = Command0<void>(_loadModel)..execute();
    pickAndPredictCommand = Command0<void>(_pickAndPredict);
  }

  final LoadSingleImageModelUseCase _loadSingleImageModelUseCase;
  final RunSingleImageInferenceUseCase _runSingleImageInferenceUseCase;
  final ImagePicker _imagePicker;

  final ModelType _modelType = ModelType.segment;

  List<Map<String, dynamic>> _detections = <Map<String, dynamic>>[];
  Uint8List? _imageBytes;
  Uint8List? _annotatedImage;
  bool _isModelReady = false;
  bool _isModelLoading = false;
  String _statusMessage = Platform.isIOS
      ? 'Preparing local model...'
      : 'Model loading...';

  bool _isDisposed = false;

  late final Command0<void> loadModelCommand;
  late final Command0<void> pickAndPredictCommand;

  List<Map<String, dynamic>> get detections => _detections;
  Uint8List? get imageBytes => _imageBytes;
  Uint8List? get annotatedImage => _annotatedImage;
  bool get isModelReady => _isModelReady;
  bool get isModelLoading => _isModelLoading;
  String get statusMessage => _statusMessage;

  Future<Result<void>> _loadModel() async {
    if (_isDisposed) {
      return const Result.ok(null);
    }

    _isModelLoading = true;
    _isModelReady = false;
    _statusMessage = Platform.isIOS
        ? 'Preparing local model...'
        : 'Model loading...';
    _safeNotify();

    final result = await _loadSingleImageModelUseCase.execute(
      modelType: _modelType,
    );

    if (_isDisposed) {
      return const Result.ok(null);
    }

    switch (result) {
      case Ok<void>():
        _isModelLoading = false;
        _isModelReady = true;
        _statusMessage = 'Model ready';
        _safeNotify();
        return const Result.ok(null);
      case Error<void>():
        _isModelLoading = false;
        _isModelReady = false;
        _statusMessage = 'Failed to load model';
        _safeNotify();
        return Result.error(result.error);
    }
  }

  Future<Result<void>> _pickAndPredict() async {
    if (_isDisposed) {
      return const Result.ok(null);
    }

    if (!_isModelReady) {
      return Result.error(StateError('Model is loading, please wait...'));
    }

    final file = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (file == null) {
      return const Result.ok(null);
    }

    final bytes = await file.readAsBytes();
    _statusMessage = 'Running inference...';
    _safeNotify();

    final result = await _runSingleImageInferenceUseCase.execute(bytes);

    if (_isDisposed) {
      return const Result.ok(null);
    }

    switch (result) {
      case Ok():
        _detections = result.value.detections;
        _annotatedImage = result.value.annotatedImage;
        _imageBytes = result.value.sourceImage;
        _statusMessage = 'Inference complete';
        _safeNotify();
        return const Result.ok(null);
      case Error():
        _statusMessage = 'Inference failed';
        _safeNotify();
        return Result.error(result.error);
    }
  }

  void _safeNotify() {
    if (!_isDisposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
