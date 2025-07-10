

class MessageModel{
  String message;
  String senderId;
  String receiverId ;
  String messageId ;
  DateTime timestamp = DateTime.now();
  bool isRead = false;
  MessageModel({required this.message,required this.senderId,required this.receiverId,required this.messageId,required this.timestamp,required this.isRead});

  MessageModel.fromJson(Map<String, dynamic> json)
      : message = json['message'] ?? '',
        senderId = json['senderId'] ?? '',
        receiverId = json['receiverId'] ?? '',
        messageId = json['messageId'] ?? '',
        timestamp = json['timestamp'].toDate()  ?? DateTime.now(),
        isRead = json['isRead'] ?? false;

  Map<String, dynamic> toJson() {
    return {
      'message': message,
      'senderId': senderId,
      'receiverId': receiverId,
      'messageId': messageId,
      'timestamp': timestamp,
      'isRead': isRead,
    };
  }


}