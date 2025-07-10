import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;

  /// Display name of the user.
  final String displayName;

  // Unique User name
  final String userName;

  /// Email address of the user.
  final String email;

  /// URL to the user's profile photo.
  final String photoUrl;

  /// Timestamp when the user account was created.
  final DateTime createdAt;

  /// Timestamp when the user profile was last updated.
  final DateTime updatedAt;

  /// Timestamp of the user's last activity (for "last seen").
  final DateTime? lastSeen;

  /// Online status flag.
  final bool isOnline;

  /// A short status message or "about me" line.
  final String? statusMessage;

  /// Phone number, if provided.
  final String? phoneNumber;

  /// Device token for push notifications (FCM/APNs).
  final String? pushToken;

  /// Constructor for creating a new user.
  UserModel({
    this.uid = '',
    required this.displayName,
    required this.userName,
    required this.email,
    this.photoUrl = '',
    DateTime? createdAt,
    DateTime? updatedAt,
    this.lastSeen,
    this.isOnline = false,
    this.statusMessage = 'Hey! I\'m using ChatOn',
    this.phoneNumber,
    this.pushToken,
  }) : createdAt = createdAt ?? DateTime.now(),
       updatedAt = updatedAt ?? DateTime.now();

  /// Creates a User instance from a JSON map.
  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
    uid: json['uid'] as String? ?? '',
    displayName: json['displayName'] as String? ?? '',
    userName: json['userName'] as String? ?? '',
    email: json['email'] as String? ?? '',
    photoUrl: json['photoUrl'] as String? ?? '',
    createdAt:
        DateTime.tryParse(json['createdAt'] as String? ?? '') ?? DateTime.now(),
    updatedAt:
        DateTime.tryParse(json['updatedAt'] as String? ?? '') ?? DateTime.now(),
    lastSeen: json['lastSeen'] != null && json['lastSeen'] is Timestamp
        ? (json['lastSeen'] as Timestamp).toDate()
        : DateTime.now(),
    isOnline: json['isOnline'] as bool? ?? false,
    statusMessage: json['statusMessage'] as String?,
    phoneNumber: json['phoneNumber'] as String?,
    pushToken: json['pushToken'] as String?,
  );

  /// Converts the User instance to a JSON map.
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'displayName': displayName,
    'userName': userName,
    'email': email,
    'photoUrl': photoUrl,
    'createdAt': createdAt.toIso8601String(),
    'updatedAt': updatedAt.toIso8601String(),
    'lastSeen': lastSeen?.toIso8601String(),
    'isOnline': isOnline,
    'statusMessage': statusMessage,
    'phoneNumber': phoneNumber,
    'pushToken': pushToken,
  };

  /// Returns a new copy of this User with the given fields updated.
  UserModel copyWith({
    String? uid,
    String? displayName,
    String? userName,
    String? email,
    String? photoUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? lastSeen,
    bool? isOnline,
    String? statusMessage,
    String? phoneNumber,
    String? pushToken,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      displayName: displayName ?? this.displayName,
      userName: this.userName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      lastSeen: lastSeen ?? this.lastSeen,
      isOnline: isOnline ?? this.isOnline,
      statusMessage: statusMessage ?? this.statusMessage,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      pushToken: pushToken ?? this.pushToken,
    );
  }
}
