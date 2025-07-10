import 'package:chaton/Screen/profile/edit_profile.dart';
import 'package:chaton/Screen/profile/profile.dart';
import 'package:chaton/Widget/reuseable.dart';
import 'package:flutter/material.dart';

class AnimatedAvatarCard extends StatefulWidget {
  final String name;
  final String email;
  final String avatarUrl;
  final VoidCallback? onClose;

  const AnimatedAvatarCard({
    Key? key,
    required this.name,
    required this.email,
    required this.avatarUrl,
    this.onClose,
  }) : super(key: key);

  @override
  State<AnimatedAvatarCard> createState() => _AnimatedAvatarCardState();
}

class _AnimatedAvatarCardState extends State<AnimatedAvatarCard>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late AnimationController _fadeController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );

    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.elasticOut),
        );

    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.bounceOut),
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    // Start animations
    _fadeController.forward();
    _slideController.forward();
    Future.delayed(const Duration(milliseconds: 200), () {
      _scaleController.forward();
    });
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _closeCard() {
    _scaleController.reverse();
    _slideController.reverse();
    _fadeController.reverse();
    Future.delayed(const Duration(milliseconds: 300), () {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black54,
      child: GestureDetector(
        onTap: _closeCard,
        child: SizedBox(
          width: double.infinity,
          height: double.infinity,
          child: Center(
            child: GestureDetector(
              onTap: () {}, // Prevent closing when tapping on card
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: ScaleTransition(
                    scale: _scaleAnimation,
                    child: Container(
                      margin: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF00695C), // Dark teal
                            Color(0xFF26A69A), // Medium teal
                            Color(0xFF4DB6AC), // Light teal
                          ],
                        ),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: CustomPaint(painter: CirclePatternPainter()),
                          ),
                          Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Colors.white.withOpacity(0.2),
                                width: 1.5,
                              ),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Header with close button
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Profile',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: _closeCard,
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white.withOpacity(
                                              0.2,
                                            ),
                                            borderRadius: BorderRadius.circular(
                                              10,
                                            ),
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 20,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                // Avatar section
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(60),
                                  ),
                                  child: CircleAvatar(
                                    radius: 50,
                                    backgroundColor: Colors.white,
                                    child: CircleAvatar(
                                      radius: 46,
                                      backgroundImage:
                                          widget.avatarUrl.isNotEmpty
                                          ? NetworkImage(widget.avatarUrl)
                                          : null,
                                      backgroundColor: const Color(0xFF80CBC4),
                                      child: widget.avatarUrl.isEmpty
                                          ? Text(
                                              widget.name.isNotEmpty
                                                  ? widget.name[0].toUpperCase()
                                                  : 'U',
                                              style: const TextStyle(
                                                fontSize: 32,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            )
                                          : null,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                // User info
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Column(
                                    children: [
                                      Text(
                                        reuseCapitalize(widget.name),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 24,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      const SizedBox(height: 8),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 16,
                                          vertical: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: Colors.white.withOpacity(0.2),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          widget.email,
                                          style: TextStyle(
                                            color: Colors.white.withOpacity(
                                              0.9,
                                            ),
                                            fontSize: 16,
                                          ),
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 30),

                                // Action buttons
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                  ),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: ElevatedButton.icon(
                                          onPressed: () {
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                builder: (context) =>
                                                    EditProfileScreen(),
                                              ),
                                            );
                                          },
                                          icon: const Icon(
                                            Icons.edit,
                                            size: 18,
                                          ),
                                          label: const Text('Edit Profile'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: Colors.white,
                                            foregroundColor: const Color(
                                              0xFF00695C,
                                            ),
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                    ],
                                  ),
                                ),

                                const SizedBox(height: 20),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Positioned.fill(
                    //   child: CustomPaint(painter: CirclePatternPainter()),
                    // ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// Usage example:
class AvatarCardExample extends StatefulWidget {
  @override
  _AvatarCardExampleState createState() => _AvatarCardExampleState();
}

class _AvatarCardExampleState extends State<AvatarCardExample> {
  bool _showCard = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text('Avatar Card Demo'),
      ),
      body: Stack(
        children: [
          // Your list screen content
          Center(
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _showCard = true;
                });
              },
              child: const CircleAvatar(
                radius: 40,
                backgroundColor: Colors.teal,
                child: Icon(Icons.person, size: 40, color: Colors.white),
              ),
            ),
          ),

          // Animated card overlay
          if (_showCard)
            AnimatedAvatarCard(
              name: 'John Doe',
              email: 'john.doe@example.com',
              avatarUrl: '', // Add your avatar URL here
              onClose: () {
                setState(() {
                  _showCard = false;
                });
              },
            ),
        ],
      ),
    );
  }
}
