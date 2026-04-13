import 'dart:typed_data';

class SingleImagePrediction {
  const SingleImagePrediction({
    required this.sourceImage,
    required this.detections,
    required this.annotatedImage,
  });

  final Uint8List sourceImage;
  final List<Map<String, dynamic>> detections;
  final Uint8List? annotatedImage;
}
