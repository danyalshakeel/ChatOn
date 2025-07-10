import 'package:chaton/Model/message_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MessageServices {
  FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  String _collection = 'chats';
  String _document = 'messages';

  Future<void> sendMessage({
    required String chatId,
    required MessageModel message,
  }) async {
    await _firebaseFirestore
        .collection(_collection)
        .doc(chatId)
        .collection(_document)
        .doc(message.messageId)
        .set(message.toJson());
  }

  Stream<QuerySnapshot> fetchMessages(String chatId) {
    return _firebaseFirestore
        .collection(_collection)
        .doc(chatId)
        .collection(_document)
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  Future<void> deleteMessage(String chatId, String messageId) async {
    await _firebaseFirestore
        .collection(_collection)
        .doc(chatId)
        .collection(_document)
        .doc(messageId)
        .delete();
  }

  Future<void> deleteallMessages(String chatId) async {
    final messages = await _firebaseFirestore
        .collection(_collection)
        .doc(chatId)
        .collection(_collection)
        .get();

    print("${messages.docs.length} messages in docs.");
    for (var message in messages.docs) {
      await _firebaseFirestore
          .collection(_collection)
          .doc(chatId)
          .collection(_document)
          .doc(message['messageId'])
          .delete();
      print(
        "Message ${message['message']} deleted: ${message.id} and ${message['messageId']}",
      );
    }
  }
}
