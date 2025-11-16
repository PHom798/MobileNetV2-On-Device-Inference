import 'package:flutter/material.dart';
import 'imagenet/screen_result.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image Classifier',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'SF Pro Display',
      ),
      home:EnhancedClassifyPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}