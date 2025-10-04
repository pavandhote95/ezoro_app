import 'dart:convert';
import 'package:get/get.dart';

ApiPostModel apiPostModelFromJson(String str) =>
    ApiPostModel.fromJson(json.decode(str) as Map<String, dynamic>);

String apiPostModelToJson(ApiPostModel data) => json.encode(data.toJson());

class ApiPostModel {
  final bool status;
  final String message;
  final List<Datum> data;

  ApiPostModel({
    required this.status,
    required this.message,
    required this.data,
  });

  factory ApiPostModel.fromJson(Map<String, dynamic> json) => ApiPostModel(
        status: (json['status'] ?? false) as bool,
        message: (json['message'] ?? '') as String,
        data: (json['data'] is List ? (json['data'] as List) : const <dynamic>[])
            .map((e) => Datum.fromJson(e as Map<String, dynamic>))
            .toList(),
      );

  Map<String, dynamic> toJson() => {
        'status': status,
        'message': message,
        'data': data.map((e) => e.toJson()).toList(),
      };

  ApiPostModel copyWith({
    bool? status,
    String? message,
    List<Datum>? data,
  }) =>
      ApiPostModel(
        status: status ?? this.status,
        message: message ?? this.message,
        data: data ?? this.data,
      );
}

class Datum {
  final int id;
  final String pId;
  final String question;
  final String location;
  final String status;
  final List<String> image;
  final String userId;
  final User? user;
  final List<int> postId;
  final int likesCount;
  final int dislikesCount;
  final int isLiked;
  final int isDisliked;
  final DateTime? createdAt;
  final String postUrl;
  final Postuser? postuser;
  final RxList<Comment> comments;

  Datum({
    required this.id,
    required this.pId,
    required this.question,
    required this.location,
    required this.status,
    required this.image,
    required this.userId,
    required this.user,
    required this.postId,
    required this.likesCount,
    required this.dislikesCount,
    required this.isLiked,
    required this.isDisliked,
    required this.createdAt,
    required this.postUrl,
    required this.postuser,
    required this.comments,
  });

  factory Datum.fromJson(Map<String, dynamic> json) => Datum(
        id: _asInt(json['id']),
        pId: _asString(json['p_id'] ?? json['pId']),
        question: _asString(json['question']),
        location: _asString(json['location']),
        status: _asString(json['status']),
        image: _asStringList(json['image']).isEmpty
            ? ["https://via.placeholder.com/150"]
            : _asStringList(json['image']),
        userId: _asString(json['user_id'] ?? json['userId']),
        user: json['user'] is Map<String, dynamic>
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
        postId: _asIntList(json['post_id'] ?? json['postId']),
        likesCount: _asInt(json['likes_count']),
        dislikesCount: _asInt(json['dislikes_count']),
        isLiked: _as01(json['is_liked'] ?? json['isLiked']),
        isDisliked: _as01(json['is_disliked'] ?? json['isDisliked']),
        createdAt: _asDateTime(json['created_at']),
        postUrl: _asString(json['post_url'] ?? json['postUrl']),
        postuser: json['postuser'] is Map<String, dynamic>
            ? Postuser.fromJson(json['postuser'] as Map<String, dynamic>)
            : (json['post_user'] is Map<String, dynamic>
                ? Postuser.fromJson(json['post_user'] as Map<String, dynamic>)
                : Postuser(
                    id: 0,
                    name: "Unknown User",
                    email: "",
                    phoneNumber: "",
                    bio: "",
                    userPoints: 0,
                    image: "",
                    travelDetail: null,
                  )),
        comments: RxList<Comment>(
          json['comments'] is List
              ? (json['comments'] as List)
                  .map((c) => Comment.fromJson(c as Map<String, dynamic>))
                  .toList()
              : [],
        ),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'p_id': pId,
        'question': question,
        'location': location,
        'status': status,
        'image': image,
        'user_id': userId,
        'user': user?.toJson(),
        'post_id': postId,
        'likes_count': likesCount,
        'dislikes_count': dislikesCount,
        'is_liked': isLiked,
        'is_disliked': isDisliked,
        'created_at': createdAt?.toIso8601String(),
        'post_url': postUrl,
        'postuser': postuser?.toJson(),
        'comments': comments.map((c) => c.toJson()).toList(),
      };

  Datum copyWith({
    int? id,
    String? pId,
    String? question,
    String? location,
    String? status,
    List<String>? image,
    String? userId,
    User? user,
    List<int>? postId,
    int? likesCount,
    int? dislikesCount,
    int? isLiked,
    int? isDisliked,
    DateTime? createdAt,
    String? postUrl,
    Postuser? postuser,
    RxList<Comment>? comments,
  }) =>
      Datum(
        id: id ?? this.id,
        pId: pId ?? this.pId,
        question: question ?? this.question,
        location: location ?? this.location,
        status: status ?? this.status,
        image: image ?? this.image,
        userId: userId ?? this.userId,
        user: user ?? this.user,
        postId: postId ?? this.postId,
        likesCount: likesCount ?? this.likesCount,
        dislikesCount: dislikesCount ?? this.dislikesCount,
        isLiked: isLiked ?? this.isLiked,
        isDisliked: isDisliked ?? this.isDisliked,
        createdAt: createdAt ?? this.createdAt,
        postUrl: postUrl ?? this.postUrl,
        postuser: postuser ?? this.postuser,
        comments: comments ?? this.comments,
      );
}

class Comment {
  final int id;
  final int userId;
  final String comment;
  final String? createdAt;
  final User? user;

  Comment({
    required this.id,
    required this.userId,
    required this.comment,
    this.createdAt,
    this.user,
  });

  factory Comment.fromJson(Map<String, dynamic> json) => Comment(
        id: _asInt(json['id']),
        userId: _asInt(json['user_id']),
        comment: _asString(json['comment']),
        createdAt: _asStringOrNull(json['created_at']),
        user: json['user'] is Map<String, dynamic>
            ? User.fromJson(json['user'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'user_id': userId,
        'comment': comment,
        'created_at': createdAt,
        'user': user?.toJson(),
      };
}

class User {
  final int id;
  final String name;
  final String email;
  final String image;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.image,
  });

  factory User.fromJson(Map<String, dynamic> json) => User(
        id: _asInt(json['id']),
        name: _asString(json['name']),
        email: _asString(json['email']),
        image: _asString(json['image']),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'image': image,
      };
}

class Postuser {
  final int id;
  final String name;
  final String email;
  final String phoneNumber;
  final String bio;
  final dynamic userPoints;
  final String image;
  final TravelDetail? travelDetail;

  Postuser({
    required this.id,
    required this.name,
    required this.email,
    required this.phoneNumber,
    required this.bio,
    required this.userPoints,
    required this.image,
    required this.travelDetail,
  });

  factory Postuser.fromJson(Map<String, dynamic> json) => Postuser(
        id: _asInt(json['id']),
        name: _asString(json['name']),
        email: _asString(json['email']),
        phoneNumber: _asString(json['phone_number'] ?? json['phoneNumber']),
        bio: _asString(json['bio']),
        userPoints: json['user_points'],
        image: _asString(json['image']),
        travelDetail: json['travel_detail'] is Map<String, dynamic>
            ? TravelDetail.fromJson(json['travel_detail'] as Map<String, dynamic>)
            : null,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'phone_number': phoneNumber,
        'bio': bio,
        'user_points': userPoints,
        'image': image,
        'travel_detail': travelDetail?.toJson(),
      };
}

class TravelDetail {
  final String? description;
  final String? location;
  final String? travelInterest;
  final String? visitedPlace;
  final String? dreamDestination;
  final String? language;
  final String? travelType;
  final dynamic travelMode;

  TravelDetail({
    this.description,
    this.location,
    this.travelInterest,
    this.visitedPlace,
    this.dreamDestination,
    this.language,
    this.travelType,
    this.travelMode,
  });

  factory TravelDetail.fromJson(Map<String, dynamic> json) => TravelDetail(
        description: _asStringOrNull(json['description']),
        location: _asStringOrNull(json['location']),
        travelInterest: _asStringOrNull(json['travel_interest']),
        visitedPlace: _asStringOrNull(json['visited_place']),
        dreamDestination: _asStringOrNull(json['dream_destination']),
        language: _asStringOrNull(json['language']),
        travelType: _asStringOrNull(json['travel_type']),
        travelMode: json['travel_mode'],
      );

  Map<String, dynamic> toJson() => {
        'description': description,
        'location': location,
        'travel_interest': travelInterest,
        'visited_place': visitedPlace,
        'dream_destination': dreamDestination,
        'language': language,
        'travel_type': travelType,
        'travel_mode': travelMode,
      };
}

int _asInt(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is String) return int.tryParse(v) ?? fallback;
  if (v is double) return v.toInt();
  if (v is bool) return v ? 1 : 0;
  return fallback;
}

int _as01(dynamic v) {
  if (v is bool) return v ? 1 : 0;
  return _asInt(v) > 0 ? 1 : 0;
}

String _asString(dynamic v, [String fallback = '']) {
  if (v == null) return fallback;
  if (v is String) return v;
  return v.toString();
}

String? _asStringOrNull(dynamic v) {
  if (v == null) return null;
  if (v is String) return v;
  return v.toString();
}

DateTime? _asDateTime(dynamic v) {
  if (v == null) return null;
  if (v is DateTime) return v;
  if (v is String) {
    try {
      return DateTime.parse(v);
    } catch (_) {
      return null;
    }
  }
  return null;
}

List<String> _asStringList(dynamic v) {
  if (v is List) {
    return v.map((e) => _asString(e)).toList();
  }
  return <String>[];
}

List<int> _asIntList(dynamic v) {
  if (v is List) {
    return v.map((e) => _asInt(e)).toList();
  }
  return <int>[];
}