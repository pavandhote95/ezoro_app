class UserModel {
  final int userId;
  final String name;
  final String? profile;
  final String? lastMessage;
  final String? lastMessageTime;
  final int unreadCount;

  UserModel({
    required this.userId,
    required this.name,
    this.profile,
    this.lastMessage,
    this.lastMessageTime,
    this.unreadCount = 0,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['user_id'] is int
          ? json['user_id']
          : int.tryParse(json['user_id'].toString()) ?? 0,
      name: json['name'] ?? '',
      profile: json['profile'],
      lastMessage: json['last_message'],
      lastMessageTime: json['last_message_time'],
      unreadCount: json['unread_count'] is int
          ? json['unread_count']
          : int.tryParse(json['unread_count'].toString()) ?? 0,
    );
  }
}
