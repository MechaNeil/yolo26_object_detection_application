import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:ultralytics_yolo/config/channel_config.dart';
import 'package:ultralytics_yolo/utils/map_converter.dart';

import '../../../domain/models/inference/inference_models.dart';

class ModelLocalService {
  static const String _modelDownloadBaseUrl =
      'https://github.com/ultralytics/yolo-flutter-app/releases/download/v0.0.0';

  static final MethodChannel _channel =
      ChannelConfig.createSingleImageChannel();

  Future<String?> getModelPath({
    required ModelType modelType,
    void Function(double progress)? onDownloadProgress,
    void Function(String message)? onStatusUpdate,
  }) async {
    return Platform.isIOS
        ? _getIOSModelPath(
            modelType: modelType,
            onDownloadProgress: onDownloadProgress,
            onStatusUpdate: onStatusUpdate,
          )
        : Platform.isAndroid
        ? _getAndroidModelPath(
            modelType: modelType,
            onDownloadProgress: onDownloadProgress,
            onStatusUpdate: onStatusUpdate,
          )
        : null;
  }

  Future<String?> _getIOSModelPath({
    required ModelType modelType,
    void Function(double progress)? onDownloadProgress,
    void Function(String message)? onStatusUpdate,
  }) async {
    _updateStatus(
      message: 'Checking for ${modelType.modelName} model...',
      onStatusUpdate: onStatusUpdate,
    );

    try {
      final bundleCheck = await _checkModelExistsInBundle(modelType.modelName);
      if (bundleCheck['exists'] == true) {
        return modelType.modelName;
      }
    } catch (_) {}

    final dir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${dir.path}/${modelType.modelName}.mlpackage');
    if (await modelDir.exists()) {
      if (await File('${modelDir.path}/Manifest.json').exists()) {
        return modelDir.path;
      }
      await modelDir.delete(recursive: true);
    }

    _updateStatus(
      message: 'Downloading ${modelType.modelName} model...',
      onStatusUpdate: onStatusUpdate,
    );

    return _downloadIOSModel(
      modelType: modelType,
      onDownloadProgress: onDownloadProgress,
      onStatusUpdate: onStatusUpdate,
    );
  }

  Future<Map<String, dynamic>> _checkModelExistsInBundle(
    String modelName,
  ) async {
    if (!Platform.isIOS) {
      return {'exists': false};
    }

    try {
      final result = await _channel.invokeMethod('checkModelExists', {
        'modelPath': modelName,
      });
      return MapConverter.convertToTypedMap(result);
    } catch (_) {
      return {'exists': false};
    }
  }

  Future<String?> _downloadIOSModel({
    required ModelType modelType,
    void Function(double progress)? onDownloadProgress,
    void Function(String message)? onStatusUpdate,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final modelDir = Directory('${dir.path}/${modelType.modelName}.mlpackage');
    if (await modelDir.exists()) {
      return modelDir.path;
    }

    try {
      final zipData = await rootBundle.load(
        'assets/models/${modelType.modelName}.mlpackage.zip',
      );
      return _extractZip(
        bytes: zipData.buffer.asUint8List(),
        targetDir: modelDir,
        onStatusUpdate: onStatusUpdate,
      );
    } catch (_) {}

    return _downloadAndExtract(
      modelType: modelType,
      targetDir: modelDir,
      extension: '.mlpackage.zip',
      onDownloadProgress: onDownloadProgress,
      onStatusUpdate: onStatusUpdate,
    );
  }

  Future<String?> _getAndroidModelPath({
    required ModelType modelType,
    void Function(double progress)? onDownloadProgress,
    void Function(String message)? onStatusUpdate,
  }) async {
    _updateStatus(
      message: 'Checking for ${modelType.modelName} model...',
      onStatusUpdate: onStatusUpdate,
    );

    final bundledName = '${modelType.modelName}.tflite';
    try {
      final result = await _channel.invokeMethod('checkModelExists', {
        'modelPath': bundledName,
      });
      if (result != null && result['exists'] == true) {
        return result['location'] == 'assets'
            ? bundledName
            : result['path'] as String;
      }
    } catch (_) {}

    final dir = await getApplicationDocumentsDirectory();
    final modelFile = File('${dir.path}/$bundledName');
    if (await modelFile.exists()) {
      return modelFile.path;
    }

    _updateStatus(
      message: 'Downloading ${modelType.modelName} model...',
      onStatusUpdate: onStatusUpdate,
    );

    final bytes = await _downloadFile(
      url: '$_modelDownloadBaseUrl/$bundledName',
      onDownloadProgress: onDownloadProgress,
    );

    if (bytes != null && bytes.isNotEmpty) {
      await modelFile.writeAsBytes(bytes);
      return modelFile.path;
    }

    return null;
  }

  Future<List<int>?> _downloadFile({
    required String url,
    void Function(double progress)? onDownloadProgress,
  }) async {
    try {
      final client = http.Client();
      final request = await client.send(http.Request('GET', Uri.parse(url)));
      final contentLength = request.contentLength ?? 0;
      final bytes = <int>[];
      var downloadedBytes = 0;

      await for (final chunk in request.stream) {
        bytes.addAll(chunk);
        downloadedBytes += chunk.length;
        if (contentLength > 0) {
          onDownloadProgress?.call(downloadedBytes / contentLength);
        }
      }

      client.close();
      return bytes;
    } catch (_) {
      return null;
    }
  }

  Future<String?> _extractZip({
    required List<int> bytes,
    required Directory targetDir,
    void Function(String message)? onStatusUpdate,
  }) async {
    try {
      _updateStatus(
        message: 'Extracting model...',
        onStatusUpdate: onStatusUpdate,
      );

      final archive = ZipDecoder().decodeBytes(bytes);
      await targetDir.create(recursive: true);
      String? prefix;

      if (archive.files.isNotEmpty) {
        final first = archive.files.first.name;
        if (first.contains('/') &&
            first.split('/').first.endsWith('.mlpackage')) {
          final topDir = first.split('/').first;
          if (archive.files.every(
            (file) => file.name.startsWith('$topDir/') || file.name == topDir,
          )) {
            prefix = '$topDir/';
          }
        }
      }

      for (final file in archive) {
        var filename = file.name;
        if (prefix != null) {
          if (filename.startsWith(prefix)) {
            filename = filename.substring(prefix.length);
          } else if (filename == prefix.replaceAll('/', '')) {
            continue;
          }
        }

        if (filename.isEmpty) {
          continue;
        }

        if (file.isFile) {
          final outputFile = File('${targetDir.path}/$filename');
          await outputFile.parent.create(recursive: true);
          await outputFile.writeAsBytes(file.content as List<int>);
        }
      }

      return targetDir.path;
    } catch (_) {
      if (await targetDir.exists()) {
        await targetDir.delete(recursive: true);
      }
      return null;
    }
  }

  Future<String?> _downloadAndExtract({
    required ModelType modelType,
    required Directory targetDir,
    required String extension,
    void Function(double progress)? onDownloadProgress,
    void Function(String message)? onStatusUpdate,
  }) async {
    final bytes = await _downloadFile(
      url: '$_modelDownloadBaseUrl/${modelType.modelName}$extension',
      onDownloadProgress: onDownloadProgress,
    );

    if (bytes == null) {
      return null;
    }

    return extension.contains('zip')
        ? _extractZip(
            bytes: bytes,
            targetDir: targetDir,
            onStatusUpdate: onStatusUpdate,
          )
        : (await File(targetDir.path).writeAsBytes(bytes), targetDir.path).$2;
  }

  void _updateStatus({
    required String message,
    void Function(String message)? onStatusUpdate,
  }) {
    onStatusUpdate?.call(message);
  }
}
