import 'dart:async';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _particleController;
  late AnimationController _rotationController;
  late AnimationController _pulseController;

  late Animation<double> _logoSlideAnimation;
  late Animation<double> _logoFadeAnimation;
  late Animation<double> _textSlideAnimation;
  late Animation<double> _textFadeAnimation;
  late Animation<double> _particleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    // Logo Animation Controller
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    // Text Animation Controller
    _textController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    // Particle Animation Controller
    _particleController = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    );

    // Rotation Animation Controller
    _rotationController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );

    // Pulse Animation Controller
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );

    // Logo Animations - Slide from top with bounce
    _logoSlideAnimation = Tween<double>(
      begin: -300.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: Curves.bounceOut,
    ));

    _logoFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _logoController,
      curve: const Interval(0.0, 0.7, curve: Curves.easeInOut),
    ));

    // Text Animations - Slide from bottom with elastic
    _textSlideAnimation = Tween<double>(
      begin: 100.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.elasticOut,
    ));

    _textFadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _textController,
      curve: Curves.easeIn,
    ));

    // Particle floating animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _particleController,
      curve: Curves.linear,
    ));

    // Rotation animation for background elements
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    // Pulse animation for logo
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start animations sequence
    _startAnimations();

    // Timer 4 detik lalu pindah ke halaman login
    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    });
  }

  void _startAnimations() async {
    // Start continuous animations
    _rotationController.repeat();
    _particleController.repeat();
    _pulseController.repeat(reverse: true);

    // Sequence animations
    await Future.delayed(const Duration(milliseconds: 300));
    _logoController.forward();

    await Future.delayed(const Duration(milliseconds: 800));
    _textController.forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _particleController.dispose();
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Widget _buildFloatingParticle(
      double top, double left, double size, Color color, double delay) {
    return AnimatedBuilder(
      animation: _particleAnimation,
      builder: (context, child) {
        final animationValue = (_particleAnimation.value + delay) % 1.0;
        return Positioned(
          top: top + (math.sin(animationValue * 2 * math.pi) * 20),
          left: left + (math.cos(animationValue * 2 * math.pi) * 15),
          child: Opacity(
            opacity: (math.sin(animationValue * math.pi) * 0.8).abs(),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: color.withOpacity(0.6),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildRotatingRing(
      double size, double strokeWidth, Color color, double speed) {
    return AnimatedBuilder(
      animation: _rotationAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rotationAnimation.value * speed,
          child: Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: color.withOpacity(0.3),
                width: strokeWidth,
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    final isTablet = screenSize.width > 600;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF018175),
              Color(0xFF10b68d),
              Color(0xFF4fd1c7),
            ],
          ),
        ),
        child: Stack(
          children: [
            // Floating Particles Background
            _buildFloatingParticle(100, 50, 8, Colors.white, 0.0),
            _buildFloatingParticle(
                200, screenSize.width - 80, 12, Colors.white70, 0.3),
            _buildFloatingParticle(350, 100, 6, Colors.white60, 0.6),
            _buildFloatingParticle(500, screenSize.width - 120, 10,
                Colors.white.withOpacity(0.8), 0.9),
            _buildFloatingParticle(150, screenSize.width * 0.7, 14,
                Colors.white.withOpacity(0.5), 0.2),
            _buildFloatingParticle(400, 40, 9, Colors.white70, 0.7),

            // Main Content
            SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Rotating Rings Background
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildRotatingRing(250, 2, Colors.white, 0.5),
                        _buildRotatingRing(200, 3, Colors.white, -0.8),
                        _buildRotatingRing(300, 1, Colors.white, 1.2),

                        // Logo with Slide Animation
                        AnimatedBuilder(
                          animation: _logoController,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _logoSlideAnimation.value),
                              child: Opacity(
                                opacity: _logoFadeAnimation.value,
                                child: AnimatedBuilder(
                                  animation: _pulseAnimation,
                                  builder: (context, child) {
                                    return Transform.scale(
                                      scale: _pulseAnimation.value,
                                      child: Container(
                                        width: isTablet ? 180 : 140,
                                        height: isTablet ? 180 : 140,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.white.withOpacity(0.15),
                                          boxShadow: [
                                            BoxShadow(
                                              color:
                                                  Colors.black.withOpacity(0.2),
                                              blurRadius: 30,
                                              spreadRadius: 10,
                                            ),
                                            BoxShadow(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              blurRadius: 20,
                                              spreadRadius: -5,
                                            ),
                                          ],
                                        ),
                                        child: Padding(
                                          padding: const EdgeInsets.all(25),
                                          child: Image.asset(
                                            'assets/images/Logo.png',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    SizedBox(height: screenSize.height * 0.08),

                    // App Name with Slide Animation
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Transform.translate(
                          offset: Offset(0, _textSlideAnimation.value),
                          child: Opacity(
                            opacity: _textFadeAnimation.value,
                            child: Column(
                              children: [
                                // Main Title with Gradient Text Effect
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      const LinearGradient(
                                    colors: [Colors.white, Colors.white70],
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                  ).createShader(bounds),
                                  child: Text(
                                    'GiziKu',
                                    style: TextStyle(
                                      fontSize: isTablet ? 48 : 42,
                                      fontWeight: FontWeight.w900,
                                      color: Colors.white,
                                      letterSpacing: 3,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.4),
                                          offset: const Offset(3, 3),
                                          blurRadius: 8,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),

                                // Subtitle with typewriter effect
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(25),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    'Aplikasi Pemantauan Gizi Anak',
                                    style: TextStyle(
                                      fontSize: isTablet ? 18 : 16,
                                      color: Colors.white.withOpacity(0.95),
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 1,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: screenSize.height * 0.08),

                    // Loading Indicator with enhanced animation
                    AnimatedBuilder(
                      animation: _textController,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _textFadeAnimation.value * 0.8,
                          child: Column(
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                children: [
                                  // Outer rotating circle
                                  AnimatedBuilder(
                                    animation: _rotationController,
                                    builder: (context, child) {
                                      return Transform.rotate(
                                        angle: _rotationAnimation.value,
                                        child: Container(
                                          width: 50,
                                          height: 50,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            border: Border.all(
                                              color:
                                                  Colors.white.withOpacity(0.3),
                                              width: 2,
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                  // Inner loading indicator
                                  SizedBox(
                                    width: isTablet ? 32 : 28,
                                    height: isTablet ? 32 : 28,
                                    child: CircularProgressIndicator(
                                      valueColor:
                                          const AlwaysStoppedAnimation<Color>(
                                              Colors.white),
                                      strokeWidth: 3,
                                      backgroundColor:
                                          Colors.white.withOpacity(0.2),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 20),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 6),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(15),
                                ),
                                child: Text(
                                  'Memuat aplikasi...',
                                  style: TextStyle(
                                    fontSize: isTablet ? 16 : 14,
                                    color: Colors.white.withOpacity(0.9),
                                    fontWeight: FontWeight.w400,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
