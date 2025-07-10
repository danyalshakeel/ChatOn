class ChatModel {
  String chatId;
  List<String> usersId = [];
  
  // bool isOnline;

  ChatModel({
    required this.chatId ,
  //  required this.peerName,
    required this.usersId,
    //required this.isOnline,
    //required this.peerUrl,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
  return ChatModel(
    chatId: json['chatId'] as String?       ?? '',
   // peerName: json['peerName'] as String?   ?? '',
    usersId: (json['usersId'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList()                ?? <String>[],
   // isOnline: json['isOnline'] as bool?     ?? false,
    //peerUrl: json['peerUrl'] as String?     ?? '',
  );
}

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
     // 'peerName': peerName,
      'usersId': usersId,
    //  'isOnline': isOnline,
      //'peerUrl': peerUrl,
    };
  }
}
