<div align="center">

# 🧠 MobileNetV2 On-Device Inference
### Real-Time Image Classification Powered by ONNX Runtime

<img src="https://readme-typing-svg.demolab.com?font=Fira+Code&weight=600&size=28&duration=3000&pause=1000&color=FF6F00&center=true&vCenter=true&width=900&lines=On-Device+AI+%7C+Zero+Server+Calls;MobileNetV2+%7C+Lightning+Fast;Privacy-First+Machine+Learning;1000+ImageNet+Classes" alt="Typing SVG" />

<br>

[![Made with Flutter](https://img.shields.io/badge/Made%20with-Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)](https://flutter.dev)
[![ONNX Runtime](https://img.shields.io/badge/ONNX-Runtime-005CED?style=for-the-badge&logo=onnx&logoColor=white)](https://onnxruntime.ai)
[![MobileNetV2](https://img.shields.io/badge/Model-MobileNetV2-FF6F00?style=for-the-badge&logo=tensorflow&logoColor=white)](https://arxiv.org/abs/1801.04381)
[![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)](https://dart.dev)

<br>

![Version](https://img.shields.io/badge/version-1.0.0-FF6F00?style=flat-square)
![Platform](https://img.shields.io/badge/platform-Android%20%7C%20iOS-lightgrey?style=flat-square)
![Model Size](https://img.shields.io/badge/model%20size-~14MB-green?style=flat-square)
![Status](https://img.shields.io/badge/status-Production%20Ready-success?style=flat-square)

---

### 🚀 Bringing Computer Vision to Your Pocket
*Complete on-device image classification with zero latency and maximum privacy*

</div>

---

## ✨ Features

### 🎯 Core Capabilities
- **🔥 MobileNetV2 Integration** - Optimized CNN architecture running entirely on-device
- **⚡ ONNX Runtime** - High-performance inference engine for mobile platforms
- **📸 ImageNet Classification** - Recognizes 1000+ object categories with high accuracy
- **🎨 Production-Ready Preprocessing** - ImageNet normalization and center crop
- **🏆 Top-K Predictions** - Configurable multi-class prediction output
- **✅ Confidence Thresholding** - Smart fallback for low-confidence predictions
- **🔒 Privacy-First** - All inference happens locally, no data leaves device
- **📱 Cross-Platform** - Runs on Android and iOS with Flutter

### 🛠️ Technical Highlights
- **Preprocessing Pipeline**: ImageNet-standard normalization (mean/std)
- **Input Processing**: Center crop to 224x224 model input size
- **Output Processing**: Softmax activation for probability distribution
- **Confidence Filtering**: Configurable threshold with fallback handling
- **Top-K Selection**: Returns top N predictions with scores

---

## 🏗️ Architecture

```
┌─────────────────┐
│  Camera/Gallery │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│ Image Loading   │
│  & Decoding     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Center Crop    │
│   (224x224)     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   ImageNet      │
│ Normalization   │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  MobileNetV2    │
│  ONNX Model     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│    Softmax      │
│   Activation    │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│   Top-K + CI    │
│   Filtering     │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  Display Results│
└─────────────────┘
```

---

## 📦 Installation

### Prerequisites
```yaml
dependencies:
  flutter:
    sdk: flutter
  onnxruntime: ^1.15.0  # Or latest version
  image: ^4.0.0
```

### Setup Steps

1. **Clone the repository**
```bash
git clone https://github.com/yourusername/mobilenetv2-flutter.git
cd mobilenetv2-flutter
```

2. **Install dependencies**
```bash
flutter pub get
```

3. **Add the ONNX model**
   - Download MobileNetV2 ONNX model
   - Place in `assets/models/mobilenetv2.onnx`
   - Add to `pubspec.yaml`:
   ```yaml
   flutter:
     assets:
       - assets/models/mobilenetv2.onnx
       - assets/imagenet_classes.txt
   ```

4. **Run the app**
```bash
flutter run
```

---

## 🎮 Usage

### Basic Implementation

```dart
import 'package:onnxruntime/onnxruntime.dart';

class ImageClassifier {
  late OrtSession session;
  
  Future<void> initialize() async {
    // Load model
    final modelBytes = await rootBundle.load('assets/models/mobilenetv2.onnx');
    session = OrtSession.fromBuffer(modelBytes.buffer.asUint8List());
  }
  
  Future<List<Prediction>> classify(String imagePath) async {
    // 1. Load and preprocess image
    final preprocessed = await preprocessImage(imagePath);
    
    // 2. Run inference
    final inputs = {'input': OrtValueTensor.createTensorWithDataList(
      preprocessed,
      [1, 3, 224, 224],
    )};
    
    final outputs = await session.runAsync(
      OrtRunOptions(),
      inputs,
    );
    
    // 3. Apply softmax
    final logits = outputs[0]?.value as List<List<double>>;
    final probabilities = softmax(logits[0]);
    
    // 4. Get Top-K with confidence threshold
    return getTopKPredictions(probabilities, k: 5, threshold: 0.1);
  }
}
```

### Preprocessing Pipeline

```dart
Future<List<double>> preprocessImage(String path) async {
  final img = decodeImage(File(path).readAsBytesSync())!;
  
  // Center crop to 224x224
  final cropped = copyCrop(img, 
    x: (img.width - 224) ~/ 2,
    y: (img.height - 224) ~/ 2,
    width: 224,
    height: 224,
  );
  
  // ImageNet normalization
  final mean = [0.485, 0.456, 0.406];
  final std = [0.229, 0.224, 0.225];
  
  List<double> normalized = [];
  for (var c = 0; c < 3; c++) {
    for (var y = 0; y < 224; y++) {
      for (var x = 0; x < 224; x++) {
        final pixel = cropped.getPixel(x, y);
        final value = (pixel[c] / 255.0 - mean[c]) / std[c];
        normalized.add(value);
      }
    }
  }
  
  return normalized;
}
```

---

## 📊 Model Details

| Property | Value |
|----------|-------|
| **Architecture** | MobileNetV2 |
| **Input Size** | 224 × 224 × 3 |
| **Parameters** | ~3.5M |
| **Model Size** | ~14MB |
| **Classes** | 1000 (ImageNet) |
| **Top-1 Accuracy** | ~71.8% |
| **Top-5 Accuracy** | ~90.3% |
| **Inference Time** | 20-50ms (device dependent) |

---

## 🔧 Configuration

### Adjustable Parameters

```dart
class ModelConfig {
  static const int inputSize = 224;
  static const int topK = 5;
  static const double confidenceThreshold = 0.1;
  static const List<double> imagenetMean = [0.485, 0.456, 0.406];
  static const List<double> imagenetStd = [0.229, 0.224, 0.225];
}
```

---


## 🌟 Key Advantages

### 🔒 Privacy & Security
- **100% On-Device** - No internet required
- **Zero Data Transmission** - Images never leave device
- **GDPR Compliant** - No external data processing

### ⚡ Performance
- **Low Latency** - Instant results without network delay
- **Offline First** - Works without connectivity
- **Efficient** - Optimized for mobile CPUs

### 💰 Cost-Effective
- **No API Costs** - Zero inference fees
- **Scalable** - No server infrastructure needed
- **Sustainable** - Reduced carbon footprint

---

## 📱 Screenshots

*Add your app screenshots here*

---


## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

---

## 🙏 Acknowledgments

- **MobileNetV2** - [Sandler et al., 2018](https://arxiv.org/abs/1801.04381)
- **ONNX Runtime** - Microsoft's cross-platform inference engine
- **ImageNet** - Dataset and pretrained weights
- **Flutter Team** - Amazing cross-platform framework

---

## 💬 Connect & Support

For questions, feedback, or collaborations:

<div align="center">

[![GitHub](https://img.shields.io/badge/GitHub-Follow-181717?logo=github&logoColor=white)](https://github.com/PHom798)
[![Twitter](https://img.shields.io/badge/Twitter-Follow-1DA1F2?logo=twitter&logoColor=white)](https://x.com/KishanP07684084)
[![LinkedIn](https://img.shields.io/badge/LinkedIn-Connect-0077B5?logo=linkedin&logoColor=white)](https://www.linkedin.com/in/hom-bdr-pathak-01a3bb210)
[![Email](https://img.shields.io/badge/Email-Contact-D14836?logo=gmail&logoColor=white)](pathakhom17@gmail.com)

</div>

---

<div align="center">

### ⭐ Star this repo if you find it useful!

**Made with ❤️ and Flutter**


![Footer](https://capsule-render.vercel.app/api?type=waving&color=gradient&customColorList=6,11,20&height=100&section=footer)

</div>
