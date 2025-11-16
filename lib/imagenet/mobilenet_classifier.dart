import 'dart:typed_data';
import 'dart:math' as math;
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:onnxruntime/onnxruntime.dart';

Future<String> classifyImage(Uint8List imageBytes) async {
  final modelData = await rootBundle.load('assets/model/mobilenetv2-10.onnx');
  final labels = await rootBundle.loadString('assets/labels/imagenet_classes.txt');
  final labelList = labels.split('\n').where((label) => label.trim().isNotEmpty).toList();

  final session = OrtSession.fromBuffer(
    modelData.buffer.asUint8List(),
    OrtSessionOptions(),
  );

  // Decode and preprocess image
  final image = img.decodeImage(imageBytes)!;
  final preprocessed = preprocessImage(image);
  final input = imageToFloat32(preprocessed);

  final inputTensor = OrtValueTensor.createTensorWithDataList(
    input,
    [1, 3, 224, 224],
  );

  final output = await session.runAsync(OrtRunOptions(), {
    session.inputNames.first: inputTensor,
  });

  final outputValue = output?.first?.value;
  if (outputValue == null || outputValue is! List || outputValue.isEmpty) {
    return "No result";
  }

  // Handle output properly
  final scores = (outputValue.first as List).cast<double>();

  // Apply softmax to get probabilities
  final probabilities = softmax(scores);

  // Get top 5 predictions
  final topIndices = getTopKIndices(probabilities, 5);

  // Get the best prediction
  final bestIndex = topIndices[0];
  final confidence = probabilities[bestIndex];

  // Clean up session
  inputTensor.release();
  session.release();

  // Format result with label cleaning
  final label = cleanLabel(labelList[bestIndex]);

  // Return top prediction with additional info if confidence is low
  if (confidence < 0.5) {
    final secondBest = topIndices.length > 1 ? labelList[topIndices[1]] : "";
    final secondConfidence = topIndices.length > 1 ? probabilities[topIndices[1]] : 0.0;
    return "$label (${(confidence * 100).toStringAsFixed(1)}%)\nAlternative: ${cleanLabel(secondBest)} (${(secondConfidence * 100).toStringAsFixed(1)}%)";
  }

  return "$label (${(confidence * 100).toStringAsFixed(1)}%)";
}

// Preprocess image with proper center crop and aspect ratio handling
img.Image preprocessImage(img.Image image) {
  // MobileNetV2 expects 224x224 images
  const targetSize = 224;

  // Calculate center crop to maintain aspect ratio
  final width = image.width;
  final height = image.height;

  // Determine the size of the square crop
  final cropSize = math.min(width, height);

  // Calculate crop coordinates for center crop
  final left = (width - cropSize) ~/ 2;
  final top = (height - cropSize) ~/ 2;

  // Center crop the image
  final cropped = img.copyCrop(
    image,
    x: left,
    y: top,
    width: cropSize,
    height: cropSize,
  );

  // Resize to target size with high-quality interpolation
  final resized = img.copyResize(
    cropped,
    width: targetSize,
    height: targetSize,
    interpolation: img.Interpolation.cubic,
  );

  return resized;
}

// Convert image to float array with proper MobileNetV2 normalization
Float32List imageToFloat32(img.Image image) {
  final floats = Float32List(3 * 224 * 224);

  // MobileNetV2 specific normalization parameters
  const mean = [0.485, 0.456, 0.406]; // ImageNet mean
  const std = [0.229, 0.224, 0.225];  // ImageNet std

  int pixelIndex = 0;

  for (int y = 0; y < 224; y++) {
    for (int x = 0; x < 224; x++) {
      final pixel = image.getPixel(x, y);

      // Convert to 0-1 range first
      final r = pixel.r / 255.0;
      final g = pixel.g / 255.0;
      final b = pixel.b / 255.0;

      // Apply ImageNet normalization: (pixel - mean) / std
      floats[pixelIndex] = (r - mean[0]) / std[0];
      floats[pixelIndex + 224 * 224] = (g - mean[1]) / std[1];
      floats[pixelIndex + 2 * 224 * 224] = (b - mean[2]) / std[2];

      pixelIndex++;
    }
  }

  return floats;
}

// Apply softmax to convert logits to probabilities
List<double> softmax(List<double> logits) {
  // Find max for numerical stability
  final maxLogit = logits.reduce(math.max);

  // Compute exp(x - max) for numerical stability
  final expValues = logits.map((x) => math.exp(x - maxLogit)).toList();

  // Sum of all exp values
  final sumExp = expValues.reduce((a, b) => a + b);

  // Normalize to get probabilities
  return expValues.map((x) => x / sumExp).toList();
}

// Get indices of top K values
List<int> getTopKIndices(List<double> values, int k) {
  final indexed = values.asMap().entries.toList();
  indexed.sort((a, b) => b.value.compareTo(a.value));
  return indexed.take(k).map((e) => e.key).toList();
}

// Clean label text (remove index numbers if present)
String cleanLabel(String label) {
  // Remove leading numbers and dots/colons
  final cleaned = label.replaceFirst(RegExp(r'^\d+[\.:]\s*'), '');

  // Capitalize first letter of each word
  return cleaned.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

// Alternative: Apply temperature scaling for calibration (optional)
List<double> applyTemperatureScaling(List<double> logits, {double temperature = 1.0}) {
  if (temperature == 1.0) return logits;
  return logits.map((x) => x / temperature).toList();
}

// Enhanced classification with multiple preprocessing attempts (optional)
Future<String> classifyImageWithFallback(Uint8List imageBytes) async {
  // Try standard classification first
  final result = await classifyImage(imageBytes);

  // If confidence is very low, you could try different preprocessing
  if (result.contains("(") && result.contains("%")) {
    final confidenceStr = result.split("(")[1].split("%")[0];
    final confidence = double.tryParse(confidenceStr) ?? 0;

    if (confidence < 30) {
      // You could implement alternative preprocessing here
      // For example: different crop strategies, color adjustments, etc.
      return "$result\n⚠️ Low confidence - image may be unclear or out of domain";
    }
  }

  return result;
}