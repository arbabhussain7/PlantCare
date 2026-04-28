import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:http/http.dart' as http;

class GeminiService {
  GeminiService({required String apiKey, required String model})
      : _apiKey = apiKey,
        _model = model;

  final String _apiKey;
  final String _model;

  static const List<String> _allowedClasses = <String>[
    'Anthracnose',
    'Bacterial Canker',
    'Cutting Weevil',
    'Die Back',
    'Healthy',
  ];

  static const String _systemInstruction =
      'You are an AI trained to classify mango leaf diseases. Analyze the image and return EXACTLY ONE of these: Anthracnose, Bacterial Canker, Cutting Weevil, Die Back, or Healthy. No extra text.';

  static const String _userPrompt = '''
You are an AI model trained to classify mango leaf diseases.

Your task is to analyze the given mango leaf image and classify it into EXACTLY ONE of the following 5 classes:

1. Anthracnose
2. Bacterial Canker
3. Cutting Weevil
4. Die Back
5. Healthy

Strict Rules:
- Output ONLY one class name from the list above.
- Do NOT explain your answer.
- Do NOT add extra text, punctuation, or formatting.
- Do NOT return probabilities or multiple classes.
- If unsure, return the most probable class ONLY.

Classification Guidelines:
- Anthracnose → dark/black spots, often along edges, irregular patches.
- Bacterial Canker → water-soaked lesions, cracks, or necrotic spots.
- Cutting Weevil → leaf edges appear cut or eaten.
- Die Back → yellowing, drying, or dead leaf tips.
- Healthy → no visible disease symptoms.
''';

  Future<String> classifyMangoLeaf({
    required Uint8List imageBytes,
    required String mimeType,
    Duration timeout = const Duration(seconds: 60),
    int maxRetries = 3,
  }) async {
    final candidates = <String>[
      _sanitizeModelName(_model),
      'gemini-flash-latest',
      'gemini-1.5-flash',
      'gemini-1.5-pro',
    ].where((m) => m.trim().isNotEmpty).toList();

    GenerativeAIException? lastAiError;
    for (final modelName in candidates.toSet()) {
      try {
        final raw = await _generateWithRetry(
          modelName: modelName,
          imageBytes: imageBytes,
          mimeType: mimeType,
          timeout: timeout,
          maxRetries: maxRetries,
        );
        return _normalizeToAllowedClass(raw);
      } on GenerativeAIException catch (e) {
        lastAiError = e;
        final msg = (e.message).toLowerCase();
        final isModelNotFound = msg.contains('is not found') ||
            msg.contains('not supported') ||
            msg.contains('model') && msg.contains('not found');
        if (!isModelNotFound) rethrow;
        // else: try next candidate
      }
    }

    // Final fallback: dynamically discover models for this key/project.
    try {
      final discovered = await _discoverSupportedModel(timeout: timeout);
      final raw = await _generateWithRetry(
        modelName: discovered,
        imageBytes: imageBytes,
        mimeType: mimeType,
        timeout: timeout,
        maxRetries: maxRetries,
      );
      return _normalizeToAllowedClass(raw);
    } on GenerativeAIException catch (e) {
      lastAiError ??= e;
    } catch (_) {
      // ignore and fall through to lastAiError
    }

    if (lastAiError != null) throw lastAiError;
    throw StateError('No Gemini model candidates available.');
  }

  Future<String> _generateWithRetry({
    required String modelName,
    required Uint8List imageBytes,
    required String mimeType,
    required Duration timeout,
    required int maxRetries,
  }) async {
    final model = GenerativeModel(
      model: modelName,
      apiKey: _apiKey,
      systemInstruction: Content.text(_systemInstruction),
    );

    for (var attempt = 0; attempt <= maxRetries; attempt++) {
      try {
        final response = await model
            .generateContent(<Content>[
              Content.multi(<Part>[
                DataPart(mimeType, imageBytes),
                TextPart(_userPrompt),
              ]),
            ])
            .timeout(timeout);
        return (response.text ?? '').trim();
      } on TimeoutException catch (_) {
        if (attempt == maxRetries) rethrow;
        await Future<void>.delayed(_backoffDelay(attempt));
      } on GenerativeAIException catch (e) {
        final msg = e.message.toLowerCase();
        final retryable = msg.contains('503') ||
            msg.contains('unavailable') ||
            msg.contains('deadline') ||
            msg.contains('timeout') ||
            msg.contains('temporarily');
        if (!retryable || attempt == maxRetries) rethrow;
        await Future<void>.delayed(_backoffDelay(attempt));
      }
    }
    throw StateError('Unreachable');
  }

  Duration _backoffDelay(int attempt) {
    // Exponential backoff with small jitter: 800ms, 1600ms, 3200ms...
    final baseMs = 800 * (1 << attempt);
    final jitterMs = Random().nextInt(250);
    return Duration(milliseconds: baseMs + jitterMs);
  }

  String _normalizeToAllowedClass(String raw) {
    final trimmed = raw.trim();
    if (_allowedClasses.contains(trimmed)) return trimmed;

    final cleaned = trimmed
        .replaceAll(RegExp(r'[\.\,\:\;\!\?\n\r\t]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    for (final c in _allowedClasses) {
      if (cleaned.toLowerCase() == c.toLowerCase()) return c;
    }

    final match = _allowedClasses.firstWhere(
      (c) => cleaned.toLowerCase().contains(c.toLowerCase()),
      orElse: () => '',
    );
    if (match.isNotEmpty) return match;

    throw FormatException('Unexpected Gemini output: "$raw"');
  }

  String _sanitizeModelName(String model) {
    final m = model.trim();
    if (m.endsWith('-latest')) {
      return m.substring(0, m.length - '-latest'.length);
    }
    return m;
  }

  Future<String> _discoverSupportedModel({required Duration timeout}) async {
    final uri = Uri.parse(
      'https://generativelanguage.googleapis.com/v1beta/models?key=$_apiKey',
    );
    final resp = await http.get(uri).timeout(timeout);
    if (resp.statusCode < 200 || resp.statusCode >= 300) {
      throw GenerativeAIException('ListModels failed (${resp.statusCode}): ${resp.body}');
    }

    final decoded = jsonDecode(resp.body);
    final models = (decoded is Map<String, dynamic>) ? decoded['models'] : null;
    if (models is! List) {
      throw GenerativeAIException('ListModels: unexpected response shape.');
    }

    final supported = <String>[];
    for (final m in models) {
      if (m is! Map) continue;
      final name = m['name'];
      final methods = m['supportedGenerationMethods'];
      if (name is! String) continue;
      if (methods is! List) continue;
      final methodStrings = methods.whereType<String>().toList();
      if (!methodStrings.contains('generateContent')) continue;
      supported.add(name);
    }

    if (supported.isEmpty) {
      throw GenerativeAIException('ListModels: no models support generateContent.');
    }

    // Prefer flash models, then any gemini model.
    String pick(List<String> items, bool Function(String) pred) {
      return items.firstWhere(pred, orElse: () => '');
    }

    final flash = pick(
      supported,
      (n) => n.toLowerCase().contains('flash') && n.toLowerCase().contains('gemini'),
    );
    final geminiAny = pick(supported, (n) => n.toLowerCase().contains('gemini'));
    final chosen = flash.isNotEmpty ? flash : (geminiAny.isNotEmpty ? geminiAny : supported.first);

    // API returns like "models/gemini-xxx" but the SDK expects without "models/".
    return chosen.startsWith('models/') ? chosen.substring('models/'.length) : chosen;
  }
}

