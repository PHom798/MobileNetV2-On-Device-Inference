---
title: "Mastering On-Device ML in Flutter: A Guide to Soft-max, Top-K, and Confidence Checks"
seoTitle: "On-Device ML in Flutter: Softmax, Top-K & Confidence"
seoDescription: "Learn how to run efficient on-device ML in Flutter using MobileNetV2 with softmax, top-K predictions, and confidence scoring."
datePublished: Thu Nov 27 2025 10:08:49 GMT+0000 (Coordinated Universal Time)
cuid: cmih9tx9q000f02jo3k0n8a71
slug: mastering-on-device-ml-in-flutter-a-guide-to-soft-max-top-k-and-confidence-checks
cover: https://cdn.hashnode.com/res/hashnode/image/upload/v1764080411938/d11f5d1e-75e5-45ab-9c80-0cb769b07020.png
ogImage: https://cdn.hashnode.com/res/hashnode/image/upload/v1764204823168/88b04aa8-e626-4ed7-95b6-1e84fe69f653.png
tags: flutter, machine-learning, mobile-development, flutter-examples, softmax, model-deployment, onnx

---

Hey there, fellow developers!✨

Have you ever wondered how to harness the power of advanced machine learning directly on your mobile devices using Flutter? Today, we’re diving deep into the realm of on-device ML, focusing on some of the most effective techniques to enhance your image classification models. Whether you’re a seasoned developer or just starting out, this guide will walk you through the essentials of deploying MobileNetv2 in Flutter, complete with softmax activation, top-K predictions, and confidence checks.

Let’s get started!

## Why On-Device ML Matters

In today’s fast-paced digital world, users demand instant results. Cloud-based ML solutions often suffer from latency and privacy concerns. On-device ML offers a perfect balance: fast inference times, no internet dependency, and enhanced user privacy. Flutter, with its cross-platform capabilities and growing ecosystem, is an ideal choice for deploying these models efficiently.

## Why MobileNetV2?

MobileNetV2 is a state-of-the-art neural network designed specifically for mobile and embedded vision applications. It strikes an excellent balance between accuracy and computational efficiency, making it perfect for on-device inference. With Flutter, you can leverage this powerful model to build robust and responsive applications

## Why This Article Matters?

Most Flutter machine learning tutorials rely on TensorFlow Lite, which is great, but it has limitations when you want to run custom models or experiment with different frameworks. This tutorial takes a different approach by using **ONNX Runtime**, a high-performance framework that supports models from PyTorch, TensorFlow, Keras, Scikit-Learn, and more.

You won’t just download a finished model and run it.  
Instead, this guide shows you:

* How to use **a real ONNX model (MobileNetV2)**
    
* How to run **fully offline, on-device inference**
    
* How ONNX Runtime works internally in Flutter
    
* How to prepare input, process output, and build a clean Flutter structure
    

By the end, you’ll understand both **the code AND the concepts**, so you can build more advanced AI features in your own apps.

## Setting Up Your Flutter Environment

Before we dive into the code, make sure you have Flutter installed on your machine. You can follow the official Flutter installation guide here: [https://flutter.dev/docs/get-started/install](https://flutter.dev/docs/get-started/install)

Next, create a new Flutter project:

```bash
flutter create on_device_ml
cd on_device_ml
```

Add the necessary dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  flutter:
    sdk: flutter
  onnxruntime: ^0.1.0
  image: ^4.1.7
  image_picker: ^1.1.1
```

Run `flutter pub get` to install the dependencies.

## Loading the Models and Labels

First, let’s load the MobileNetV2 model and the ImageNet labels. Place the `mobilenetv2-10.onnx` model and `imagenet_classes.txt` file in the `assets` directory of your Flutter project.

Update your `pubspec.yaml` to include the assets:

```yaml
flutter:
  assets:
    - assets/model/mobilenetv2-10.onnx
    - assets/labels/imagenet_classes.txt
```

Now, let’s follow the step-by-step process to integrate and run the model.

1. ### **Loading ONNX Model (MobileNetV2) and Labels**
    
    Let’s write the code to load our assets:
    

```dart
final modelData = await rootBundle.load('assets/model/mobilenetv2-10.onnx');
final labels = await rootBundle.loadString('assets/labels/imagenet_classes.txt');
final labelList = labels.split('\n')
    .where((label) => label.trim().isNotEmpty)
    .toList();

final session = OrtSession.fromBuffer(
  modelData.buffer.asUint8List(),
  OrtSessionOptions(),
);
```

**💡 Explanation:**

* You used `rootBundle.load()` to load the model efficiently.
    
* `OrtSession.fromBuffer()` is used (faster than from a file).
    
* Labels are cleaned to remove blank lines.
    

2. ### Preprocessing The Image
    
    MobileNetV2 expects input images to be 224x224 pixels and to be normalized using specific parameters. We'll preprocess the image to meet these requirements.
    

```dart
final image = img.decodeImage(imageBytes)!;
final preprocessed = preprocessImage(image);
final input = imageToFloat32(preprocessed);
```

**💡 Explanation:**

* `img.decodeImage()` This decodes the raw image bytes into an image object.
    
* `preprocessImage()`This function performs center cropping and resizing to ensure the image is 224x224 pixels.
    
* `imageToFloat32()`This function converts the image to a float array and applies the necessary normalization.
    

3. ### Preprocessing Function
    
    Let's take a closer look at the `preprocessImage()` function:
    

```dart
img.Image preprocessImage(img.Image image) {
  const targetSize = 224;

  final width = image.width;
  final height = image.height;

  final cropSize = math.min(width, height);

  final left = (width - cropSize) ~/ 2;
  final top = (height - cropSize) ~/ 2;

  final cropped = img.copyCrop(
    image,
    x: left,
    y: top,
    width: cropSize,
    height: cropSize,
  );

  final resized = img.copyResize(
    cropped,
    width: targetSize,
    height: targetSize,
    interpolation: img.Interpolation.cubic,
  );

  return resized;
}
```

**💡 Explanation:**

* **Center Crop**: We calculate the center crop to maintain the aspect ratio of the image.
    
* **Resize**: We resize the cropped image to 224x224 pixels using cubic interpolation for high-quality results.
    

3. ### Normalization Function
    
    The `imageToFloat32()` function applies the necessary normalization:
    

```dart
Float32List imageToFloat32(img.Image image) {
  final floats = Float32List(3 * 224 * 224);

  const mean = [0.485, 0.456, 0.406];
  const std = [0.229, 0.224, 0.225];

  int pixelIndex = 0;

  for (int y = 0; y < 224; y++) {
    for (int x = 0; x < 224; x++) {
      final pixel = image.getPixel(x, y);

      final r = pixel.r / 255.0;
      final g = pixel.g / 255.0;
      final b = pixel.b / 255.0;

      floats[pixelIndex] = (r - mean[0]) / std[0];
      floats[pixelIndex + 224 * 224] = (g - mean[1]) / std[1];
      floats[pixelIndex + 2 * 224 * 224] = (b - mean[2]) / std[2];

      pixelIndex++;
    }
  }

  return floats;
}
```

**💡 Explanation:**

* **Normalization**: We convert the pixel values to the range \[0, 1\] and then apply the ImageNet mean and standard deviation normalization.
    

4. ### **Running the Model**
    
    Now, we create the input tensor and run the model:
    

```dart
final inputTensor = OrtValueTensor.createTensorWithDataList(
  input,
  [1, 3, 224, 224],
);

final output = await session.runAsync(OrtRunOptions(), {
  session.inputNames.first: inputTensor,
});
```

**💡 Explanation:**

* **Input Tensor**: We create a tensor with the preprocessed image data.
    
* `session.runAsync()`: This method runs the model asynchronously and returns the output.
    

5. ### Postprocessing the output
    
    We need to convert the model output to probabilities and get the top-K predictions:
    

```dart
final scores = (outputValue.first as List).cast<double>();
final probabilities = softmax(scores);
final topIndices = getTopKIndices(probabilities, 5);
```

**💡 Explanation:**

* **Softmax**: We apply the softmax function to convert the raw scores to probabilities.
    
* **Top-K Predictions**: We get the indices of the top 5 predictions.
    

6. ### Softmax Function
    
    Here's the softmax function:
    

```dart
List<double> softmax(List<double> logits) {
  final maxLogit = logits.reduce(math.max);
  final expValues = logits.map((x) => math.exp(x - maxLogit)).toList();
  final sumExp = expValues.reduce((a, b) => a + b);
  return expValues.map((x) => x / sumExp).toList();
}
```

**💡 Explanation:**

* **Numerical Stability**: We subtract the maximum logit value to ensure numerical stability.
    
* **Normalization**: We normalize the exponential values to get the probabilities.
    

7. ### Top-K Indices Function
    
    Here's the function to get the top-K indices:
    

```dart
List<int> getTopKIndices(List<double> values, int k) {
  final indexed = values.asMap().entries.toList();
  indexed.sort((a, b) => b.value.compareTo(a.value));
  return indexed.take(k).map((e) => e.key).toList();
}
```

**💡 Explanation:**

* **Sorting**: We sort the values in descending order and take the top K indices.
    

8. ### **Formatting the Result**
    
    Finally, we format the result and clean the labels:
    

```dart
final bestIndex = topIndices[0];
final confidence = probabilities[bestIndex];
final label = cleanLabel(labelList[bestIndex]);

if (confidence < 0.5) {
  final secondBest = topIndices.length > 1 ? labelList[topIndices[1]] : "";
  final secondConfidence = topIndices.length > 1 ? probabilities[topIndices[1]] : 0.0;
  return "$label (${(confidence * 100).toStringAsFixed(1)}%)\nAlternative: ${cleanLabel(secondBest)} (${(secondConfidence * 100).toStringAsFixed(1)}%)";
}

return "$label (${(confidence * 100).toStringAsFixed(1)}%)";
```

**💡 Explanation:**

* **Confidence Check**: If the confidence is low, we provide an alternative prediction.
    
* **Label Cleaning**: We clean the labels to remove any leading numbers or special characters.
    

9. ### Clean Label Function
    
    Here's the function to clean the labels:
    

```dart
String cleanLabel(String label) {
  final cleaned = label.replaceFirst(RegExp(r'^\d+[\.:]\s*'), '');
  return cleaned.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}
```

**💡 Explanation:**

* **Regex**: We use a regular expression to remove leading numbers and special characters.
    
* **Capitalization**: We capitalize the first letter of each word for better readability.
    

10. ### Memory Cleanup (Very Important)
    

```dart
inputTensor.release();
session.release();
```

**💡 Explanation:**

* ONNX Runtime allocates native memory.
    
* Cleaning up avoids memory leaks on real devices.
    

## Final Results

Here’s the final output of the MobileNetV2 ONNX model running on-device in Flutter:

![](https://cdn.hashnode.com/res/hashnode/image/upload/v1764000273925/c5400a35-264a-4665-80b8-1d496519c0f5.jpeg align="center")

### Full Source Code & Demo:

Github Repository: [https://github.com/PHom798/MobileNetV2-On-Device-Inference](https://github.com/PHom798/MobileNetV2-On-Device-Inference)

## Conclusion

In this blog post, we've explored how to implement an efficient on-device image classifier using Flutter and MobileNetV2. We covered advanced techniques such as softmax normalization, top-K predictions, and confidence checks to ensure robust and reliable results. By following these steps, you can build powerful on-device ML applications that provide fast and accurate predictions without compromising user privacy.

Feel free to experiment with different models and techniques to further enhance your application. Happy coding!

<div data-node-type="callout">
<div data-node-type="callout-emoji">😉</div>
<div data-node-type="callout-text"><strong>If you found this tutorial helpful</strong>, consider sharing it or leaving a comment!</div>
</div>

### [**Additio**](https://arxiv.org/abs/1801.04381)[**nal R**](https://flutter.dev/docs)[**esou**](https://arxiv.org/abs/1801.04381)[**rces**](https://onnxruntime.ai/)

* [Flutter Documentat](https://flutter.dev/docs)[ion](https://arxiv.org/abs/1801.04381)
    
* [ONNX Runtim](https://flutter.dev/docs)[e Documentation](https://onnxruntime.ai/)
    
* [MobileNetV2 Pa](https://arxiv.org/abs/1801.04381)[per](https://flutter.dev/docs)