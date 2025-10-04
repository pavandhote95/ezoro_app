// comment_model.dart
import 'dart:convert';

CommentPostModel commentPostModelFromJson(String str) =>
    CommentPostModel.fromJson(json.decode(str));

String commentPostModelToJson(CommentPostModel data) =>
    json.encode(data.toJson());

class CommentPostModel {
  bool status;
  List<CommentDatum> data;

  CommentPostModel({
    required this.status,
    required this.data,
  });

  factory CommentPostModel.fromJson(Map<String, dynamic> json) =>
      CommentPostModel(
        status: json["status"] ?? false,
        data: json["data"] == null
            ? []
            : List<CommentDatum>.from(
                json["data"].map((x) => CommentDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class CommentDatum {
  int id;
  int postId;
  int userId;
  int? parentId;
  String comment;
  DateTime createdAt;
  DateTime updatedAt;
  int likesCount;
  int dislikesCount;
  int userLiked;
  int userDisliked;
  User user;
  List<CommentDatum> replies;

  CommentDatum({
    required this.id,
    required this.postId,
    required this.userId,
    this.parentId,
    required this.comment,
    required this.createdAt,
    required this.updatedAt,
    required this.likesCount,
    required this.dislikesCount,
    required this.userLiked,
    required this.userDisliked,
    required this.user,
    required this.replies,
  });

  factory CommentDatum.fromJson(Map<String, dynamic> json) => CommentDatum(
        id: json["id"] ?? 0,
        postId: json["post_id"] ?? 0,
        userId: json["user_id"] ?? 0,
        parentId: json["parent_id"],
        comment: json["comment"] ?? "",
        createdAt: DateTime.tryParse(json["created_at"] ?? "") ?? DateTime.now(),
        updatedAt: DateTime.tryParse(json["updated_at"] ?? "") ?? DateTime.now(),
        likesCount: json["likes_count"] ?? 0,
        dislikesCount: json["dislikes_count"] ?? 0,
        userLiked: json["user_liked"] ?? 0,
        userDisliked: json["user_disliked"] ?? 0,
        user: User.fromJson(json["user"] ?? {}),
        replies: json["replies"] == null
            ? []
            : List<CommentDatum>.from(
                json["replies"].map((x) => CommentDatum.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "post_id": postId,
        "user_id": userId,
        "parent_id": parentId,
        "comment": comment,
        "created_at": createdAt.toIso8601String(),
        "updated_at": updatedAt.toIso8601String(),
        "likes_count": likesCount,
        "dislikes_count": dislikesCount,
        "user_liked": userLiked,
        "user_disliked": userDisliked,
        "user": user.toJson(),
        "replies": List<dynamic>.from(replies.map((x) => x.toJson())),
      };
}

class User {
  int id;
  String name;
  String image;
  int userPoints;

  User({
    required this.id,
    required this.name,
    required this.image,
    required this.userPoints,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: json["id"] ?? 0,
        name: json["name"] ?? "",
        image: json["image_url"] ?? "",
        userPoints: json["user_points"] ?? 0,
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "image_url": image,
        "user_points": userPoints,
      };
}