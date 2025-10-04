class PostModel {
  final String username;
  final String userImage;
  final String location;
  final String time;
  final String postText;
  final String postImage;
  final int likes;

  PostModel({
    required this.username,
    required this.userImage,
    required this.location,
    required this.time,
    required this.postText,
    required this.postImage,
    required this.likes,
  });
}
