import 'dart:ui';

import 'package:chaton/Model/message_model.dart';
import 'package:chaton/Screen/chat/message_bubble.dart';
import 'package:chaton/Screen/profile/peer_profile.dart';
import 'package:chaton/Screen/profile/profile.dart';
import 'package:chaton/Services/message_services.dart';
import 'package:chaton/Services/user_services.dart';
import 'package:chaton/Widget/reuseable.dart';
import 'package:chaton/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({
    Key? key,
    required this.chatId,
    required this.currentId,
    required this.peerId,
    required this.peerName,
    this.peerProfileUrl,
  }) : super(key: key);

  final String chatId;
  final String currentId;
  final String peerId;
  final String peerName;
  final String? peerProfileUrl;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final Uuid uuid = Uuid();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // Stream<QuerySnapshot> get _messageStream { // return FirebaseFirestore.instance // .collection('chats') // .doc(widget.chatId) // .collection('messages') // .orderBy('timestamp', descending: true) // .snapshots(); // }

  Stream<QuerySnapshot> fetchMessages(String chatId) {
    return MessageServices().fetchMessages(chatId);
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    final messageModel = MessageModel(
      message: text,
      senderId: widget.currentId,
      receiverId: widget.peerId,
      messageId: uuid.v4(),
      timestamp: DateTime.now(),
      isRead: false,
    );

    MessageServices().sendMessage(chatId: widget.chatId, message: messageModel);
    _messageController.clear();

    // scroll to bottom after a short delay
    Future.delayed(const Duration(milliseconds: 100), () {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.bounceIn,
      );
    });
  }

  bool _isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  _getDateString(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(Duration(days: 1));
    final dateToCheck = DateTime(date.year, date.month, date.day);

    if (dateToCheck == today) {
      return 'Today';
    } else if (dateToCheck == yesterday) {
      return 'Yesterday';
    } else if (now.difference(date).inDays < 7) {
      return _getWeekdayName(date.weekday);
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  _getWeekdayName(int weekday) {
    const weekdays = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    return weekdays[weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: lightGreenColor,
        title: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PeerProfileScreen(
                peerId: widget.peerId,
                peerName: widget.peerName,
                peerProfileUrl: widget.peerProfileUrl,
                chatId: widget.chatId,
              ),
            ),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: greenColor,
                // backgroundImage: widget.peerProfileUrl!.isNotEmpty
                //     ? NetworkImage(widget.peerProfileUrl!)
                //     : null,
                child: widget.peerProfileUrl == null
                    ? null
                    : Text(
                        widget.peerName[0].toUpperCase(),
                        style: TextStyle(fontSize: 20, color: Colors.black),
                      ),
              ),
              horizontalGap(8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(widget.peerName),
                  StreamBuilder(
                    stream: DatabaseServices().getOnlineStatus(widget.peerId),
                    builder: (context, asyncSnapshot) {
                      if (asyncSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return Text("", style: TextStyle(fontSize: 12));
                      }

                      final isOnline = asyncSnapshot.data ?? false;

                      return Text(
                        isOnline ? 'Online' : 'Offline',
                        style: TextStyle(
                          color: isOnline ? Colors.white : Colors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),

        // shape: const RoundedRectangleBorder(
        //   borderRadius: BorderRadius.only(
        //     bottomLeft: Radius.circular(25),
        //     bottomRight: Radius.circular(25),
        //   ),
        // ),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () {
              showGeneralDialog(
                context: context,
                barrierLabel: "Delete Chat",
                barrierDismissible: true,
                barrierColor: Colors.black.withOpacity(0.5),
                transitionDuration: const Duration(milliseconds: 300),
                pageBuilder: (ctx, anim1, anim2) {
                  return Center(
                    child: Material(
                      color: Colors.transparent,
                      child: Container(
                        width: 320,
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1E1E1E)
                              : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            // Header with icon
                            Container(
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.red.shade400,
                                    Colors.red.shade600,
                                  ],
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                                borderRadius: const BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white.withOpacity(0.2),
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(
                                      Icons.delete_outline_rounded,
                                      color: Colors.white,
                                      size: 24,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Text(
                                    "Delete Chat",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Content
                            Padding(
                              padding: const EdgeInsets.all(20),
                              child: Column(
                                children: [
                                  const Text(
                                    "Are you sure you want to delete this chat? This action cannot be undone.",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      height: 1.5,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 24),

                                  // Action buttons
                                  Row(
                                    children: [
                                      Expanded(
                                        child: TextButton(
                                          onPressed: () {
                                            Navigator.of(ctx).pop();
                                          },
                                          style: TextButton.styleFrom(
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                          ),
                                          child: Text(
                                            "Cancel",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Colors.grey[600],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: ElevatedButton(
                                          onPressed: () {
                                            MessageServices().deleteallMessages(
                                              widget.chatId,
                                            );
                                            Navigator.of(ctx).pop();

                                            // Show confirmation snackbar
                                            ScaffoldMessenger.of(
                                              context,
                                            ).showSnackBar(
                                              SnackBar(
                                                content: const Text(
                                                  "Chat deleted",
                                                ),
                                                behavior:
                                                    SnackBarBehavior.floating,
                                                shape: RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                backgroundColor:
                                                    Colors.grey[800],
                                                duration: const Duration(
                                                  seconds: 2,
                                                ),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor:
                                                Colors.red.shade500,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 12,
                                            ),
                                            shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          child: const Text(
                                            "Delete",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                transitionBuilder: (ctx, anim1, anim2, child) {
                  return BackdropFilter(
                    filter: ImageFilter.blur(
                      sigmaX: 3 * anim1.value,
                      sigmaY: 3 * anim1.value,
                    ),
                    child: ScaleTransition(
                      scale: CurvedAnimation(
                        parent: anim1,
                        curve: Curves.easeOutBack,
                      ),
                      child: FadeTransition(
                        opacity: CurvedAnimation(
                          parent: anim1,
                          curve: Curves.easeOut,
                        ),
                        child: child,
                      ),
                    ),
                  );
                },
              );
            },
          ),
          horizontalGap(20),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: fetchMessages(widget.chatId),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final docs = snapshot.data?.docs ?? [];
                      if (docs.isEmpty) {
                        return const Center(child: Text('No messages yet'));
                      }

                      return ListView.builder(
                        reverse: true,
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 8,
                        ),
                        itemCount: docs.length,
                        itemBuilder: (context, index) {
                          final data =
                              docs[index].data() as Map<String, dynamic>;
                          final message = MessageModel.fromJson(data);
                          final isMe = message.senderId == widget.currentId;

                          // Check if we should show date separator
                          bool showDateSeparator = false;
                          if (index == docs.length - 1) {
                            showDateSeparator = true;
                          } else {
                            final nextData =
                                docs[index + 1].data() as Map<String, dynamic>;
                            final nextMessage = MessageModel.fromJson(nextData);
                            showDateSeparator = !_isSameDay(
                              message.timestamp,
                              nextMessage.timestamp,
                            );
                          }

                          return Column(
                            children: [
                              if (showDateSeparator)
                                _buildDateSeparator(message.timestamp),
                              Align(
                                alignment: isMe
                                    ? Alignment.centerRight
                                    : Alignment.centerLeft,
                                child: Row(
                                  mainAxisAlignment: isMe
                                      ? MainAxisAlignment.end
                                      : MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    if (!isMe) ...[
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: greyTextColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 13,
                                          backgroundColor: Colors.grey.shade200,
                                          backgroundImage:
                                           (   widget.peerProfileUrl ?? '').isNotEmpty
                                              ? NetworkImage(
                                                  widget.peerProfileUrl!,
                                                )
                                              : null,
                                          child: (widget.peerProfileUrl??'').isEmpty
                                              ? const Icon(
                                                  Icons.person,
                                                  color: Colors.black,
                                                )
                                              : null,
                                        ),
                                      ),
                                      horizontalGap(0),
                                    ],
                                    GestureDetector(
                                      child: MessageBubble(
                                        message: message.message,
                                        timestamp: formatTime(
                                          message.timestamp,
                                        ),
                                        isMe: isMe,
                                        backgroundColor: isMe
                                            ? lightGreenColor
                                            : Colors.grey.shade300,
                                      ),

                                      onLongPress: () {
                                        _showDeleteDialog(
                                          message.messageId,
                                          isMe,
                                          message.message,
                                        );
                                      },
                                    ),
                                    if (isMe) ...[
                                      horizontalGap(8),
                                      Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          border: Border.all(
                                            color: greenColor,
                                            width: 2,
                                          ),
                                        ),
                                        child: CircleAvatar(
                                          radius: 13,

                                          backgroundColor: Colors.teal,
                                          child: const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                      );
                    },
                  ),
                  _buildScrollToBottomButton(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 6, right: 6, bottom: 4),

              child: Container(
                decoration: BoxDecoration(
                  color: const Color.fromARGB(255, 186, 212, 210),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                padding: EdgeInsets.only(left: 8, right: 8, top: 8, bottom: 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              maxLines: 7,
                              minLines: 1,
                              controller: _messageController,
                              decoration: InputDecoration(
                                hintText: 'Type a message',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.white,
                              ),
                              textInputAction: TextInputAction.send,
                              onSubmitted: (_) => _sendMessage(),
                            ),
                          ),
                          IconButton(
                            icon: Icon(Icons.emoji_emotions_outlined),
                            color: Colors.grey[600],
                            onPressed: () {
                              // Show emoji picker
                            },
                          ),
                        ],
                      ),
                    ),
                    // horizontalGap(8),
                    Container(
                      decoration: BoxDecoration(
                        color: lightGreenColor,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: IconButton(
                        icon: const Icon(Icons.send),
                        onPressed: _sendMessage,
                      ),
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

  Future<void> _showDeleteDialog(String messageId, bool isMe, String message) {
    return showGeneralDialog(
      context: context,
      barrierLabel: "Delete Message",
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(0.5),
      transitionDuration: Duration(milliseconds: 300),
      pageBuilder: (ctx, anim1, anim2) {
        return Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              width: 320,
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Color(0xFF1E1E1E)
                    : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 20,
                    offset: Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Header with icon
                  Container(
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Colors.red.shade400, Colors.red.shade600],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.delete_outline_rounded,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          "Delete Message",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Content
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text(
                          "Are you sure you want to delete the message '$message' ?",
                          textAlign: TextAlign.start,
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.5,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                ? Colors.grey[300]
                                : Colors.grey[700],
                          ),
                        ),

                        if (isMe) ...[
                          SizedBox(height: 20),
                          // Delete options
                          Container(
                            decoration: BoxDecoration(
                              color:
                                  Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.grey[900]
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              children: [
                                _buildDeleteOption(
                                  icon: Icons.delete_outline,
                                  title: "Delete from everyone",
                                  subtitle:
                                      "Message will be removed Permanently",
                                  onTap: () {
                                    HapticFeedback.lightImpact();
                                    // Delete for current user only
                                    MessageServices().deleteMessage(
                                      widget.chatId,
                                      messageId,
                                    );
                                    Navigator.of(ctx).pop();
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],

                        SizedBox(height: 24),

                        // Action buttons
                        Row(
                          children: [
                            Expanded(
                              child: TextButton(
                                onPressed: () {
                                  HapticFeedback.selectionClick();
                                  Navigator.of(ctx).pop();
                                },
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: Text(
                                  "Cancel",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ),

                            if (!isMe) ...[
                              SizedBox(width: 12),
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    HapticFeedback.mediumImpact();
                                    MessageServices().deleteMessage(
                                      widget.chatId,
                                      messageId,
                                    );
                                    Navigator.of(ctx).pop();

                                    // Show confirmation snackbar
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text("Message deleted"),
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        backgroundColor: Colors.grey[800],
                                        duration: Duration(seconds: 2),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red.shade500,
                                    foregroundColor: Colors.white,
                                    padding: EdgeInsets.symmetric(vertical: 12),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: Text(
                                    "Delete",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
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
      transitionBuilder: (ctx, anim1, anim2, child) {
        return BackdropFilter(
          filter: ImageFilter.blur(
            sigmaX: 3 * anim1.value,
            sigmaY: 3 * anim1.value,
          ),
          child: ScaleTransition(
            scale: CurvedAnimation(parent: anim1, curve: Curves.easeOutBack),
            child: FadeTransition(
              opacity: CurvedAnimation(parent: anim1, curve: Curves.easeOut),
              child: child,
            ),
          ),
        );
      },
    );
  }

  Widget _buildDeleteOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isDestructive
                    ? Colors.red.withOpacity(0.1)
                    : Colors.blue.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: isDestructive ? Colors.red : Colors.blue,
                size: 20,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: isDestructive ? Colors.red : null,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  // Update the GestureDetector to pass isMe parameter

  Widget _buildScrollToBottomButton() {
    return Positioned(
      bottom: 16,
      right: 16,
      child: AnimatedBuilder(
        animation: _scrollController,
        builder: (context, child) {
          final showButton =
              _scrollController.hasClients && _scrollController.offset > 200;

          return AnimatedOpacity(
            opacity: showButton ? 1.0 : 0.0,
            duration: Duration(milliseconds: 200),
            child: AnimatedScale(
              scale: showButton ? 1.0 : 0.0,
              duration: Duration(milliseconds: 200),
              child: FloatingActionButton.small(
                onPressed: () {
                  _scrollController.animateTo(
                    0.0,
                    duration: Duration(milliseconds: 300),
                    curve: Curves.easeOut,
                  );
                },
                backgroundColor: greenColor,
                child: Icon(Icons.arrow_downward_rounded, color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildDateSeparator(DateTime date) {
    final dateStr = _getDateString(date);
    return dateStr == "Monday" || dateStr == "Today" || dateStr == "Yesterday"
        ? Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                dateStr,
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Row(
              children: [
                Expanded(child: Divider()),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text(
                    dateStr,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Expanded(child: Divider()),
              ],
            ),
          );
  }
}
