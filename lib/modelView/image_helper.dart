// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// // import 'package:image/image.dart' as img;
// import 'dart:math' as math;

// class ImageHelper {
//   static const int inputSize = 224; // DenseNet-201 input size

//   /// Preprocess image for TensorFlow Lite model
//   static Future<Float32List> preprocessImage(File imageFile) async {
//     try {
//       // Read image file
//       final bytes = await imageFile.readAsBytes();
//       final image = img.decodeImage(bytes);
      
//       if (image == null) {
//         throw Exception('Failed to decode image');
//       }

//       print('Original image size: ${image.width}x${image.height}');

//       // Resize image to 224x224 using the class constant
//       final resizedImage = img.copyResize(
//         image,
//         width: inputSize,
//         height: inputSize,
//         interpolation: img.Interpolation.linear,
//       );

//       print('Resized image to: ${resizedImage.width}x${resizedImage.height}');

//       // Create a flat Float32List for the input tensor
//       // Format: [batch_size * height * width * channels] = [1 * 224 * 224 * 3]
//       final input = Float32List(1 * inputSize * inputSize * 3);
      
//       // Fill the tensor with normalized pixel values
//       // Note: TensorFlow Lite expects NHWC format (batch, height, width, channels)
//       int tensorIndex = 0;
      
//       for (int y = 0; y < inputSize; y++) {
//         for (int x = 0; x < inputSize; x++) {
//           final pixel = resizedImage.getPixel(x, y);
          
//           // Extract RGB values and normalize to [0, 1]
//           final r = pixel.r / 255.0;
//           final g = pixel.g / 255.0;
//           final b = pixel.b / 255.0;
          
//                 // Apply ImageNet normalization (mean and std for DenseNet)
//       // Format: [batch, height, width, channels] = [1, 224, 224, 3]
//       // For DenseNet-201, use standard ImageNet normalization
//       // Some models expect different normalization, so we'll try multiple approaches
//       input[tensorIndex++] = (r - 0.485) / 0.229; // Red channel
//       input[tensorIndex++] = (g - 0.456) / 0.224; // Green channel
//       input[tensorIndex++] = (b - 0.406) / 0.225; // Blue channel
//         }
//       }
      
//       // Ensure the tensor is properly formatted for the model
//       // Some models expect specific memory layout
//       final formattedInput = Float32List.fromList(input);

//       print('Image preprocessing completed successfully');
//       print('Input tensor size: ${input.length}');
//       print('Expected size: ${1 * inputSize * inputSize * 3}');
      
//              // Validate tensor size
//        if (formattedInput.length != 1 * inputSize * inputSize * 3) {
//          throw Exception('Invalid tensor size. Expected: ${1 * inputSize * inputSize * 3}, Got: ${formattedInput.length}');
//        }
       
//        return formattedInput;
      
//     } catch (e) {
//       print('Error in preprocessImage: $e');
//       throw Exception('Failed to preprocess image: $e');
//     }
//   }

//   /// Apply softmax to convert logits to probabilities
//   static List<double> softmax(List<double> logits) {
//     // Find max value for numerical stability
//     double maxLogit = logits.reduce((a, b) => math.max(a, b));
    
//     // Calculate exponentials
//     List<double> expLogits = logits.map((logit) => math.exp(logit - maxLogit)).toList();
    
//     // Calculate sum of exponentials
//     double sumExp = expLogits.reduce((a, b) => a + b);
    
//     // Apply softmax
//     return expLogits.map((exp) => exp / sumExp).toList();
//   }

//   /// Get top predictions from model output
//   static List<Map<String, dynamic>> getTopPredictions(
//     Float32List output, // Changed back to Float32List
//     List<String> labels,
//     {int topK = 5}
//   ) {
//     try {
//       if (output.isEmpty) {
//         throw Exception('Empty model output');
//       }

//       print('Raw model output length: ${output.length}');
//       print('Labels length: ${labels.length}');
      
//       // Convert Float32List to List<double>
//       List<double> predictions = output.toList();
      
//       // Apply softmax to convert logits to probabilities
//       List<double> probabilities = softmax(predictions);
      
//       // Create indexed list for sorting
//       final List<MapEntry<int, double>> indexed = [];
      
//       for (int i = 0; i < probabilities.length && i < labels.length; i++) {
//         indexed.add(MapEntry(i, probabilities[i]));
//       }
      
//       // Sort by confidence (descending)
//       indexed.sort((a, b) => b.value.compareTo(a.value));
      
//       // Get top K predictions
//       final List<Map<String, dynamic>> topPredictions = [];
//       for (int i = 0; i < topK && i < indexed.length; i++) {
//         final index = indexed[i].key;
//         final confidence = indexed[i].value;
        
//         print('Prediction ${i + 1}: ${labels[index]} - ${(confidence * 100).toStringAsFixed(2)}%');
        
//         topPredictions.add({
//           'label': labels[index],
//           'confidence': confidence, // This is already a probability (0-1)
//         });
//       }
      
//       return topPredictions;
      
//     } catch (e) {
//       print('Error in getTopPredictions: $e');
//       throw Exception('Failed to process predictions: $e');
//     }
//   }

//   /// Validate model output shape
//   static bool validateOutputShape(dynamic output, int expectedClasses) {
//     if (output is Float32List) {
//       return output.length == expectedClasses;
//     }
//     return false;
//   }

//   /// Alternative preprocessing method for models that expect different normalization
//   static Future<Float32List> preprocessImageAlternative(File imageFile) async {
//     try {
//       // Read image file
//       final bytes = await imageFile.readAsBytes();
//       final image = img.decodeImage(bytes);
      
//       if (image == null) {
//         throw Exception('Failed to decode image');
//       }

//       print('Original image size: ${image.width}x${image.height}');

//       // Resize image to 224x224
//       final resizedImage = img.copyResize(
//         image,
//         width: inputSize,
//         height: inputSize,
//         interpolation: img.Interpolation.linear,
//       );

//       print('Resized image to: ${resizedImage.width}x${resizedImage.height}');

//       // Create a flat Float32List for the input tensor
//       final input = Float32List(1 * inputSize * inputSize * 3);
      
//       int tensorIndex = 0;
      
//       for (int y = 0; y < inputSize; y++) {
//         for (int x = 0; x < inputSize; x++) {
//           final pixel = resizedImage.getPixel(x, y);
          
//           // Extract RGB values and normalize to [0, 1]
//           final r = pixel.r / 255.0;
//           final g = pixel.g / 255.0;
//           final b = pixel.b / 255.0;
          
//           // Alternative normalization: simple [0,1] range without ImageNet stats
//           input[tensorIndex++] = r; // Red channel
//           input[tensorIndex++] = g; // Green channel
//           input[tensorIndex++] = b; // Blue channel
//         }
//       }
      
//       print('Alternative preprocessing completed successfully');
//       print('Input tensor size: ${input.length}');
      
//       return input;
      
//          } catch (e) {
//        print('Error in alternative preprocessImage: $e');
//        throw Exception('Failed to preprocess image: $e');
//      }
//    }

//    /// Preprocessing method for different input sizes (maybe the model expects different dimensions)
//    static Future<Float32List> preprocessImageDifferentSize(File imageFile) async {
//      try {
//        // Read image file
//        final bytes = await imageFile.readAsBytes();
//        final image = img.decodeImage(bytes);
       
//        if (image == null) {
//          throw Exception('Failed to decode image');
//        }

//        print('Original image size: ${image.width}x${image.height}');

//        // Try different input sizes that DenseNet models might expect
//        final differentSizes = [299, 331, 256, 192]; // Common DenseNet input sizes
       
//        for (int size in differentSizes) {
//          try {
//            print('Trying input size: ${size}x$size');
           
//            // Resize image to the test size
//            final resizedImage = img.copyResize(
//              image,
//              width: size,
//              height: size,
//              interpolation: img.Interpolation.linear,
//            );

//            // Create a flat Float32List for the input tensor
//            final input = Float32List(1 * size * size * 3);
           
//            int tensorIndex = 0;
           
//            for (int y = 0; y < size; y++) {
//              for (int x = 0; x < size; x++) {
//                final pixel = resizedImage.getPixel(x, y);
               
//                // Extract RGB values and normalize to [0, 1]
//                final r = pixel.r / 255.0;
//                final g = pixel.g / 255.0;
//                final b = pixel.b / 255.0;
               
//                // Simple normalization without ImageNet stats
//                input[tensorIndex++] = r;
//                input[tensorIndex++] = g;
//                input[tensorIndex++] = b;
//              }
//            }
           
//            print('Different size preprocessing completed successfully for $size');
//            print('Input tensor size: ${input.length}');
           
//            return input;
           
//          } catch (e) {
//            print('Failed with size $size: $e');
//            continue;
//          }
//        }
       
//        throw Exception('All different sizes failed');
       
//      } catch (e) {
//        print('Error in different size preprocessImage: $e');
//        throw Exception('Failed to preprocess image: $e');
//      }
//    }

//    /// Raw preprocessing method - minimal processing
//    static Future<Float32List> preprocessImageRaw(File imageFile) async {
//      try {
//        // Read image file
//        final bytes = await imageFile.readAsBytes();
//        final image = img.decodeImage(bytes);
       
//        if (image == null) {
//          throw Exception('Failed to decode image');
//        }

//        print('Original image size: ${image.width}x${image.height}');

//        // Use original image size or resize to a very small size
//        final targetSize = 64; // Very small size to test
       
//        // Resize image
//        final resizedImage = img.copyResize(
//          image,
//          width: targetSize,
//          height: targetSize,
//          interpolation: img.Interpolation.linear,
//        );

//        // Create a flat Float32List for the input tensor
//        final input = Float32List(1 * targetSize * targetSize * 3);
       
//        int tensorIndex = 0;
       
//        for (int y = 0; y < targetSize; y++) {
//          for (int x = 0; x < targetSize; x++) {
//            final pixel = resizedImage.getPixel(x, y);
           
//            // Extract RGB values and normalize to [0, 1]
//            final r = pixel.r / 255.0;
//            final g = pixel.g / 255.0;
//            final b = pixel.b / 255.0;
           
//            // Raw values without any normalization
//            input[tensorIndex++] = r;
//            input[tensorIndex++] = g;
//            input[tensorIndex++] = b;
//          }
//        }
       
//        print('Raw preprocessing completed successfully');
//        print('Input tensor size: ${input.length}');
       
//        return input;
       
//      } catch (e) {
//        print('Error in raw preprocessImage: $e');
//        throw Exception('Failed to preprocess image: $e');
//      }
//    }

//    /// Preprocessing method that matches the actual model input shape
//    static Future<Float32List> preprocessImageForShape(File imageFile, List<int> targetShape) async {
//      try {
//        // Read image file
//        final bytes = await imageFile.readAsBytes();
//        final image = img.decodeImage(bytes);
       
//        if (image == null) {
//          throw Exception('Failed to decode image');
//        }

//        print('Original image size: ${image.width}x${image.height}');
//        print('Target shape: $targetShape');

//        // Extract dimensions from target shape
//        int batchSize = targetShape[0];
//        int height = targetShape[1];
//        int width = targetShape[2];
//        int channels = targetShape[3];

//        // Resize image to match the target dimensions
//        final resizedImage = img.copyResize(
//          image,
//          width: width,
//          height: height,
//          interpolation: img.Interpolation.linear,
//        );

//        // Create a flat Float32List for the input tensor
//        final input = Float32List(batchSize * height * width * channels);
       
//        int tensorIndex = 0;
       
//        for (int y = 0; y < height; y++) {
//          for (int x = 0; x < width; x++) {
//            final pixel = resizedImage.getPixel(x, y);
           
//            // Extract RGB values and normalize to [0, 1]
//            final r = pixel.r / 255.0;
//            final g = pixel.g / 255.0;
//            final b = pixel.b / 255.0;
           
//            // Simple normalization without ImageNet stats
//            input[tensorIndex++] = r;
//            input[tensorIndex++] = g;
//            input[tensorIndex++] = b;
//          }
//        }
       
//        print('Shape-specific preprocessing completed successfully');
//        print('Input tensor size: ${input.length}');
//        print('Expected size: ${batchSize * height * width * channels}');
       
//        return input;
       
//      } catch (e) {
//        print('Error in shape-specific preprocessImage: $e');
//        throw Exception('Failed to preprocess image: $e');
//      }
//    }
// }