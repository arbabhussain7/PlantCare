import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import 'package:plantcare/services/gemini_service.dart';
import 'package:plantcare/views/model_results.dart';

class MangoController extends GetxController {
  final selectedImage = Rx<File?>(null);
  final isLoading = false.obs;
  final errorMessage = ''.obs;
  final classificationResult = RxString('');

  String _apiKey = '';
  String _modelName = '';

  @override
  void onInit() {
    super.onInit();
    _apiKey = const String.fromEnvironment('GEMINI_API_KEY');
    _modelName = const String.fromEnvironment(
      'GEMINI_MODEL',
      defaultValue: 'gemini-flash-latest',
    );
  }

  bool get hasResult => classificationResult.value.trim().isNotEmpty;

  Future<void> pickAndClassify(ImageSource source) async {
    errorMessage.value = '';
    classificationResult.value = '';

    try {
      debugPrint('[MangoController] pickAndClassify source=$source model=$_modelName');
      final image = await _pickImage(source);
      if (image == null) return;

      selectedImage.value = image;
      debugPrint('[MangoController] image selected path=${image.path}');

      if (_apiKey.isEmpty) {
        errorMessage.value =
            'Missing Gemini API key.\n\n'
            'Run the app with:\n'
            '--dart-define=GEMINI_API_KEY=YOUR_KEY\n\n'
            'Then fully stop the app and run again (hot restart won’t apply --dart-define).';
        return;
      }

      isLoading.value = true;

      final dnsOk = await _canResolveGeminiHost();
      if (!dnsOk) {
        errorMessage.value =
            'Network/DNS error: cannot resolve generativelanguage.googleapis.com.\n'
            'Please check internet (Wi‑Fi/mobile data), private DNS/VPN, and try again.';
        debugPrint('[MangoController] DNS lookup failed for Gemini host');
        return;
      }
      debugPrint('[MangoController] DNS lookup ok');

      final preflightOk = await _preflightGeminiApi();
      if (!preflightOk) {
        errorMessage.value =
            'Network error: cannot reach Gemini API.\n'
            'Please check internet connection, disable VPN/Private DNS, and try again.';
        debugPrint('[MangoController] Preflight Gemini API failed');
        return;
      }
      debugPrint('[MangoController] Preflight Gemini API ok');

      final bytes = await image.readAsBytes();
      final mimeType = _guessMimeType(image.path);
      debugPrint('[MangoController] mimeType=$mimeType bytes=${bytes.length}');
      final geminiService = GeminiService(apiKey: _apiKey, model: _modelName);

      final result = await geminiService.classifyMangoLeaf(
        imageBytes: bytes,
        mimeType: mimeType,
        timeout: const Duration(seconds: 60),
        maxRetries: 3,
      );

      classificationResult.value = result;

      Get.to(
        () => ModelResults(
          imageFile: image,
          classification: result,
        ),
      );
    } on PlatformException catch (e) {
      if ((e.code).toLowerCase().contains('denied')) {
        errorMessage.value =
            'Permission denied. Please allow camera/photos access and try again.';
      } else {
        errorMessage.value = e.message ?? 'Failed to pick image.';
      }
    } on TimeoutException {
      errorMessage.value =
          'Request timed out. Please check your connection and try again.';
      debugPrint('[MangoController] TimeoutException');
    } on GenerativeAIException catch (e) {
      errorMessage.value =
          'Gemini API error: ${e.message}\n\n'
          'Model: $_modelName';
      debugPrint('[MangoController] GenerativeAIException: ${e.message}');
    } on SocketException {
      errorMessage.value =
          'Network error. Please check internet connection and try again.';
      debugPrint('[MangoController] SocketException');
    } catch (e) {
      errorMessage.value = 'Failed to analyze image: $e';
      debugPrint('[MangoController] Unknown error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _canResolveGeminiHost() async {
    try {
      final result = await InternetAddress.lookup('generativelanguage.googleapis.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<bool> _preflightGeminiApi() async {
    try {
      final uri = Uri.parse(
        'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey',
      );
      final resp = await http.get(uri).timeout(const Duration(seconds: 8));
      return resp.statusCode >= 200 && resp.statusCode < 500;
    } catch (_) {
      return false;
    }
  }

  Future<File?> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final XFile? xfile = await picker.pickImage(
      source: source,
      // Smaller images upload faster → fewer 503/deadline errors.
      maxWidth: 1024,
      maxHeight: 1024,
      imageQuality: 80,
    );
    if (xfile == null) return null;
    return File(xfile.path);
  }

  String _guessMimeType(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  void clear() {
    selectedImage.value = null;
    isLoading.value = false;
    errorMessage.value = '';
    classificationResult.value = '';
  }
}

