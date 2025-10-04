class PostModel {
  final int id;
  final String question;
  final String location;
  final String status;
  final String image;
  final String userId;
  final String createdAt;

  PostModel({
    required this.id,
    required this.question,
    required this.location,
    required this.status,
    required this.image,
    required this.userId,
    required this.createdAt,
  });

  factory PostModel.fromJson(Map<String, dynamic> json) {
    return PostModel(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      location: json['location'] ?? '',
      status: json['status'] ?? '',
      image: json['image'] ?? '',
      userId: json['user_id'] ?? '',
      createdAt: json['created_at'] ?? '',
    );
  }
}
