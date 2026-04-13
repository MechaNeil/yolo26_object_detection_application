import 'package:flutter/material.dart';
import 'package:ultralytics_yolo/models/yolo_result.dart';
import 'package:ultralytics_yolo/utils/error_handler.dart';
import 'package:ultralytics_yolo/widgets/yolo_controller.dart';
import 'package:ultralytics_yolo/yolo_view.dart';

import '../../../domain/models/inference/inference_models.dart';
import '../../../domain/use_cases/inference/load_model_use_case.dart';
import '../../../utils/command.dart';
import '../../../utils/result.dart';

class CameraInferenceViewModel extends ChangeNotifier {
  CameraInferenceViewModel({required LoadModelUseCase loadModelUseCase})
    : _loadModelUseCase = loadModelUseCase {
    _isFrontCamera = _lensFacing == LensFacing.front;

    loadCommand = Command0<void>(_loadCurrentModel)..execute();
    changeModelCommand = Command1<ModelType, void>(_changeModel);

    _yoloController.setThresholds(
      confidenceThreshold: _confidenceThreshold,
      iouThreshold: _iouThreshold,
      numItemsThreshold: _numItemsThreshold,
    );
  }

  final LoadModelUseCase _loadModelUseCase;
  final YOLOViewController _yoloController = YOLOViewController();

  int _detectionCount = 0;
  double _currentFps = 0.0;
  int _frameCount = 0;
  DateTime _lastFpsUpdate = DateTime.now();

  double _confidenceThreshold = 0.5;
  double _iouThreshold = 0.45;
  int _numItemsThreshold = 30;
  SliderType _activeSlider = SliderType.none;

  ModelType _selectedModel = ModelType.detect;
  bool _isModelLoading = false;
  String? _modelPath;
  String _loadingMessage = '';
  double _downloadProgress = 0.0;

  double _currentZoomLevel = 1.0;
  LensFacing _lensFacing = LensFacing.front;
  bool _isFrontCamera = false;

  bool _isDisposed = false;

  late final Command0<void> loadCommand;
  late final Command1<ModelType, void> changeModelCommand;

  int get detectionCount => _detectionCount;
  double get currentFps => _currentFps;
  double get confidenceThreshold => _confidenceThreshold;
  double get iouThreshold => _iouThreshold;
  int get numItemsThreshold => _numItemsThreshold;
  SliderType get activeSlider => _activeSlider;
  ModelType get selectedModel => _selectedModel;
  bool get isModelLoading => _isModelLoading;
  String? get modelPath => _modelPath;
  String get loadingMessage => _loadingMessage;
  double get downloadProgress => _downloadProgress;
  double get currentZoomLevel => _currentZoomLevel;
  bool get isFrontCamera => _isFrontCamera;
  LensFacing get lensFacing => _lensFacing;
  YOLOViewController get yoloController => _yoloController;

  Future<Result<void>> _loadCurrentModel() async {
    if (_isDisposed) {
      return const Result.ok(null);
    }

    _isModelLoading = true;
    _loadingMessage = 'Loading ${_selectedModel.modelName} model...';
    _downloadProgress = 0.0;
    _detectionCount = 0;
    _currentFps = 0.0;
    _safeNotify();

    final modelPathResult = await _loadModelUseCase.execute(
      modelType: _selectedModel,
      onDownloadProgress: (progress) {
        _downloadProgress = progress;
        _safeNotify();
      },
      onStatusUpdate: (message) {
        _loadingMessage = message;
        _safeNotify();
      },
    );

    if (_isDisposed) {
      return const Result.ok(null);
    }

    switch (modelPathResult) {
      case Ok<String>():
        _modelPath = modelPathResult.value;
        _isModelLoading = false;
        _loadingMessage = '';
        _downloadProgress = 0.0;
        _safeNotify();
        return const Result.ok(null);
      case Error<String>():
        final handledError = YOLOErrorHandler.handleError(
          modelPathResult.error,
          'Failed to load model ${_selectedModel.modelName} for task ${_selectedModel.task.name}',
        );

        _isModelLoading = false;
        _loadingMessage = 'Failed to load model: ${handledError.message}';
        _downloadProgress = 0.0;
        _safeNotify();
        return Result.error(handledError);
    }
  }

  Future<Result<void>> _changeModel(ModelType model) async {
    if (_isDisposed || _isModelLoading || model == _selectedModel) {
      return const Result.ok(null);
    }

    _selectedModel = model;
    _safeNotify();
    return _loadCurrentModel();
  }

  void changeModelRequested(ModelType model) {
    changeModelCommand.execute(model);
  }

  void onDetectionResults(List<YOLOResult> results) {
    if (_isDisposed) {
      return;
    }

    _frameCount++;
    final now = DateTime.now();
    final elapsed = now.difference(_lastFpsUpdate).inMilliseconds;

    if (elapsed >= 1000) {
      _currentFps = _frameCount * 1000 / elapsed;
      _frameCount = 0;
      _lastFpsUpdate = now;
    }

    if (_detectionCount != results.length) {
      _detectionCount = results.length;
      _safeNotify();
    }
  }

  void onPerformanceMetrics(double fps) {
    if (_isDisposed) {
      return;
    }

    if ((_currentFps - fps).abs() > 0.1) {
      _currentFps = fps;
      _safeNotify();
    }
  }

  void onZoomChanged(double zoomLevel) {
    if (_isDisposed) {
      return;
    }

    if ((_currentZoomLevel - zoomLevel).abs() > 0.01) {
      _currentZoomLevel = zoomLevel;
      _safeNotify();
    }
  }

  void toggleSlider(SliderType type) {
    if (_isDisposed) {
      return;
    }

    _activeSlider = _activeSlider == type ? SliderType.none : type;
    _safeNotify();
  }

  void updateSliderValue(double value) {
    if (_isDisposed) {
      return;
    }

    var changed = false;
    switch (_activeSlider) {
      case SliderType.numItems:
        final newValue = value.toInt();
        if (_numItemsThreshold != newValue) {
          _numItemsThreshold = newValue;
          _yoloController.setNumItemsThreshold(_numItemsThreshold);
          changed = true;
        }
      case SliderType.confidence:
        if ((_confidenceThreshold - value).abs() > 0.01) {
          _confidenceThreshold = value;
          _yoloController.setConfidenceThreshold(value);
          changed = true;
        }
      case SliderType.iou:
        if ((_iouThreshold - value).abs() > 0.01) {
          _iouThreshold = value;
          _yoloController.setIoUThreshold(value);
          changed = true;
        }
      case SliderType.none:
        break;
    }

    if (changed) {
      _safeNotify();
    }
  }

  void setZoomLevel(double zoomLevel) {
    if (_isDisposed) {
      return;
    }

    if ((_currentZoomLevel - zoomLevel).abs() > 0.01) {
      _currentZoomLevel = zoomLevel;
      _yoloController.setZoomLevel(zoomLevel);
      _safeNotify();
    }
  }

  void flipCamera() {
    if (_isDisposed) {
      return;
    }

    _isFrontCamera = !_isFrontCamera;
    _lensFacing = _isFrontCamera ? LensFacing.front : LensFacing.back;
    if (_isFrontCamera) {
      _currentZoomLevel = 1.0;
    }
    _yoloController.switchCamera();
    _safeNotify();
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
