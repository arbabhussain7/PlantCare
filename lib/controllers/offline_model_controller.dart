import 'dart:async';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:plantcare/services/prediction_api_service.dart';
import 'package:plantcare/services/tflite_service.dart';
import 'package:plantcare/views/model_results.dart';

class OfflineModelController extends GetxController {
  final selectedImage = Rx<File?>(null);
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final classificationResult = RxString('');

  final TfliteService _tflite = TfliteService();
  late final String _predictApiUrl;

  bool get hasResult => classificationResult.value.trim().isNotEmpty;

  @override
  void onInit() {
    super.onInit();
    _predictApiUrl = const String.fromEnvironment('PREDICT_API_URL');
  }

  Future<void> pickAndClassify(ImageSource source) async {
    errorMessage.value = '';
    classificationResult.value = '';

    try {
      final image = await _pickImage(source);
      if (image == null) return;
      selectedImage.value = image;

      isLoading.value = true;

      // 1) Prefer offline TFLite if model asset exists.
      // 2) If missing, fall back to your Django/DRF API (if configured).
      String label;
      try {
        final bytes = await image.readAsBytes();
        final result = await _tflite.classifyImageBytes(bytes);
        label = result.label;
      } on StateError catch (e) {
        final msg = e.message ?? '';
        final missingTflite = msg.toLowerCase().contains('unable to load asset') ||
            msg.toLowerCase().contains('.tflite');
        if (!missingTflite || _predictApiUrl.trim().isEmpty) rethrow;

        final api = PredictionApiService(predictUrl: _predictApiUrl.trim());
        final apiResult = await api.predict(image);
        label = apiResult.prediction;
      }

      classificationResult.value = label;

      Get.to(
        () => ModelResults(
          imageFile: image,
          classification: label,
        ),
      );
    } on PlatformException catch (e) {
      if ((e.code).toLowerCase().contains('denied')) {
        errorMessage.value =
            'Permission denied. Please allow camera/photos access and try again.';
      } else {
        errorMessage.value = e.message ?? 'Failed to pick image.';
      }
    } on ArgumentError catch (e) {
      errorMessage.value = 'Offline model error: $e';
    } on StateError catch (e) {
      // Most common: missing assets/model/model.tflite
      errorMessage.value =
          'Offline model is not configured.\n\n'
          'Please add your TFLite file to:\n'
          'assets/model/model.tflite\n\n'
          'OR set a hosted API endpoint and rebuild:\n'
          '--dart-define=PREDICT_API_URL=http://<ip>:8000/api/prediction/predict/\n\n'
          'Error: ${e.message}';
    } catch (e) {
      errorMessage.value = 'Failed to analyze image offline: $e';
    } finally {
      isLoading.value = false;
    }
  }

  Future<File?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(
      source: source,
      imageQuality: 85,
    );
    if (xfile == null) return null;
    return File(xfile.path);
  }

  void clear() {
    selectedImage.value = null;
    isLoading.value = false;
    errorMessage.value = '';
    classificationResult.value = '';
  }
}

