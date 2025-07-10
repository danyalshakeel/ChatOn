import 'package:chaton/Model/user_model.dart';
import 'package:chaton/Screen/Search/searchUser_screen.dart';
import 'package:chaton/Screen/profile/edit_profile.dart';
import 'package:chaton/Services/auth_services.dart';
import 'package:chaton/Services/chat_services.dart';
import 'package:chaton/Services/user_services.dart';
import 'package:chaton/Widget/reuseable.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  final AuthServices _auth = AuthServices();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.1, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _animationController,
            curve: Curves.easeOutCubic,
          ),
        );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _onOptionTap(String route) async {
    // Add haptic feedback
    // HapticFeedback.lightImpact();

    switch (route) {
      case 'edit':
        Navigator.push(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) =>
                EditProfileScreen(),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(1.0, 0.0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  );
                },
          ),
        );
        break;
      case 'settings':
        _showComingSoonDialog('Settings');
        break;
      case 'notifications':
        _showComingSoonDialog('Notifications');
        break;
      case 'privacy':
        _showComingSoonDialog('Privacy & Security');
        break;
      case 'help':
        _showComingSoonDialog('Help & Support');
        break;
      case 'friends':
        _showComingSoonDialog('Friends');
        break;
      case 'saved':
        _showComingSoonDialog('Saved Messages');
        break;
      case 'theme':
        _showComingSoonDialog('Theme Settings');
        break;
      case 'storage':
        _showComingSoonDialog('Storage & Data');
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Opening $route...'),
            backgroundColor: greenColor,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        );
    }
  }

  void _showComingSoonDialog(String feature) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.construction, color: Colors.orange),
              SizedBox(width: 10),
              Text('Coming Soon', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Text(
            '$feature feature is under development and will be available soon!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('OK', style: TextStyle(color: greenColor)),
            ),
          ],
        );
      },
      // barrierDismissible: false,
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Row(
            children: [
              Icon(Icons.logout, color: Colors.red),
              SizedBox(width: 10),
              Text('Logout', style: TextStyle(fontSize: 18)),
            ],
          ),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _auth.signOut();
                Navigator.pushReplacementNamed(context, '/signin');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Logout', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    final curUserDetail = DatabaseServices().getUser(user!.uid);
    final chats = ChatServices().fetchUserChats(user.uid);

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: CustomScrollView(
            physics: BouncingScrollPhysics(),
            slivers: [
              // Modern Header with Gradient
              SliverAppBar(
                pinned: true,
                expandedHeight: 300,
                backgroundColor: Colors.teal,
                elevation: 0,

                flexibleSpace: FlexibleSpaceBar(
                  //  collapseMode: CollapseMode.pin,
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.teal.shade600,
                          Colors.teal.shade400,
                          Colors.cyan.shade300,
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),

                    child: Stack(
                      children: [
                        // Background Pattern
                        Positioned.fill(
                          child: CustomPaint(painter: CirclePatternPainter()),
                        ),
                        // Profile Content
                        Positioned(
                          bottom: 20,
                          left: 20,
                          right: 20,
                          child: FutureBuilder<UserModel?>(
                            future: curUserDetail,
                            builder: (context, snapshot) {
                              return Column(
                                children: [
                                  // Profile Picture with Border
                                  Container(
                                    padding: EdgeInsets.all(4),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,

                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.2),
                                          blurRadius: 15,
                                          offset: Offset(0, 5),
                                        ),
                                      ],
                                    ),
                                    child: CircleAvatar(
                                      radius: 55,
                                      backgroundColor: Colors.white,
                                      child: CircleAvatar(
                                        radius: 50,
                                        backgroundImage:
                                            user.photoURL != null &&
                                                user.photoURL!.isNotEmpty
                                            ? NetworkImage(user.photoURL!)
                                            : null,
                                        child:
                                            user.photoURL == null ||
                                                user.photoURL!.isEmpty
                                            ? Icon(
                                                Icons.person,
                                                size: 50,
                                                color: Colors.grey,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  // User Info
                                  Text(
                                    reuseCapitalize(user.displayName!),
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(height: 6),
                                  if (snapshot.hasData &&
                                      snapshot.data!.userName.isNotEmpty)
                                    Container(
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.2),
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        '@${snapshot.data!.userName}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  SizedBox(height: 12),
                                  // Edit Button
                                  ElevatedButton.icon(
                                    onPressed: () => _onOptionTap('edit'),
                                    icon: Icon(Icons.edit, size: 18),
                                    label: Text('Edit Profile'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.teal,
                                      padding: EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(25),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Bio Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: FutureBuilder<UserModel?>(
                    future: curUserDetail,
                    builder: (context, snapshot) {
                      return Container(
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(
                                  Icons.info_outline,
                                  color: Colors.teal,
                                  size: 20,
                                ),
                                SizedBox(width: 8),
                                Text(
                                  'About',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12),
                            Text(
                              snapshot.hasData &&
                                      snapshot.data!.statusMessage!.isNotEmpty
                                  ? snapshot.data!.statusMessage!
                                  : 'Add a short bio to tell others about yourself',
                              style: TextStyle(
                                fontSize: 15,
                                color:
                                    snapshot.hasData &&
                                        snapshot.data!.statusMessage!.isNotEmpty
                                    ? Colors.grey.shade700
                                    : Colors.grey.shade500,
                                fontStyle:
                                    snapshot.hasData &&
                                        snapshot.data!.statusMessage!.isNotEmpty
                                    ? FontStyle.normal
                                    : FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Statistics Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        StreamBuilder(
                          stream: chats,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                return _buildStatCard('Chats', '0', Icons.chat);
                              } else {
                                return _buildStatCard(
                                  'Chats',
                                  "${snapshot.data!.length}",
                                  Icons.chat,
                                );
                              }
                            }
                            return _buildStatCard('Chats', '0', Icons.chat);
                          },
                        ),
                        StreamBuilder(
                          stream: chats,
                          builder: (context, snapshot) {
                            if (snapshot.hasData) {
                              if (snapshot.data!.isEmpty) {
                                return _buildStatCard('Chats', '0', Icons.chat);
                              } else {
                                return _buildStatCard(
                                  'Friends',
                                  '${snapshot.data!.length}',
                                  Icons.people,
                                );
                              }
                            }
                            return _buildStatCard('Chats', '0', Icons.chat);
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Options Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Settings',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 16),
                      _buildOptionsList(),
                    ],
                  ),
                ),
              ),

              // Logout Section
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: Offset(0, 5),
                        ),
                      ],
                    ),
                    child: ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(Icons.logout, color: Colors.red),
                      ),
                      title: Text(
                        'Logout',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.red,
                        ),
                      ),
                      subtitle: Text('Sign out of your account'),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 16,
                        color: Colors.red,
                      ),
                      onTap: _showLogoutDialog,
                    ),
                  ),
                ),
              ),

              // Bottom Spacing
              SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.teal.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Icon(icon, color: Colors.teal, size: 24),
        ),
        SizedBox(height: 8),
        Text(
          count,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        Text(
          title,
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
      ],
    );
  }

  Widget _buildOptionsList() {
    final options = [
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'subtitle': 'App preferences',
        'key': 'settings',
      },
      {
        'icon': Icons.notifications,
        'title': 'Notifications',
        'subtitle': 'Manage notifications',
        'key': 'notifications',
      },
      {
        'icon': Icons.lock,
        'title': 'Privacy & Security',
        'subtitle': 'Control your privacy',
        'key': 'privacy',
      },
      {
        'icon': Icons.palette,
        'title': 'Theme',
        'subtitle': 'Customize appearance',
        'key': 'theme',
      },
      {
        'icon': Icons.storage,
        'title': 'Storage & Data',
        'subtitle': 'Manage storage usage',
        'key': 'storage',
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help & Support',
        'subtitle': 'Get help and support',
        'key': 'help',
      },
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: options.map((option) {
          final isLast = option == options.last;
          return Column(
            children: [
              ListTile(
                leading: Container(
                  padding: EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.teal.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(option['icon'] as IconData, color: Colors.teal),
                ),
                title: Text(
                  option['title'] as String,
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(option['subtitle'] as String),
                trailing: Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: Colors.grey,
                ),
                onTap: () => _onOptionTap(option['key'] as String),
              ),
              if (!isLast)
                Divider(
                  height: 1,
                  indent: 60,
                  endIndent: 20,
                  color: Colors.grey.shade200,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// Custom Painter for Background Pattern
class CirclePatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.1)
      ..style = PaintingStyle.fill;

    // Draw circles
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 30, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.7), 20, paint);
    canvas.drawCircle(Offset(size.width * 0.9, size.height * 0.8), 15, paint);
    canvas.drawCircle(Offset(size.width * 0.1, size.height * 0.3), 25, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
