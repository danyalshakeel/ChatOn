import 'package:chaton/Screen/Notification/notification.dart';
import 'package:chaton/Screen/chat/chat_screen.dart';
import 'package:chaton/Screen/profile/animated_Avtar.dart';
import 'package:chaton/Services/auth_services.dart';
import 'package:chaton/Services/chat_services.dart';
import 'package:chaton/Widget/reuseable.dart';
import 'package:chaton/Widget/widgets.dart';
import 'package:chaton/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ChatList extends StatefulWidget {
  const ChatList({Key? key}) : super(key: key);

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> with TickerProviderStateMixin {
  final TextEditingController searchController = TextEditingController();
  final AuthServices authServices = AuthServices();
  final ChatServices chatServices = ChatServices();
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    searchController.addListener(() => setState(() {}));

    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
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
    searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  String capitalise(String s) {
    return s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;
  }

  String _formatTime(String timeString) {
    // You can implement proper time formatting here
    return timeString;
  }

  bool _showCard = false;
  @override
  Widget build(BuildContext context) {
    final currentUserId = authServices.currentUserId;
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Stack(
              children: [
                Column(
                  children: [
                    // Modern Header with Gradient
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [greenColor, greenColor.withOpacity(0.8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(30),
                          bottomRight: Radius.circular(30),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: greenColor.withOpacity(0.3),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          children: [
                            // Top Bar
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(
                                  width: 48,
                                ), // Balance the notification icon
                                const Text(
                                  'ChatOn',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 1.2,
                                  ),
                                ),
                                Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => NotificationScreen(),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.notifications_outlined,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Profile Section
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      _showCard = !_showCard;
                                    });
                                  },
                                  child: Hero(
                                    tag: 'profile_avatar',
                                    child: Container(
                                      padding: const EdgeInsets.all(3),
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 2,
                                        ),
                                        boxShadow: [
                                          BoxShadow(
                                            color: Colors.black.withOpacity(
                                              0.1,
                                            ),
                                            blurRadius: 10,
                                            offset: const Offset(0, 5),
                                          ),
                                        ],
                                      ),
                                      child: CircleAvatar(
                                        radius: 32,
                                        backgroundColor: Colors.white,
                                        child: CircleAvatar(
                                          radius: 30,
                                          backgroundImage: NetworkImage(
                                            authServices
                                                    .currentUser
                                                    ?.photoURL ??
                                                'https://cybrid.solutions/wp-content/uploads/2022/05/123236861-default-avatar-profile-icon-grey-photo-placeholder.webp',
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Welcome back,',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 14,
                                        ),
                                      ),
                                      Text(
                                        capitalise(
                                          authServices
                                                  .currentUser
                                                  ?.displayName ??
                                              'User',
                                        ),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            // Search Bar
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(25),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.05),
                                    blurRadius: 10,
                                    offset: const Offset(0, 5),
                                  ),
                                ],
                              ),
                              child: TextField(
                                controller: searchController,
                                onChanged: (value) {
                                  setState(() {
                                    _isSearching = value.isNotEmpty;
                                  });
                                },
                                decoration: InputDecoration(
                                  hintText: 'Search conversations...',
                                  hintStyle: TextStyle(
                                    color: Colors.grey.shade500,
                                  ),
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.grey.shade500,
                                  ),
                                  suffixIcon: _isSearching
                                      ? IconButton(
                                          icon: Icon(
                                            Icons.clear,
                                            color: Colors.grey.shade500,
                                          ),
                                          onPressed: () {
                                            searchController.clear();
                                            setState(() {
                                              _isSearching = false;
                                            });
                                          },
                                        )
                                      : null,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(25),
                                    borderSide: BorderSide.none,
                                  ),
                                  filled: true,
                                  fillColor: Colors.white,
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Chat List
                    Expanded(
                      child: currentUserId == null
                          ? _buildEmptyState(
                              'User not logged in',
                              Icons.person_off,
                            )
                          : StreamBuilder<List<Map<String, dynamic>>>(
                              stream: onSplashFetchChats(currentUserId),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return _buildLoadingState();
                                }
                                if (snapshot.hasError) {
                                  return _buildEmptyState(
                                    'Something went wrong',
                                    Icons.error_outline,
                                  );
                                }
                                if (snapshot.data == null ||
                                    snapshot.data!.isEmpty) {
                                  return _buildEmptyState(
                                    'No conversations yet',
                                    Icons.chat_bubble_outline,
                                    subtitle:
                                        'Start a new conversation to see it here',
                                  );
                                }

                                final allChats = snapshot.data ?? [];
                                final filtered = searchController.text.isEmpty
                                    ? allChats
                                    : allChats.where((chat) {
                                        final name =
                                            (chat['peerName'] as String)
                                                .toLowerCase();
                                        return name.contains(
                                          searchController.text.toLowerCase(),
                                        );
                                      }).toList();

                                if (filtered.isEmpty) {
                                  return _buildEmptyState(
                                    'No matches found',
                                    Icons.search_off,
                                    subtitle:
                                        'Try searching with different keywords',
                                  );
                                }
  List<Map<String, dynamic>> filteredChats = filtered.toList();

  filteredChats.sort((a, b) {
    
    final aTimestamp = a['lastTime'] ;
    final bTimestamp = b['lastTime'] ;
    return bTimestamp.compareTo(aTimestamp);
  });

                                return ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                  ),
                                  itemCount: filteredChats.length,
                                  itemBuilder: (context, index) {
                                    final chat = filteredChats[index];
                                    return _buildChatTile(
                                      chat,
                                      currentUserId,
                                      index,
                                    );
                                  },
                                );
                              },
                            ),
                    ),
                  ],
                ),

                if (_showCard)
                  AnimatedAvatarCard(
                    name: authServices.currentUser!.displayName ?? '',
                    email: authServices.currentUser!.email ?? '',
                    avatarUrl:
                        authServices.currentUser!.photoURL ??
                        '', // Add your avatar URL here
                    onClose: () {
                      debugPrint("close");
                      setState(() {
                        _showCard = false;
                      });
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChatTile(
    Map<String, dynamic> chat,
    String currentUserId,
    int index,
  ) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 300 + (index * 100)),
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, (1 - value) * 50),
          child: Opacity(
            opacity: value,
            child: Container(
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => Navigator.push(
                    context,
                    PageRouteBuilder(
                      pageBuilder: (context, animation, secondaryAnimation) =>
                          ChatScreen(
                            chatId: chat['chatId'],
                            currentId: currentUserId,
                            peerId: chat['peerId'],
                            peerName: capitalise(chat['peerName']),
                            peerProfileUrl: chat['peerUrl'],
                          ),
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
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        // Profile Picture
                        Hero(
                          tag: 'avatar_${chat['peerId']}',
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: LinearGradient(
                                colors: [
                                  greenColor.withOpacity(0.3),
                                  greenColor.withOpacity(0.1),
                                ],
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 28,
                              backgroundColor: Colors.white,
                              child: CircleAvatar(
                                radius: 25,
                                backgroundImage: chat['peerUrl'].isNotEmpty
                                    ? NetworkImage(chat['peerUrl'])
                                    : null,
                                backgroundColor: lightGreenColor,
                                child: chat['peerUrl'].isEmpty
                                    ? Text(
                                        chat['peerName'][0].toUpperCase(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      )
                                    : null,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Chat Info
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    capitalise(chat['peerName']),
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    _formatTime(chat['lastTime']),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade500,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                chat['lastMessage'] ?? 'No messages yet',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Chevron
                        Icon(
                          Icons.chevron_right,
                          color: Colors.grey.shade400,
                          size: 20,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(greenColor),
          ),
          const SizedBox(height: 16),
          Text(
            'Loading conversations...',
            style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(String title, IconData icon, {String? subtitle}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 48, color: Colors.grey.shade400),
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade700,
            ),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
            ),
          ],
        ],
      ),
    );
  }
}
