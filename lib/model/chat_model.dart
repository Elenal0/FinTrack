import 'package:intl/intl.dart';

class ChatModel {
  final String id;
  final String groupId;
  final String userId;
  final String message;
  final DateTime createdAt;
  final String? senderName;
  final String? splitId;

  ChatModel({
    required this.id,
    required this.groupId,
    required this.userId,
    required this.message,
    required this.createdAt,
    this.senderName,
    this.splitId,
  });

  factory ChatModel.fromMap(Map<String, dynamic> map, {String? senderName}) {
    return ChatModel(
      id: map['id'] as String,
      groupId: map['group_id'] as String,
      userId: map['user_id'] as String,
      message: map['message'] as String,
      createdAt: DateTime.parse(map['created_at'] as String).toLocal(),
      senderName: senderName,
      splitId: map['split_id'] as String?,
    );
  }

  String get formattedTime {
    return DateFormat('h:mm a').format(createdAt);
  }
}
