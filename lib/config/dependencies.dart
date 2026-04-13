import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../data/repositories/inference/model_repository.dart';
import '../data/repositories/inference/model_repository_local.dart';
import '../data/repositories/inference/model_repository_remote.dart';
import '../data/repositories/inference/single_image_inference_repository.dart';
import '../data/repositories/inference/single_image_inference_repository_local.dart';
import '../data/repositories/inference/single_image_inference_repository_remote.dart';
import '../data/services/api/api_client.dart';
import '../data/services/local/model_local_service.dart';
import '../data/services/local/yolo_inference_local_service.dart';
import '../domain/use_cases/inference/load_model_use_case.dart';
import '../domain/use_cases/inference/load_single_image_model_use_case.dart';
import '../domain/use_cases/inference/run_single_image_inference_use_case.dart';

final List<SingleChildWidget> providersLocal = <SingleChildWidget>[
  Provider<ModelLocalService>(create: (_) => ModelLocalService()),
  Provider<YoloInferenceLocalService>(
    create: (_) => YoloInferenceLocalService(),
  ),
  Provider<ModelRepository>(
    create: (context) =>
        ModelRepositoryLocal(localService: context.read<ModelLocalService>()),
  ),
  Provider<SingleImageInferenceRepository>(
    create: (context) => SingleImageInferenceRepositoryLocal(
      inferenceService: context.read<YoloInferenceLocalService>(),
    ),
  ),
];

final List<SingleChildWidget> providersRemote = <SingleChildWidget>[
  Provider<ApiClient>(create: (_) => const ApiClient()),
  Provider<ModelLocalService>(create: (_) => ModelLocalService()),
  Provider<YoloInferenceLocalService>(
    create: (_) => YoloInferenceLocalService(),
  ),
  Provider<ModelRepositoryLocal>(
    create: (context) =>
        ModelRepositoryLocal(localService: context.read<ModelLocalService>()),
  ),
  Provider<SingleImageInferenceRepositoryLocal>(
    create: (context) => SingleImageInferenceRepositoryLocal(
      inferenceService: context.read<YoloInferenceLocalService>(),
    ),
  ),
  Provider<ModelRepository>(
    create: (context) => ModelRepositoryRemote(
      apiClient: context.read<ApiClient>(),
      fallbackRepository: context.read<ModelRepositoryLocal>(),
    ),
  ),
  Provider<SingleImageInferenceRepository>(
    create: (context) => SingleImageInferenceRepositoryRemote(
      apiClient: context.read<ApiClient>(),
      fallbackRepository: context.read<SingleImageInferenceRepositoryLocal>(),
    ),
  ),
];

final List<SingleChildWidget> sharedProviders = <SingleChildWidget>[
  Provider<LoadModelUseCase>(
    create: (context) =>
        LoadModelUseCase(modelRepository: context.read<ModelRepository>()),
  ),
  Provider<LoadSingleImageModelUseCase>(
    create: (context) => LoadSingleImageModelUseCase(
      loadModelUseCase: context.read<LoadModelUseCase>(),
      repository: context.read<SingleImageInferenceRepository>(),
    ),
  ),
  Provider<RunSingleImageInferenceUseCase>(
    create: (context) => RunSingleImageInferenceUseCase(
      repository: context.read<SingleImageInferenceRepository>(),
    ),
  ),
];
