import 'package:flutter_test/flutter_test.dart';
import 'package:yolo26_object_detection_application/domain/models/inference/inference_models.dart';
import 'package:yolo26_object_detection_application/domain/use_cases/inference/load_model_use_case.dart';
import 'package:yolo26_object_detection_application/ui/camera_inference/view_models/camera_inference_viewmodel.dart';
import 'package:yolo26_object_detection_application/utils/command.dart';
import 'package:yolo26_object_detection_application/utils/result.dart';

import '../../../../testing/fakes/repositories/fake_model_repository.dart';

void main() {
  Future<void> waitForCommand(Command0<void> command) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!command.completed) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for command completion.');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  Future<void> waitForCommand1(Command1<ModelType, void> command) async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!command.completed) {
      if (DateTime.now().isAfter(deadline)) {
        fail('Timed out waiting for command completion.');
      }
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
  }

  test('loads model on startup command', () async {
    final fakeRepository = FakeModelRepository(
      defaultResult: const Result.ok('assets/models/yolo11n.tflite'),
    );
    final viewModel = CameraInferenceViewModel(
      loadModelUseCase: LoadModelUseCase(modelRepository: fakeRepository),
    );

    await waitForCommand(viewModel.loadCommand);

    expect(viewModel.modelPath, 'assets/models/yolo11n.tflite');
    expect(viewModel.isModelLoading, isFalse);
    expect(viewModel.loadCommand.error, isNull);

    viewModel.dispose();
  });

  test('changes model and reloads', () async {
    final fakeRepository = FakeModelRepository(
      defaultResult: const Result.ok('assets/models/yolo11n.tflite'),
    );
    fakeRepository.setResult(
      ModelType.segment,
      const Result.ok('assets/models/yolo11n-seg.tflite'),
    );

    final viewModel = CameraInferenceViewModel(
      loadModelUseCase: LoadModelUseCase(modelRepository: fakeRepository),
    );

    await waitForCommand(viewModel.loadCommand);
    viewModel.loadCommand.clearResult();

    viewModel.changeModelRequested(ModelType.segment);
    await waitForCommand1(viewModel.changeModelCommand);

    expect(viewModel.selectedModel, ModelType.segment);
    expect(viewModel.modelPath, 'assets/models/yolo11n-seg.tflite');
    expect(viewModel.changeModelCommand.error, isNull);

    viewModel.dispose();
  });
}
