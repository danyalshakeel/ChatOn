import 'package:chaton/Model/chat_model.dart';
import 'package:chaton/Model/user_model.dart';
import 'package:chaton/Services/user_services.dart';
import 'package:chaton/helper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatServices {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  final String _collection = 'chats';

  Future<ChatModel> createChat({required ChatModel chatModel}) async {

    _firebaseFirestore
        .collection('chats')
        .doc(chatModel.chatId)
        .set(chatModel.toJson());

    return chatModel;
  }

  Future<ChatModel?> getChat(String chatId) async {
    try {
      DocumentSnapshot doc = await _firebaseFirestore
          .collection(_collection)
          .doc(chatId)
          .get();
      print('Chat retrieved successfully: ${doc.id}');
      if (!doc.exists) return null;
      return ChatModel.fromJson(doc.data() as Map<String, dynamic>);
    } catch (e) {
      print('Error getting chat: $e');
      return null;
    }
  }
   Stream<QuerySnapshot> fetchChats(String currentUserId) {
     return _firebaseFirestore
         .collection(_collection)
         .where('usersId', arrayContains: currentUserId)
         .snapshots();
   }
   /// Emits a List of chat summaries for `currentUserId` in real time.
Stream<List<Map<String, dynamic>>> fetchUserChats(String currentUserId) {
  return _firebaseFirestore
    .collection(_collection)
    .where('usersId', arrayContains: currentUserId)
    .snapshots()                              // 1️⃣ listen to all chats
    .asyncMap((QuerySnapshot chatSnap) async {
      // Fetch all peer profiles in parallel
      final chatDocs = chatSnap.docs;
      final futures = chatDocs.map((doc) async {
        final data = doc.data() as Map<String, dynamic>;
        final users = List<String>.from(data['usersId'] as List);
        final peerId = users.firstWhere((id) => id != currentUserId);

        // 2️⃣ fetch peer profile
        final peerUser = await DatabaseServices().getUser(peerId) as UserModel;

        // 3️⃣ fetch latest message for this chat
        final msgSnap = await _firebaseFirestore
          .collection(_collection)
          .doc(doc.id)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

        String lastText = '';
        String lastTime = '';
        if (msgSnap.docs.isNotEmpty) {
          final m = msgSnap.docs.first.data() as Map<String, dynamic>;
          lastText = m['message'] as String? ?? '';
          lastTime = formatTime((m['timestamp'] as Timestamp).toDate());
        }

        return {
          'chatId':      doc.id,
          'peerId':      peerId,
          'peerName':    peerUser.displayName,
          'peerUrl':     peerUser.photoUrl,
          'lastMessage': lastText,
          'lastTime':    lastTime,
          'isOnline':    peerUser.isOnline,
        };
      });

      // Wait for all per-chat futures, then return the full list
      return Future.wait(futures);
    });
}

  
   Future<void> deleteChat(String chatId) async {
    await _firebaseFirestore.collection(_collection).doc(chatId).delete();
  }

}
