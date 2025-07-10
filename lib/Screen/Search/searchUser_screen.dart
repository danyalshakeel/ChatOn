import 'package:chaton/Model/chat_model.dart';
import 'package:chaton/Model/user_model.dart';
import 'package:chaton/Screen/chat/chat_screen.dart';
import 'package:chaton/Services/User_services.dart';
import 'package:chaton/Services/auth_services.dart';
import 'package:chaton/Services/chat_services.dart';
import 'package:chaton/Widget/reuseable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({Key? key}) : super(key: key);

  @override
  _SearchUserScreenState createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final DatabaseServices _db = DatabaseServices();
  final TextEditingController _searchController = TextEditingController();

  List<UserModel> _allUsers = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    try {
      final users = await _db.getAllUsers();
      final currentId = AuthServices().currentUserId;
      setState(() {
        _allUsers = users.where((u) => u.uid != currentId).toList();
        _filteredUsers = [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error loading users: $e')));
    }
  }

  void _filterUsers(String query) {
    final term = query.trim().toLowerCase();
    if (term.isEmpty) {
      setState(() => _filteredUsers = []);
      return;
    }
    final results = _allUsers.where((user) {
      final name = user.displayName.toLowerCase();
      final username = user.userName.toLowerCase();
      return (name.contains(term) || username.contains(term));
    }).toList();
    setState(() => _filteredUsers = results);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //backgroundColor: lightBgColor,
      appBar: AppBar(
        backgroundColor: lightGreenColor,
        title: TextField(
          controller: _searchController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'Search users...',
            border: InputBorder.none,
            prefixIcon: Icon(Icons.search, color: Colors.black),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(Icons.clear, color: Colors.black),
                    onPressed: () {
                      _searchController.clear();
                      _filterUsers('');
                    },
                  ),
          ),
          onChanged: _filterUsers,
          style: TextStyle(color: darkTextColor),
        ),
        elevation: 1,
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator(color: lightGreenColor))
          : (_searchController.text.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: lightGreenColor.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            Icons.search,
                            color: greenColor,
                            size: 100,
                          ),
                        ),
                        Text(
                          'Start typing to search...',
                          style: TextStyle(color: greyTextColor, fontSize: 20),
                        ),
                      ],
                    ),
                  )
                : (_filteredUsers.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: lightGreenColor.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Icon(
                                  Icons.search_off,
                                  color: greenColor,
                                  size: 100,
                                ),
                              ),
                              Text(
                                'No users found.',
                                style: TextStyle(
                                  color: greyTextColor,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          itemCount: _filteredUsers.length,
                          itemBuilder: (context, index) {
                            final user = _filteredUsers[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              child: SearchUserCard(user: user),
                            );
                          },
                        ))),
    );
  }
}

class SearchUserCard extends StatelessWidget {
  final UserModel user;

  SearchUserCard({Key? key, required this.user}) : super(key: key);

  final currentUserId = AuthServices().currentUserId;

  String capitalise(String s) =>
      s.isNotEmpty ? s[0].toUpperCase() + s.substring(1) : s;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4.0, vertical: 00),
      child: Material(
        borderRadius: BorderRadius.circular(20),
        elevation: 1,
        color: Colors.white,
        shadowColor: Colors.green,
        // surfaceTintColor: Colors.green,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {}, // optional: can show profile or open modal
          child: Container(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: lightGreenColor,
                  child: CircleAvatar(
                    radius: 28,
                    backgroundColor: greyBgColor,
                    backgroundImage: user.photoUrl.isNotEmpty
                        ? NetworkImage(user.photoUrl)
                        : null,
                    child: user.photoUrl.isEmpty
                        ? Icon(Icons.person, size: 32, color: greyTextColor)
                        : null,
                  ),
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Text(
                        capitalise(user.displayName),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: darkTextColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "@${user.userName}",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(fontSize: 14, color: greyTextColor),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 10),
                Container(
                  decoration: BoxDecoration(
                    // ignore: deprecated_member_use
                    color: lightGreenColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    onPressed: () async {
                      final creatingId = [currentUserId, user.uid]..sort();
                      final String chatId = creatingId.join('');
                      final ischatExists = await ChatServices().getChat(chatId);

                      if (ischatExists != null) {
                        await Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (_) => ChatScreen(
                              chatId: chatId,
                              currentId: currentUserId!,
                              peerId: user.uid,
                              peerName: user.displayName,
                            ),
                          ),
                        );
                        return;
                      }
                      showChatStartDialog(context, user);
                    },
                    icon: Icon(Icons.chat_rounded, color: greenColor),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

Future<void> handleChatNavigation(BuildContext context, UserModel user) async {
  // Close any open dialogs
  if (context.mounted) {
    Navigator.of(context).pop();
  }

  // Build a deterministic chat ID
  final currentUserId = AuthServices().currentUserId;
  if (currentUserId == null) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Unable to retrieve your user ID.')),
      );
    }
    return;
  }

  final creatingId = [currentUserId, user.uid]..sort();
  final String chatId = creatingId.join('');
  
  try {
    // Check if the chat already exists
    final existingChat = await ChatServices().getChat(chatId);

    if (existingChat != null) {
      // Check if context is still mounted before using it
      if (context.mounted) {
        // Inform and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            duration: Duration(seconds: 1),
            content: Text('Chat already exists, opening...'),
          ),
        );

        await Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => ChatScreen(
              chatId: chatId,
              currentId: currentUserId,
              peerId: user.uid,
              peerName: user.displayName,
            ),
          ),
        );
      }

      debugPrint("Display name:${user.displayName}");
      return;
    }

    // Build new ChatModel
    final newChat = ChatModel(
      chatId: chatId,
      usersId: [currentUserId, user.uid],
    );
    debugPrint("Display name:${user.displayName}");

    // Create in database
    final created = await ChatServices().createChat(chatModel: newChat);
    
    if (created == null) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to create chat. Please try again.'),
          ),
        );
      }
      return;
    }

    // Navigate to the newly created chat
    if (context.mounted) {
      await Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => ChatScreen(
            chatId: chatId,
            currentId: currentUserId,
            peerId: user.uid,
            peerName: user.displayName,
          ),
        ),
      );
    }
  } catch (e, st) {
    // Log and notify
    debugPrint('Error during chat navigation: $e\n$st');
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('An unexpected error occurred.')),
      );
    }
  }
}
Future<void> showChatStartDialog(BuildContext context, UserModel user) {
  return showDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierColor: Colors.black54,
    builder: (BuildContext ctx) {
      return Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          width: 340,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Colors.white.withOpacity(0.95)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header with gradient
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      greenColor.withOpacity(0.1),
                      greenColor.withOpacity(0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24),
                    topRight: Radius.circular(24),
                  ),
                ),
                child: Column(
                  children: [
                    // Profile Avatar with decoration
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 90,
                          height: 90,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [
                                greenColor.withOpacity(0.3),
                                greenColor.withOpacity(0.1),
                              ],
                            ),
                          ),
                        ),
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.white,
                          child: CircleAvatar(
                            radius: 38,
                            backgroundColor: greyBgColor,
                            backgroundImage: user.photoUrl.isNotEmpty
                                ? NetworkImage(user.photoUrl)
                                : null,
                            child: user.photoUrl.isEmpty
                                ? Text(
                                    user.displayName[0].toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 32,
                                      fontWeight: FontWeight.bold,
                                      color: greenColor,
                                    ),
                                  )
                                : null,
                          ),
                        ),
                        // Online indicator (optional)
                        Positioned(
                          bottom: 5,
                          right: 5,
                          child: Container(
                            width: 20,
                            height: 20,
                            decoration: BoxDecoration(
                              color: user.isOnline ? Colors.green : Colors.grey,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 3),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    // User name
                    Text(
                      reuseCapitalize(user.displayName),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: darkTextColor,
                      ),
                    ),
                    SizedBox(height: 4),
                    // Username with icon
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.alternate_email,
                          size: 16,
                          color: greyTextColor,
                        ),
                        SizedBox(width: 4),
                        Text(
                          user.userName,
                          style: TextStyle(
                            fontSize: 15,
                            color: greyTextColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 40,
                      color: greenColor.withOpacity(0.3),
                    ),
                    SizedBox(height: 12),
                    Text(
                      'Start a conversation',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: darkTextColor,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Send a message to connect with ${user.displayName.split(' ')[0]}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: greyTextColor,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),

              // Actions
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(24),
                    bottomRight: Radius.circular(24),
                  ),
                ),
                child: Row(
                  children: [
                    // Cancel button
                    Expanded(
                      child: TextButton(
                        onPressed: () => Navigator.of(ctx).pop(),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 16,
                            color: greyTextColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    // Start chat button
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(ctx).pop();
                          handleChatNavigation(context, user);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: greenColor,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.send_rounded, size: 18),
                            SizedBox(width: 8),
                            Text(
                              'Start Chat',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
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
  );
}
