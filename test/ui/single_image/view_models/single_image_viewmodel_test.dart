import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:yolo26_object_detection_application/domain/use_cases/inference/load_model_use_case.dart';
import 'package:yolo26_object_detection_application/domain/use_cases/inference/load_single_image_model_use_case.dart';
import 'package:yolo26_object_detection_application/domain/use_cases/inference/run_single_image_inference_use_case.dart';
import 'package:yolo26_object_detection_application/ui/single_image/view_models/single_image_viewmodel.dart';
import 'package:yolo26_object_detection_application/utils/command.dart';
import 'package:yolo26_object_detection_application/utils/result.dart';

import '../../../../testing/fakes/repositories/fake_model_repository.dart';
import '../../../../testing/fakes/repositories/fake_single_image_inference_repository.dart';

class FakeImagePicker extends ImagePicker {
  FakeImagePicker(this._path, {this.returnNull = false});

  final String _path;
  final bool returnNull;

  @override
  Future<XFile?> pickImage({
    required ImageSource source,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
    CameraDevice preferredCameraDevice = CameraDevice.rear,
    bool requestFullMetadata = true,
  }) async {
    if (returnNull) {
      return null;
    }
    return XFile(_path);
  }
}

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

  test('loads model and runs prediction after image pick', () async {
    final tempDir = await Directory.systemTemp.createTemp('single_image_vm');
    final imageFile = File('${tempDir.path}/image.jpg');
    final imageBytes = Uint8List.fromList(<int>[1, 2, 3, 4]);
    await imageFile.writeAsBytes(imageBytes);

    final fakeModelRepository = FakeModelRepository(
      defaultResult: const Result.ok('assets/models/yolo11n-seg.tflite'),
    );
    final fakeSingleImageRepository = FakeSingleImageInferenceRepository();

    final viewModel = SingleImageViewModel(
      loadSingleImageModelUseCase: LoadSingleImageModelUseCase(
        loadModelUseCase: LoadModelUseCase(
          modelRepository: fakeModelRepository,
        ),
        repository: fakeSingleImageRepository,
      ),
      runSingleImageInferenceUseCase: RunSingleImageInferenceUseCase(
        repository: fakeSingleImageRepository,
      ),
      imagePicker: FakeImagePicker(imageFile.path),
    );

    await waitForCommand(viewModel.loadModelCommand);
    expect(viewModel.isModelReady, isTrue);

    viewModel.pickAndPredictCommand.execute();
    await waitForCommand(viewModel.pickAndPredictCommand);

    expect(viewModel.imageBytes, isNotNull);
    expect(viewModel.detections, isNotEmpty);
    expect(viewModel.pickAndPredictCommand.error, isNull);

    viewModel.dispose();
  });

  test('returns error when model fails to load', () async {
    final fakeModelRepository = FakeModelRepository(
      defaultResult: Result.error(Exception('Model load failed')),
    );
    final fakeSingleImageRepository = FakeSingleImageInferenceRepository();

    final viewModel = SingleImageViewModel(
      loadSingleImageModelUseCase: LoadSingleImageModelUseCase(
        loadModelUseCase: LoadModelUseCase(
          modelRepository: fakeModelRepository,
        ),
        repository: fakeSingleImageRepository,
      ),
      runSingleImageInferenceUseCase: RunSingleImageInferenceUseCase(
        repository: fakeSingleImageRepository,
      ),
      imagePicker: FakeImagePicker('', returnNull: true),
    );

    await waitForCommand(viewModel.loadModelCommand);

    expect(viewModel.isModelReady, isFalse);
    expect(viewModel.loadModelCommand.error, isNotNull);

    viewModel.dispose();
  });
}
