import 'package:flutter/material.dart';

import '../view_models/single_image_viewmodel.dart';

class SingleImageScreen extends StatefulWidget {
  const SingleImageScreen({super.key, required this.viewModel});

  final SingleImageViewModel viewModel;

  @override
  State<SingleImageScreen> createState() => _SingleImageScreenState();
}

class _SingleImageScreenState extends State<SingleImageScreen> {
  late final SingleImageViewModel _viewModel;

  @override
  void initState() {
    super.initState();
    _viewModel = widget.viewModel;
    _viewModel.loadModelCommand.addListener(_onLoadModelChanged);
    _viewModel.pickAndPredictCommand.addListener(_onPickAndPredictChanged);
  }

  @override
  void dispose() {
    _viewModel.loadModelCommand.removeListener(_onLoadModelChanged);
    _viewModel.pickAndPredictCommand.removeListener(_onPickAndPredictChanged);
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Single Image Inference')),
      body: ListenableBuilder(
        listenable: _viewModel,
        builder: (context, child) {
          return Column(
            children: [
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _viewModel.pickAndPredictCommand.running
                    ? null
                    : () {
                        _viewModel.pickAndPredictCommand.execute();
                      },
                child: const Text('Pick Image & Run Inference'),
              ),
              const SizedBox(height: 10),
              if (_viewModel.isModelLoading || !_viewModel.isModelReady)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(width: 10),
                      Text(_viewModel.statusMessage),
                    ],
                  ),
                ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      if (_viewModel.annotatedImage != null ||
                          _viewModel.imageBytes != null)
                        SizedBox(
                          height: 300,
                          width: double.infinity,
                          child: Image.memory(
                            _viewModel.annotatedImage ?? _viewModel.imageBytes!,
                          ),
                        ),
                      const SizedBox(height: 10),
                      const Text('Detections:'),
                      Text(_viewModel.detections.toString()),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onLoadModelChanged() {
    if (!_viewModel.loadModelCommand.completed) {
      return;
    }

    final error = _viewModel.loadModelCommand.error;
    if (error != null && mounted) {
      _showSnackBar('Error loading model: $error');
    }

    _viewModel.loadModelCommand.clearResult();
  }

  void _onPickAndPredictChanged() {
    if (!_viewModel.pickAndPredictCommand.completed) {
      return;
    }

    final error = _viewModel.pickAndPredictCommand.error;
    if (error != null && mounted) {
      _showSnackBar(error.toString());
    }

    _viewModel.pickAndPredictCommand.clearResult();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }
}
