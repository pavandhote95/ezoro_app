class UserModel {
  final int userId;
  final String name;
  final String? profile; // network image
  final String lastMessage;
  final String lastMessageTime;
  final int unreadCount;

  UserModel({
    required this.userId,
    required this.name,
    this.profile,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCount,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      userId: json['id'],
      name: json['name'] ?? "",
      profile: json['image_url'],
      lastMessage: json['last_message'] ?? "",
      lastMessageTime: json['last_message_time'] ?? "",
      unreadCount: json['unread_count'] ?? 0,
    );
  }
}
