import 'package:flutter/material.dart';

import '../view_models/camera_inference_viewmodel.dart';
import 'camera_controls.dart';
import 'camera_inference_content.dart';
import 'camera_inference_overlay.dart';
import 'camera_logo_overlay.dart';
import 'threshold_slider.dart';

class CameraInferenceScreen extends StatefulWidget {
  const CameraInferenceScreen({super.key, required this.viewModel});

  final CameraInferenceViewModel viewModel;

  @override
  State<CameraInferenceScreen> createState() => _CameraInferenceScreenState();
}

class _CameraInferenceScreenState extends State<CameraInferenceScreen> {
  late final CameraInferenceViewModel _viewModel;
  var _rebuildKey = 0;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    _viewModel.loadCommand.addListener(_onLoadCommandChanged);
    _viewModel.changeModelCommand.addListener(_onChangeModelCommandChanged);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route?.isCurrent == true) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _rebuildKey++;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _viewModel.loadCommand.removeListener(_onLoadCommandChanged);
    _viewModel.changeModelCommand.removeListener(_onChangeModelCommandChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      appBar: AppBar(title: const Text('YOLO Camera Inference')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return Stack(
            children: [
              CameraInferenceContent(
                key: ValueKey('camera_content_$_rebuildKey'),
                viewModel: _viewModel,
                rebuildKey: _rebuildKey,
              ),
              CameraInferenceOverlay(
                viewModel: _viewModel,
                isLandscape: isLandscape,
              ),
              CameraLogoOverlay(
                viewModel: _viewModel,
                isLandscape: isLandscape,
              ),
              CameraControls(
                currentZoomLevel: _viewModel.currentZoomLevel,
                isFrontCamera: _viewModel.isFrontCamera,
                activeSlider: _viewModel.activeSlider,
                onZoomChanged: _viewModel.setZoomLevel,
                onSliderToggled: _viewModel.toggleSlider,
                onCameraFlipped: _viewModel.flipCamera,
                isLandscape: isLandscape,
              ),
              ThresholdSlider(
                activeSlider: _viewModel.activeSlider,
                confidenceThreshold: _viewModel.confidenceThreshold,
                iouThreshold: _viewModel.iouThreshold,
                numItemsThreshold: _viewModel.numItemsThreshold,
                onValueChanged: _viewModel.updateSliderValue,
                isLandscape: isLandscape,
              ),
            ],
          );
        },
      ),
    );
  }

  void _onLoadCommandChanged() {
    if (!_viewModel.loadCommand.completed) {
      return;
    }

    final error = _viewModel.loadCommand.error;
    if (error != null && mounted) {
      _showError('Model Loading Error', error.toString());
    }

    _viewModel.loadCommand.clearResult();
  }

  void _onChangeModelCommandChanged() {
    if (!_viewModel.changeModelCommand.completed) {
      return;
    }

    final error = _viewModel.changeModelCommand.error;
    if (error != null && mounted) {
      _showError('Model Switch Error', error.toString());
    }

    _viewModel.changeModelCommand.clearResult();
  }

  void _showError(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
