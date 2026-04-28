import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteService {
  TfliteService({
    this.modelAssetPath = 'assets/model/model.tflite',
    this.labelsAssetPath = 'assets/model/labels.txt',
  });

  final String modelAssetPath;
  final String labelsAssetPath;

  Interpreter? _interpreter;
  List<String>? _labels;

  Future<void> init() async {
    _labels ??= await _loadLabels(labelsAssetPath);
    _interpreter ??= await Interpreter.fromAsset(modelAssetPath);
  }

  bool get isReady => _interpreter != null && _labels != null;

  /// Returns (label, confidence) for top prediction.
  Future<({String label, double confidence})> classifyImageBytes(Uint8List bytes) async {
    await init();

    final interpreter = _interpreter!;
    final labels = _labels!;

    final input = interpreter.getInputTensor(0);
    final inputShape = input.shape; // e.g. [1, 224, 224, 3]
    final inputType = input.type;

    if (inputShape.length != 4 || inputShape[0] != 1 || inputShape[3] != 3) {
      throw StateError('Unsupported input shape: $inputShape');
    }

    final height = inputShape[1];
    final width = inputShape[2];

    final decoded = img.decodeImage(bytes);
    if (decoded == null) throw StateError('Unable to decode image.');

    final resized = img.copyResize(decoded, width: width, height: height, interpolation: img.Interpolation.linear);

    // Prepare input tensor data.
    final inputBuffer = _imageToInput(resized, inputType);

    final output = interpreter.getOutputTensor(0);
    final outputShape = output.shape; // e.g. [1, numLabels]
    if (outputShape.length != 2 || outputShape[0] != 1) {
      throw StateError('Unsupported output shape: $outputShape');
    }

    final numLabels = outputShape[1];
    if (labels.length < numLabels) {
      throw StateError('labels.txt has ${labels.length} labels but model expects $numLabels.');
    }

    final outputBuffer = List<double>.filled(numLabels, 0);

    interpreter.run(inputBuffer, [outputBuffer]);

    final (index, conf) = _argmax(outputBuffer);
    final label = labels[index];
    return (label: label, confidence: conf);
  }

  Object _imageToInput(img.Image image, TensorType type) {
    // Most image classification models expect float32 normalized to [0,1].
    // If your model expects different normalization (e.g. [-1,1]), adjust here.
    final h = image.height;
    final w = image.width;

    if (type == TensorType.float32) {
      final input = List.generate(
        1,
        (_) => List.generate(
          h,
          (y) => List.generate(w, (x) {
            final p = image.getPixel(x, y);
            final r = p.r / 255.0;
            final g = p.g / 255.0;
            final b = p.b / 255.0;
            return <double>[r, g, b];
          }),
        ),
      );
      return input;
    }
 
    if (type == TensorType.uint8) {
      final input = List.generate(
        1,
        (_) => List.generate(
          h,
          (y) => List.generate(w, (x) {
            final p = image.getPixel(x, y);
            return <int>[p.r.toInt(), p.g.toInt(), p.b.toInt()];
          }),
        ),
      );
      return input;
    }

    throw StateError('Unsupported input tensor type: $type');
  }

  (int, double) _argmax(List<double> values) {
    var bestIdx = 0;
    var bestVal = values[0];
    for (var i = 1; i < values.length; i++) {
      if (values[i] > bestVal) {
        bestVal = values[i];
        bestIdx = i;
      }
    }
    return (bestIdx, bestVal);
  }

  Future<List<String>> _loadLabels(String assetPath) async {
    final data = await rootBundle.loadString(assetPath);
    return data
        .split('\n')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }
}

