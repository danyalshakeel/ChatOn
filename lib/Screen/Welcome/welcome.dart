import 'package:chaton/Widget/reuseable.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with TickerProviderStateMixin {
  late final AnimationController _mainController;
  late final AnimationController _confettiController;
  late final AnimationController _pulseController;
  
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _rotationAnimation;
  late final Animation<double> _pulseAnimation;
  
  final List<ConfettiParticle> _confettiParticles = [];

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _generateConfetti();
    _startAnimations();
  }

  void _setupAnimations() {
    // Main animation controller
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    
    // Confetti animation controller
    _confettiController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    
    // Pulse animation controller
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    
    // Fade animation
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
    ));
    
    // Slide animation
    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.2, 0.7, curve: Curves.easeOutCubic),
    ));
    
    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.6, curve: Curves.elasticOut),
    ));
    
    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.8, curve: Curves.easeOutCubic),
    ));
    
    // Pulse animation
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
  }

  void _generateConfetti() {
    for (int i = 0; i < 50; i++) {
      _confettiParticles.add(ConfettiParticle());
    }
  }

  void _startAnimations() {
    _mainController.forward();
    _confettiController.repeat();
  }

  @override
  void dispose() {
    _mainController.dispose();
    _confettiController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.teal.shade300,
              Colors.teal.shade500,
              Colors.teal.shade700,
            ],
          ),
        ),
        child: Stack(
          children: [
            // Animated background circles
            ..._buildBackgroundCircles(),
            
            // Confetti
            AnimatedBuilder(
              animation: _confettiController,
              builder: (context, child) {
                return CustomPaint(
                  size: size,
                  painter: ConfettiPainter(
                    particles: _confettiParticles,
                    animation: _confettiController.value,
                  ),
                );
              },
            ),
            
            // Main content
            Center(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated checkmark circle
                      AnimatedBuilder(
                        animation: _mainController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _scaleAnimation.value,
                            child: Transform.rotate(
                              angle: _rotationAnimation.value,
                              child: Container(
                                width: 120,
                                height: 120,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 20,
                                      offset: const Offset(0, 10),
                                    ),
                                  ],
                                ),
                                child: ScaleTransition(
                                  scale: _pulseAnimation,
                                  child: Icon(
                                    Icons.check_circle,
                                    size: 80,
                                    color: Colors.teal.shade600,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 40),
                      
                      // Welcome text
                      AnimatedBuilder(
                        animation: _mainController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Transform.translate(
                              offset: Offset(0, _slideAnimation.value),
                              child: Column(
                                children: [
                                  Text(
                                    'Welcome to ChatOn!',
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          color: Colors.black.withOpacity(0.3),
                                          offset: const Offset(0, 3),
                                          blurRadius: 6,
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Your account has been created successfully',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white.withOpacity(0.9),
                                      height: 1.5,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 20,
                                      vertical: 10,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          Icons.celebration,
                                          color: Colors.yellow.shade300,
                                          size: 20,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Let\'s get started!',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Features list
                      AnimatedBuilder(
                        animation: _mainController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Column(
                              children: [
                                _buildFeatureItem(
                                  icon: Icons.chat_bubble_outline,
                                  title: 'Start Chatting',
                                  subtitle: 'Connect with friends instantly',
                                  delay: 0.8,
                                ),
                                // const SizedBox(height: 16),
                                // _buildFeatureItem(
                                //   icon: Icons.group_outlined,
                                //   title: 'Join Communities',
                                //   subtitle: 'Find people with similar interests',
                                //   delay: 0.9,
                                // ),
                                const SizedBox(height: 16),
                                _buildFeatureItem(
                                  icon: Icons.security_outlined,
                                  title: 'Secure & Private',
                                  subtitle: 'Your conversations are encrypted',
                                  delay: 1.0,
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      
                      const SizedBox(height: 60),
                      
                      // Get Started button
                      AnimatedBuilder(
                        animation: _mainController,
                        builder: (context, child) {
                          return FadeTransition(
                            opacity: _fadeAnimation,
                            child: Transform.scale(
                              scale: _scaleAnimation.value,
                              child: Container(
                                width: double.infinity,
                                height: 60,
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.white,
                                      Colors.white.withOpacity(0.9),
                                    ],
                                  ),
                                  borderRadius: BorderRadius.circular(30),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withOpacity(0.2),
                                      blurRadius: 15,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.pushReplacementNamed(context, '/home');
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.transparent,
                                    shadowColor: Colors.transparent,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Get Started',
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.teal.shade700,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_forward_rounded,
                                        color: Colors.teal.shade700,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required double delay,
  }) {
    return AnimatedBuilder(
      animation: _mainController,
      builder: (context, child) {
        final animation = CurvedAnimation(
          parent: _mainController,
          curve: Interval(delay, 1.0, curve: Curves.easeOut),
        );
        
        return FadeTransition(
          opacity: animation,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - animation.value)),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Colors.white.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      icon,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
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

  List<Widget> _buildBackgroundCircles() {
    return [
      Positioned(
        top: -100,
        right: -100,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.1),
                ),
              ),
            );
          },
        ),
      ),
      Positioned(
        bottom: -150,
        left: -150,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (context, child) {
            return Transform.scale(
              scale: 1.2 - (_pulseAnimation.value - 1),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withOpacity(0.08),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}

// Confetti particle class
class ConfettiParticle {
  late double x;
  late double y;
  late double vx;
  late double vy;
    late double size;
  late Color color;
  late double rotation;
  late double rotationSpeed;

  ConfettiParticle() {
    final random = math.Random();
    x = random.nextDouble();
    y = random.nextDouble() * 0.5 - 0.5; // Start from top half
    vx = (random.nextDouble() - 0.5) * 2;
    vy = random.nextDouble() * 3 + 1;
    size = random.nextDouble() * 10 + 5;
    rotation = random.nextDouble() * 2 * math.pi;
    rotationSpeed = (random.nextDouble() - 0.5) * 0.2;
    
    // Random colors for confetti
    final colors = [
      Colors.yellow.shade400,
      Colors.pink.shade400,
      Colors.blue.shade400,
      Colors.green.shade400,
      Colors.orange.shade400,
      Colors.purple.shade400,
    ];
    color = colors[random.nextInt(colors.length)];
  }

  void update(double animation) {
    y += vy * 0.01;
    x += vx * 0.001;
    rotation += rotationSpeed;
    
    // Reset particle when it goes off screen
    if (y > 1.2) {
      y = -0.2;
      x = math.Random().nextDouble();
    }
  }
}

// Confetti painter
class ConfettiPainter extends CustomPainter {
  final List<ConfettiParticle> particles;
  final double animation;

  ConfettiPainter({
    required this.particles,
    required this.animation,
  });

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      particle.update(animation);
      
      final paint = Paint()
        ..color = particle.color.withOpacity(0.8)
        ..style = PaintingStyle.fill;
      
      canvas.save();
      canvas.translate(
        particle.x * size.width,
        particle.y * size.height,
      );
      canvas.rotate(particle.rotation);
      
      // Draw rectangle confetti
      canvas.drawRect(
        Rect.fromCenter(
          center: Offset.zero,
          width: particle.size,
          height: particle.size * 0.6,
        ),
        paint,
      );
      
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}