import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:chaton/Services/user_services.dart';
import 'package:chaton/Model/user_model.dart';
import 'package:chaton/Widget/reuseable.dart';
import 'package:chaton/helper.dart';

class PeerProfileScreen extends StatefulWidget {
  final String peerId;
  final String peerName;
  final String? peerProfileUrl;
  final String chatId;

  const PeerProfileScreen({
    Key? key,
    required this.peerId,
    required this.peerName,
    this.peerProfileUrl,
    required this.chatId,
  }) : super(key: key);

  @override
  State<PeerProfileScreen> createState() => _PeerProfileScreenState();
}

class _PeerProfileScreenState extends State<PeerProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isBlocked = false;
  bool _isMuted = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: isDarkMode ? Color(0xFF0D0D0D) : Color(0xFFF5F5F5),
      body: FutureBuilder<UserModel?>(
        future: DatabaseServices().getUser(widget.peerId),
        builder: (context, snapshot) {
          final user = snapshot.data;

          return CustomScrollView(
            slivers: [
              // Custom App Bar with Hero Image
              SliverAppBar(
                expandedHeight: size.height * 0.3,
                pinned: true,
                backgroundColor: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
                leading: IconButton(
                  icon: Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                actions: [
                  IconButton(
                    icon: Container(
                      padding: EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black26,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.more_vert_rounded, color: Colors.white),
                    ),
                    onPressed: () => _showMoreOptions(context),
                  ),
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Profile Image
                      Hero(
                        tag: 'avatar_${widget.peerId}',
                        child: (widget.peerProfileUrl??"").isNotEmpty
                            ? GestureDetector(
                                onTap: () => _viewFullImage(context),
                                child: Image.network(
                                  widget.peerProfileUrl!,
                                  fit: BoxFit.cover,
                                ),
                              )
                            : Container(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [
                                      Colors.teal.shade400,
                                      Colors.teal.shade600,
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: Center(
                                  child: Text(
                                    widget.peerName[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 80,
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                      ),
                      // Gradient Overlay
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 100,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [Colors.transparent, Colors.black54],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Profile Content
              SliverToBoxAdapter(
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Name and Status
                          _buildNameSection(user, isDarkMode),

                          verticalGap(24),

                          // Action Buttons
                          _buildActionButtons(isDarkMode),

                          verticalGap(32),

                          // User Info Section
                          _buildInfoSection(user, isDarkMode),

                          verticalGap(24),

                          // // Media Section
                          // _buildMediaSection(isDarkMode),

                          //verticalGap(24),

                          // Settings Section
                          // _buildSettingsSection(isDarkMode),

                          // verticalGap(24),

                          // Danger Zone
                          _buildDangerZone(isDarkMode),

                          verticalGap(40),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildNameSection(UserModel? user, bool isDarkMode) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user?.displayName ?? widget.peerName,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                  ),
                  verticalGap(4),
                  Text(
                    user?.email ?? '',
                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            StreamBuilder<bool>(
              stream: DatabaseServices().getOnlineStatus(widget.peerId),
              builder: (context, snapshot) {
                final isOnline = snapshot.data ?? false;
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isOnline
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: isOnline ? Colors.green : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      horizontalGap(6),
                      Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: isOnline ? Colors.green : Colors.grey,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
        if (user?.statusMessage != null && user!.statusMessage!.isNotEmpty) ...[
          verticalGap(12),
          Text(
            user.statusMessage!,
            style: TextStyle(
              fontSize: 16,
              color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
              height: 1.5,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildActionButtons(bool isDarkMode) {
    return Row(
      children: [
        Expanded(
          child: _ActionButton(
            icon: Icons.message_rounded,
            label: 'Message',
            color: Colors.teal,
            onTap: () => Navigator.pop(context),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoSection(UserModel? user, bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Info',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          verticalGap(16),
          _InfoRow(
            icon: Icons.phone_rounded,
            label: 'Phone',
            value: user?.phoneNumber ?? 'Not provided',
            isDarkMode: isDarkMode,
          ),
          verticalGap(12),
          _InfoRow(
            icon: Icons.info_outline_rounded,
            label: 'About',
            value: user?.statusMessage ?? 'Hey there! I am using ChatOn',
            isDarkMode: isDarkMode,
          ),
          verticalGap(12),
          _InfoRow(
            icon: Icons.calendar_today_rounded,
            label: 'Member since',
            value: user?.createdAt != null
                ? formatDate(user!.createdAt)
                : 'Unknown',
            isDarkMode: isDarkMode,
          ),
        ],
      ),
    );
  }

  Widget _buildMediaSection(bool isDarkMode) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Media, Links & Docs',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              TextButton(
                onPressed: () {
                  // Navigate to media gallery
                },
                child: Text('See All'),
              ),
            ],
          ),
          verticalGap(16),
          Row(
            children: [
              _MediaPreview(
                count: '12',
                label: 'Media',
                icon: Icons.photo_rounded,
                color: Colors.blue,
              ),
              horizontalGap(12),
              _MediaPreview(
                count: '5',
                label: 'Links',
                icon: Icons.link_rounded,
                color: Colors.green,
              ),
              horizontalGap(12),
              _MediaPreview(
                count: '8',
                label: 'Docs',
                icon: Icons.description_rounded,
                color: Colors.orange,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          _SettingsTile(
            icon: Icons.notifications_rounded,
            title: 'Notifications',
            subtitle: _isMuted ? 'Muted' : 'Enabled',
            trailing: Switch(
              value: !_isMuted,
              onChanged: (value) {
                setState(() => _isMuted = !value);
                HapticFeedback.lightImpact();
              },
              activeColor: Colors.green,
            ),
          ),
          Divider(height: 1),
          _SettingsTile(
            icon: Icons.wallpaper_rounded,
            title: 'Wallpaper',
            subtitle: 'Change chat wallpaper',
            onTap: () {
              // Change wallpaper
            },
          ),
          Divider(height: 1),
          _SettingsTile(
            icon: Icons.lock_rounded,
            title: 'Encryption',
            subtitle: 'Messages are end-to-end encrypted',
            trailing: Icon(
              Icons.check_circle_rounded,
              color: Colors.green,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZone(bool isDarkMode) {
    return Container(
      decoration: BoxDecoration(
        color: isDarkMode ? Color(0xFF1A1A1A) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // _SettingsTile(
          //   icon: Icons.block_rounded,
          //   title: _isBlocked ? 'Unblock User' : 'Block User',
          //   subtitle: _isBlocked
          //       ? 'Tap to unblock this user'
          //       : 'Block all messages and calls',
          //   iconColor: Colors.red,
          //   titleColor: Colors.red,
          //   onTap: () => _showBlockDialog(),
          // ),
          // Divider(height: 1),
          // _SettingsTile(
          //   icon: Icons.report_rounded,
          //   title: 'Report User',
          //   subtitle: 'Report inappropriate behavior',
          //   iconColor: Colors.orange,
          //   titleColor: Colors.orange,
          //   onTap: () => _showReportDialog(),
          // ),
          // Divider(height: 1),
          _SettingsTile(
            icon: Icons.delete_forever_rounded,
            title: 'Clear Chat',
            subtitle: 'Delete all messages in this chat',
            iconColor: Colors.red,
            titleColor: Colors.red,
            onTap: () => _showClearChatDialog(),
          ),
        ],
      ),
    );
  }

  void _viewFullImage(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullImageViewer(
          imageUrl: widget.peerProfileUrl!,
          heroTag: 'avatar_${widget.peerId}',
        ),
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? Color(0xFF1E1E1E)
              : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                margin: EdgeInsets.only(top: 12),
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              ListTile(
                leading: Icon(Icons.share_rounded),
                title: Text('Share Contact'),
                onTap: () {
                  Navigator.pop(context);
                  // Share contact
                },
              ),
              ListTile(
                leading: Icon(Icons.search_rounded),
                title: Text('Search in Conversation'),
                onTap: () {
                  Navigator.pop(context);
                  // Search messages
                },
              ),
              ListTile(
                leading: Icon(Icons.star_rounded),
                title: Text('Starred Messages'),
                onTap: () {
                  Navigator.pop(context);
                  // Show starred messages
                },
              ),
              ListTile(
                leading: Icon(Icons.download_rounded),
                title: Text('Export Chat'),
                onTap: () {
                  Navigator.pop(context);
                  // Export chat
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBlockDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_isBlocked ? 'Unblock User?' : 'Block User?'),
        content: Text(
          _isBlocked
              ? 'You will be able to receive messages and calls from ${widget.peerName}.'
              : 'You will no longer receive messages or calls from ${widget.peerName}.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _isBlocked = !_isBlocked);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_isBlocked ? 'User blocked' : 'User unblocked'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: _isBlocked ? Colors.blue : Colors.red,
            ),
            child: Text(_isBlocked ? 'Unblock' : 'Block'),
          ),
        ],
      ),
    );
  }

  void _showReportDialog() {
    final reasons = [
      'Spam',
      'Harassment',
      'Inappropriate content',
      'Fake profile',
      'Other',
    ];
    String? selectedReason;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text('Report User'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Why are you reporting this user?'),
              verticalGap(16),
              ...reasons.map(
                (reason) => RadioListTile<String>(
                  title: Text(reason),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: (value) => setState(() => selectedReason = value),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedReason != null
                  ? () {
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('User reported'),
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                    }
                  : null,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('Report'),
            ),
          ],
        ),
      ),
    );
  }

  void _showClearChatDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Clear Chat?'),
        content: Text(
          'This will delete all messages in this chat. This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // Clear chat logic
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Chat cleared'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

// Supporting Widgets

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        HapticFeedback.lightImpact();
        onTap();
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            verticalGap(4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final bool isDarkMode;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        horizontalGap(12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              verticalGap(2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  color: isDarkMode ? Colors.white : Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _MediaPreview extends StatelessWidget {
  final String count;
  final String label;
  final IconData icon;
  final Color color;

  const _MediaPreview({
    required this.count,
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 24),
            verticalGap(8),
            Text(
              count,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            Text(label, style: TextStyle(fontSize: 12, color: color)),
          ],
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final Color? iconColor;
  final Color? titleColor;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.trailing,
    this.iconColor,
    this.titleColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (iconColor ?? Colors.blue).withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: iconColor ?? Colors.blue, size: 20),
      ),
      title: Text(
        title,
        style: TextStyle(fontWeight: FontWeight.w600, color: titleColor),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
      trailing: trailing,
    );
  }
}

// Full Image Viewer
class FullImageViewer extends StatelessWidget {
  final String imageUrl;
  final String heroTag;

  const FullImageViewer({
    Key? key,
    required this.imageUrl,
    required this.heroTag,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.download_rounded),
            onPressed: () {
              // Download image
            },
          ),
          IconButton(
            icon: Icon(Icons.share_rounded),
            onPressed: () {
              // Share image
            },
          ),
        ],
      ),
      body: Center(
        child: Hero(
          tag: heroTag,
          child: InteractiveViewer(child: Image.network(imageUrl)),
        ),
      ),
    );
  }
}
