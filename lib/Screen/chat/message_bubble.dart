import 'package:flutter/material.dart';

class MessageBubble extends StatelessWidget {
  /// The text content of the message
  final String message;

  /// Timestamp string, e.g. '12:30 PM'
  final String timestamp;

  /// Whether this bubble is sent by the current user
  final bool isMe;

  /// Optional background color override
  final Color? backgroundColor;

  const MessageBubble({
    Key? key,
    required this.message,
    required this.timestamp,
    this.isMe = false,
    this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bgColor =
        backgroundColor ?? (isMe ? Colors.blueAccent : Colors.grey.shade200);
    final textColor = isMe ? Colors.white : Colors.black87;

    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 3, horizontal: 12),
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(18),
              topRight: Radius.circular(18),
              bottomLeft: Radius.circular(isMe ? 18 : 0),
              bottomRight: Radius.circular(isMe ? 0 : 18),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 4,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                message,
                style: TextStyle(color: textColor, fontSize: 16, height: 1.4),
              ),
              const SizedBox(height: 6),
              Text(
                timestamp,
                style: TextStyle(
                  // ignore: deprecated_member_use
                  color: textColor.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
