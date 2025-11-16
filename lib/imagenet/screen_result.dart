import 'dart:io';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'mobilenet_classifier.dart';

class EnhancedClassifyPage extends StatefulWidget {
  const EnhancedClassifyPage({super.key});

  @override
  State<EnhancedClassifyPage> createState() => _EnhancedClassifyPageState();
}

class _EnhancedClassifyPageState extends State<EnhancedClassifyPage>
    with TickerProviderStateMixin {
  File? _image;
  String _result = '';
  bool _isLoading = false;

  // Enhanced Animation controllers
  late AnimationController _scanController;
  late AnimationController _pulseController;
  late AnimationController _resultController;
  late AnimationController _fadeController;
  late AnimationController _particleController;
  late AnimationController _glowController;
  late AnimationController _morphController;
  late AnimationController _rippleController;

  // Enhanced Animations
  late Animation<double> _scanAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<double> _resultSlideAnimation;
  late Animation<double> _resultFadeAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _morphAnimation;
  late Animation<double> _rippleAnimation;

  // Particle system for futuristic effect
  List<Particle> _particles = [];

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _generateParticles();
  }

  void _initializeAnimations() {
    // Core animations
    _scanController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

    _resultController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // New enhanced animations
    _particleController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..repeat(reverse: true);

    _morphController = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    _rippleController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Setup enhanced animations
    _scanAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scanController, curve: Curves.easeInOutCubic),
    );

    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.elasticInOut),
    );

    _resultSlideAnimation = Tween<double>(begin: 100.0, end: 0.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.elasticOut),
    );

    _resultFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _resultController, curve: Curves.easeInOutQuart),
    );

    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _particleController, curve: Curves.linear),
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOutSine),
    );

    _morphAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _morphController, curve: Curves.elasticOut),
    );

    _rippleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _rippleController, curve: Curves.easeOut),
    );
  }

  void _generateParticles() {
    _particles = List.generate(20, (index) => Particle());
  }

  @override
  void dispose() {
    _scanController.dispose();
    _pulseController.dispose();
    _resultController.dispose();
    _fadeController.dispose();
    _particleController.dispose();
    _glowController.dispose();
    _morphController.dispose();
    _rippleController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    // Haptic feedback with enhanced pattern
    HapticFeedback.selectionClick();
    await Future.delayed(const Duration(milliseconds: 50));
    HapticFeedback.lightImpact();

    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source);

    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = '';
        _isLoading = true;
      });

      // Start enhanced animation sequence
      _fadeController.forward();
      _scanController.repeat();
      _morphController.forward();
      _rippleController.forward();

      // Enhanced haptic feedback
      HapticFeedback.mediumImpact();

      final bytes = await picked.readAsBytes();

      // Enhanced processing simulation with realistic timing
      final startTime = DateTime.now();
      final prediction = await classifyImage(bytes);
      final elapsed = DateTime.now().difference(startTime);

      // Minimum processing time for dramatic effect
      if (elapsed.inMilliseconds < 2500) {
        await Future.delayed(
          Duration(milliseconds: 2500 - elapsed.inMilliseconds),
        );
      }

      setState(() {
        _result = prediction;
        _isLoading = false;
      });

      // Enhanced completion sequence
      _scanController.stop();
      _resultController.forward();
      _morphController.reverse();

      // Success haptic pattern
      HapticFeedback.heavyImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.lightImpact();
      await Future.delayed(const Duration(milliseconds: 100));
      HapticFeedback.lightImpact();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0E21),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A0E21),
              Color(0xFF1E1E3F),
              Color(0xFF2D1B69),
            ],
          ),
        ),
        child: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildEnhancedHeader(),
                  Expanded(child: _buildContent()),
                  _buildEnhancedBottomButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedBackground() {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        return CustomPaint(
          painter: ParticlePainter(_particles, _particleAnimation.value),
          size: Size.infinite,
        );
      },
    );
  }

  Widget _buildEnhancedHeader() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(_glowAnimation.value * 0.6),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 40,
                ),
              ),
              const SizedBox(height: 12),
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Colors.cyan,
                    Colors.blue,
                    Colors.purple,
                  ],
                ).createShader(bounds),
                child: const Text(
                  'AI Image Classifier',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2.0,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'Powered By MobileNetV2',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 14,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildContent() {
    return SingleChildScrollView(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 20),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildEnhancedImageContainer(),
            const SizedBox(height: 40),
            if (_isLoading) _buildEnhancedLoadingIndicator(),
            if (_result.isNotEmpty && !_isLoading) _buildEnhancedResult(),
          ],
        ),
      ),
    );
  }

  Widget _buildEnhancedImageContainer() {
    return AnimatedBuilder(
      animation: Listenable.merge([_fadeController, _rippleController]),
      builder: (context, child) {
        return Container(
          height: 280,
          width: double.infinity,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(25),
            boxShadow: [
              BoxShadow(
                color: Colors.cyan.withOpacity(0.3),
                blurRadius: 25,
                offset: const Offset(0, 15),
              ),
              BoxShadow(
                color: Colors.blue.withOpacity(0.2),
                blurRadius: 40,
                offset: const Offset(0, 25),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(25),
            child: Stack(
              children: [
                if (_image != null)
                  Opacity(
                    opacity: _fadeController.value,
                    child: Image.file(
                      _image!,
                      height: 280,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    ),
                  )
                else
                  _buildEnhancedPlaceholder(),
                if (_isLoading) _buildEnhancedScanOverlay(),
                if (_rippleController.isAnimating) _buildRippleEffect(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedPlaceholder() {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        // Ensure all opacity values are within valid range
        final glowValue = math.min(1.0, math.max(0.0, _glowAnimation.value));

        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.cyan.withOpacity(0.1 * glowValue),
                Colors.blue.withOpacity(0.1 * glowValue),
                Colors.purple.withOpacity(0.1 * glowValue),
              ],
            ),
            border: Border.all(
              color: Colors.cyan.withOpacity(0.3 * glowValue),
              width: 2,
            ),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ShaderMask(
                  shaderCallback: (bounds) => LinearGradient(
                    colors: [Colors.cyan, Colors.blue],
                  ).createShader(bounds),
                  child: Icon(
                    Icons.smart_toy_outlined,
                    size: 100,
                    color: Colors.white.withOpacity(math.min(1.0, math.max(0.5, glowValue))),
                  ),
                ),
                const SizedBox(height: 25),
                Text(
                  'Upload Image for AI Analysis',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.8),
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Neural networks ready to classify',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.5),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildRippleEffect() {
    return AnimatedBuilder(
      animation: _rippleAnimation,
      builder: (context, child) {
        // Ensure opacity stays within valid range
        final opacity = math.min(1.0, math.max(0.0, 1 - _rippleAnimation.value));

        return Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(25),
              border: Border.all(
                color: Colors.cyan.withOpacity(opacity),
                width: 3,
              ),
            ),
            transform: Matrix4.identity()
              ..scale(1 + _rippleAnimation.value * 0.1),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedScanOverlay() {
    return AnimatedBuilder(
      animation: Listenable.merge([_scanAnimation, _morphAnimation]),
      builder: (context, child) {
        return Stack(
          children: [
            // Neural network grid overlay
            Container(
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.8),
                borderRadius: BorderRadius.circular(25),
              ),
              child: CustomPaint(
                painter: NeuralGridPainter(_morphAnimation.value),
                size: Size.infinite,
              ),
            ),
            // Enhanced scanning beam
            Positioned(
              top: (280 - 4) * _scanAnimation.value,
              left: 0,
              right: 0,
              child: Container(
                height: 4,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      Colors.cyan.withOpacity(0.5),
                      Colors.cyan,
                      Colors.white,
                      Colors.cyan,
                      Colors.cyan.withOpacity(0.5),
                      Colors.transparent,
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan,
                      blurRadius: 15,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            ),
            // Enhanced corner indicators
            ..._buildEnhancedCornerBrackets(),
            // Processing indicator
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.psychology,
                    color: Colors.cyan,
                    size: 60,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'NEURAL PROCESSING',
                    style: TextStyle(
                      color: Colors.cyan,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2.0,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildEnhancedCornerBrackets() {
    return [
      Positioned(top: 25, left: 25, child: _buildEnhancedCorner(0)),
      Positioned(top: 25, right: 25, child: _buildEnhancedCorner(math.pi / 2)),
      Positioned(bottom: 25, right: 25, child: _buildEnhancedCorner(math.pi)),
      Positioned(bottom: 25, left: 25, child: _buildEnhancedCorner(3 * math.pi / 2)),
    ];
  }

  Widget _buildEnhancedCorner(double angle) {
    return AnimatedBuilder(
      animation: _scanAnimation,
      builder: (context, child) {
        // Ensure opacity stays within valid range (0.0 to 1.0)
        final opacity = math.min(1.0, math.max(0.3, _scanAnimation.value * 0.7 + 0.3));

        return Transform.rotate(
          angle: angle,
          child: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(
                  color: Colors.cyan.withOpacity(opacity),
                  width: 4,
                ),
                left: BorderSide(
                  color: Colors.cyan.withOpacity(opacity),
                  width: 4,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedLoadingIndicator() {
    return Column(
      children: [
        AnimatedBuilder(
          animation: Listenable.merge([_pulseAnimation, _glowAnimation]),
          builder: (context, child) {
            // Ensure all values are within valid ranges
            final pulseValue = math.min(1.5, math.max(0.8, _pulseAnimation.value));
            final glowValue = math.min(1.0, math.max(0.0, _glowAnimation.value));

            return Transform.scale(
              scale: pulseValue,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      Colors.cyan.withOpacity(glowValue),
                      Colors.blue.withOpacity(glowValue * 0.6),
                      Colors.purple.withOpacity(glowValue * 0.3),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.cyan.withOpacity(glowValue * 0.8),
                      blurRadius: 30,
                      spreadRadius: 10,
                    ),
                  ],
                ),
                child: Stack(
                  children: [
                    Center(
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 4,
                        backgroundColor: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    Center(
                      child: Icon(
                        Icons.memory,
                        color: Colors.white,
                        size: 30,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 25),
        AnimatedBuilder(
          animation: _glowAnimation,
          builder: (context, child) {
            final glowValue = math.min(1.0, math.max(0.0, _glowAnimation.value));

            return ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [
                  Colors.cyan.withOpacity(glowValue),
                  Colors.blue.withOpacity(glowValue),
                ],
              ).createShader(bounds),
              child: const Text(
                'Deep Learning Analysis...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 1.0,
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Text(
          'Processing neural pathways',
          style: TextStyle(
            color: Colors.white.withOpacity(0.6),
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildEnhancedResult() {
    final parts = _result.split(' (');
    final label = parts[0];
    final confidence = parts.length > 1 ? '(${parts[1]}' : '';

    return AnimatedBuilder(
      animation: _resultController,
      builder: (context, child) {
        return Opacity(
          opacity: _resultFadeAnimation.value,
          child: Transform.translate(
            offset: Offset(0, _resultSlideAnimation.value),
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: [
                    Colors.green.withOpacity(0.3),
                    Colors.cyan.withOpacity(0.3),
                    Colors.blue.withOpacity(0.3),
                  ],
                ),
                border: Border.all(
                  color: Colors.green.withOpacity(0.7),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.green.withOpacity(0.4),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.green.withOpacity(0.6),
                          blurRadius: 20,
                          spreadRadius: 5,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.verified,
                      color: Colors.green,
                      size: 50,
                    ),
                  ),
                  const SizedBox(height: 15),
                  ShaderMask(
                    shaderCallback: (bounds) => LinearGradient(
                      colors: [Colors.white, Colors.green.shade200],
                    ).createShader(bounds),
                    child: Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  if (confidence.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      confidence,
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  const SizedBox(height: 10),
                  Text(
                    'Classification Complete',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.6),
                      fontSize: 14,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildEnhancedBottomButtons() {
    return Container(
      padding: const EdgeInsets.all(25),
      child: Row(
        children: [
          Expanded(
            child: _buildEnhancedActionButton(
              icon: Icons.camera_alt_rounded,
              label: 'Camera',
              onPressed: () => _pickImage(ImageSource.camera),
              gradient: [
                const Color(0xFFFF6B6B),
                const Color(0xFFFF8E53),
                const Color(0xFFFF6B9D),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: _buildEnhancedActionButton(
              icon: Icons.photo_library_rounded,
              label: 'Gallery',
              onPressed: () => _pickImage(ImageSource.gallery),
              gradient: [
                const Color(0xFF4ECDC4),
                const Color(0xFF44A08D),
                const Color(0xFF096DD9),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required List<Color> gradient,
  }) {
    return AnimatedBuilder(
      animation: _glowAnimation,
      builder: (context, child) {
        // Ensure glow values are within valid range
        final glowValue = math.min(1.0, math.max(0.0, _glowAnimation.value));

        return Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                gradient: LinearGradient(
                  colors: gradient,
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: gradient[0].withOpacity(0.4 * glowValue),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  BoxShadow(
                    color: gradient[1].withOpacity(0.2 * glowValue),
                    blurRadius: 25,
                    offset: const Offset(0, 15),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon, color: Colors.white, size: 24),
                  const SizedBox(width: 12),
                  Text(
                    label,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Particle class for floating animation effect
class Particle {
  late double x;
  late double y;
  late double speed;
  late double opacity;
  late double size;

  Particle() {
    reset();
  }

  void reset() {
    x = math.Random().nextDouble();
    y = math.Random().nextDouble();
    speed = 0.001 + math.Random().nextDouble() * 0.002;
    opacity = 0.1 + math.Random().nextDouble() * 0.3;
    size = 1 + math.Random().nextDouble() * 3;
  }

  void update() {
    y -= speed;
    if (y < 0) {
      reset();
      y = 1.0;
    }
  }
}

// Custom painter for floating particles
class ParticlePainter extends CustomPainter {
  final List<Particle> particles;
  final double animationValue;

  ParticlePainter(this.particles, this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();

    for (var particle in particles) {
      particle.update();

      paint.color = Colors.cyan.withOpacity(particle.opacity);
      canvas.drawCircle(
        Offset(
          particle.x * size.width,
          particle.y * size.height,
        ),
        particle.size,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}

// Custom painter for neural network grid effect
class NeuralGridPainter extends CustomPainter {
  final double animationValue;

  NeuralGridPainter(this.animationValue);

  @override
  void paint(Canvas canvas, Size size) {
    // Ensure animation value is within valid range
    final safeAnimationValue = math.min(1.0, math.max(0.0, animationValue));

    final paint = Paint()
      ..color = Colors.cyan.withOpacity(0.3 * safeAnimationValue)
      ..strokeWidth = 1;

    final gridSize = 30.0;

    // Draw grid lines
    for (double i = 0; i <= size.width; i += gridSize) {
      canvas.drawLine(
        Offset(i, 0),
        Offset(i, size.height),
        paint,
      );
    }

    for (double i = 0; i <= size.height; i += gridSize) {
      canvas.drawLine(
        Offset(0, i),
        Offset(size.width, i),
        paint,
      );
    }

    // Draw connection nodes
    paint.color = Colors.cyan.withOpacity(0.6 * safeAnimationValue);
    for (double x = gridSize; x < size.width; x += gridSize * 2) {
      for (double y = gridSize; y < size.height; y += gridSize * 2) {
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}