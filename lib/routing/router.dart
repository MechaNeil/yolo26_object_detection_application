import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../domain/use_cases/inference/load_model_use_case.dart';
import '../domain/use_cases/inference/load_single_image_model_use_case.dart';
import '../domain/use_cases/inference/run_single_image_inference_use_case.dart';
import '../ui/camera_inference/view_models/camera_inference_viewmodel.dart';
import '../ui/camera_inference/widgets/camera_inference_screen.dart';
import '../ui/home/widgets/home_screen.dart';
import '../ui/single_image/view_models/single_image_viewmodel.dart';
import '../ui/single_image/widgets/single_image_screen.dart';
import 'routes.dart';

class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name ?? Routes.home) {
      case Routes.home:
        return MaterialPageRoute<void>(builder: (_) => const HomeScreen());
      case Routes.cameraInference:
        return MaterialPageRoute<void>(
          builder: (context) => CameraInferenceScreen(
            viewModel: CameraInferenceViewModel(
              loadModelUseCase: context.read<LoadModelUseCase>(),
            ),
          ),
        );
      case Routes.singleImage:
        return MaterialPageRoute<void>(
          builder: (context) => SingleImageScreen(
            viewModel: SingleImageViewModel(
              loadSingleImageModelUseCase: context
                  .read<LoadSingleImageModelUseCase>(),
              runSingleImageInferenceUseCase: context
                  .read<RunSingleImageInferenceUseCase>(),
            ),
          ),
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Route not found'))),
        );
    }
  }
}
