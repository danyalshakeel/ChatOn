import 'package:chaton/Screen/chat/chat_list.dart';
import 'package:chaton/Screen/profile/profile.dart';
import 'package:chaton/Widget/reuseable.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  int _selectedIndex = 0;
  late final AnimationController _fabController;
  late final Animation<double> _fabScale;

  final List<Widget> _pages = [ChatList(), ProfileScreen()];

  @override
  void initState() {
    super.initState();
    _fabController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    // Define scale animation from 0 to 1
    _fabScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _fabController, curve: Curves.easeOutBack),
    );
    // Start hidden and then show if on home
    if (_selectedIndex == 0) {
      _fabController.forward();
    }
  }

  @override
  void dispose() {
    _fabController.dispose();
    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 0) {
      _fabController.forward(from: 0.0);
    } else {
      _fabController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Page transition using AnimatedSwitcher
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 400),
        transitionBuilder: (child, animation) {
          return FadeTransition(opacity: animation, child: child);
        },
        child: _pages[_selectedIndex],
      ),

      bottomNavigationBar: SizedBox(
        height: 100,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Animated background container
            Positioned(
              bottom: 50,
              left: 20,
              right: 20,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _NavItem(
                      icon: Icons.home,
                      isSelected: _selectedIndex == 0,
                      onTap: () => _onItemTapped(0),
                    ),
                    const SizedBox(width: 60),
                    _NavItem(
                      icon: Icons.person,
                      isSelected: _selectedIndex == 1,
                      onTap: () => _onItemTapped(1),
                    ),
                  ],
                ),
              ),
            ),

            // Animated FAB for Create Chat
            if (_selectedIndex == 0)
              Positioned(
                top: -30,
                left: 0,
                right: 0,
                child: ScaleTransition(
                  scale: _fabScale,
                  child: Center(
                    child: GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/searchUser');
                      },
                      child: Container(
                        height: 45,
                        width: 100,
                        decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.circular(30),
                          // shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: Colors.black26, blurRadius: 8),
                          ],
                        ),
                        child: const Icon(Icons.chat, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? greenColor.withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          size: isSelected ? 30 : 24,
          color: isSelected ? greenColor : Colors.grey[700],
        ),
      ),
    );
  }
}
