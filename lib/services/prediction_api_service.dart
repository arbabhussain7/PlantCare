import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class PredictionApiService {
  PredictionApiService({required this.predictUrl});

  /// Full URL to the predict endpoint (example):
  /// `http://<ip>:8000/api/prediction/predict/`
  final String predictUrl;

  Future<({String prediction, double? confidence})> predict(File imageFile) async {
    final uri = Uri.parse(predictUrl);
    final request = http.MultipartRequest('POST', uri);
    request.files.add(await http.MultipartFile.fromPath('image', imageFile.path));

    final streamed = await request.send().timeout(const Duration(seconds: 45));
    final body = await streamed.stream.bytesToString();

    if (streamed.statusCode < 200 || streamed.statusCode >= 300) {
      throw HttpException('Predict failed (${streamed.statusCode}): $body');
    }

    final decoded = jsonDecode(body);
    if (decoded is! Map<String, dynamic>) {
      throw FormatException('Unexpected response shape: $decoded');
    }

    final prediction = decoded['prediction'];
    final confidence = decoded['confidence'];

    if (prediction is! String || prediction.trim().isEmpty) {
      throw FormatException('Missing prediction in response: $decoded');
    }

    double? conf;
    if (confidence is num) conf = confidence.toDouble();

    return (prediction: prediction.trim(), confidence: conf);
  }
}

