import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:swipe_cards/swipe_cards.dart';
import 'package:travel_app2/app/modules/home/views/Tabes/comment_model.dart';
import 'package:travel_app2/app/services/api_service.dart';
import '../../../models/post_model.dart';

class CommunityController extends GetxController {
  RxList<Datum> allPosts = <Datum>[].obs;
  RxList<Datum> locationPosts = <Datum>[].obs;
  RxList<Datum> filteredPosts = <Datum>[].obs;
  RxInt currentIndex = 0.obs;
  RxBool isTravelingMode = false.obs;
  RxMap<int, bool> isExpanded = <int, bool>{}.obs;
  late MatchEngine matchEngine;
  final ApiService apiService = Get.find<ApiService>();
  final RxString searchQuery = ''.obs;
  final GetStorage box = GetStorage();

  /// commentsMap: postId -> list of CommentDatum
  final RxMap<int, List<CommentDatum>> commentsMap = <int, List<CommentDatum>>{}.obs;

  /// commentsLoading: postId -> isLoading
  final RxMap<int, bool> commentsLoading = <int, bool>{}.obs;

  @override
  void onInit() {
    super.onInit();
    initializeSwipeEngine();
    fetchPosts();
  }

  // CommunityController ke andar
var repliesExpanded = <int, bool>{}.obs;

void toggleReplies(int commentId) {
  repliesExpanded[commentId] = !(repliesExpanded[commentId] ?? false);
  repliesExpanded.refresh();
}


  // ----------------- POSTS / SWIPE -----------------
  Future<void> fetchPosts() async {
    try {
      final data = await apiService.fetchPosts();
      if (data['status'] == true && data['data'] is List) {
        allPosts.value = (data['data'] as List)
            .map((e) => Datum.fromJson(e as Map<String, dynamic>))
            .toList();
        updateFilteredPosts();
        initializeSwipeEngine();
      }
    } catch (e) {
      debugPrint('❌ Error in fetchPosts: $e');
    }
  }

  void updateFilteredPosts() {
    final basePosts = isTravelingMode.value ? locationPosts : allPosts;
    if (searchQuery.value.isEmpty) {
      filteredPosts.assignAll(basePosts);
    } else {
      final keyword = searchQuery.value.toLowerCase();
      filteredPosts.assignAll(
        basePosts.where(
          (post) =>
              post.question.toLowerCase().contains(keyword) ||
              post.location.toLowerCase().contains(keyword),
        ),
      );
    }
  }

  void searchPosts(String keyword) {
    searchQuery.value = keyword;
    updateFilteredPosts();
    initializeSwipeEngine();
  }

  void initializeSwipeEngine() {
    final swipeItems = filteredPosts.isEmpty
        ? <SwipeItem>[]
        : List<SwipeItem>.generate(
            filteredPosts.length * 100,
            (index) => SwipeItem(
              content: filteredPosts[index % filteredPosts.length],
              likeAction: () => incrementIndex(index % filteredPosts.length),
              nopeAction: () =>   debugPrint('⛔ Left swipe disabled')
            ),
          );
    matchEngine = MatchEngine(swipeItems: swipeItems);
    update();
  }

  void incrementIndex(int index) {
    if (filteredPosts.isNotEmpty) {
      currentIndex.value = (index + 1) % filteredPosts.length;
    }
    update();
  }

  void reset() {
    currentIndex.value = 0;
    fetchPosts();
    update();
  }

  void toggleExpanded(int index) {
    isExpanded[index] = !(isExpanded[index] ?? false);
    update();
  }

  Future<void> fetchPostsByLocation(String location) async {
    try {
      final data = await apiService.fetchPostsByLocation(location);
      if (data['status'] == true && data['data'] is List) {
        locationPosts.value =
            (data['data'] as List).map((e) => Datum.fromJson(e)).toList();
        updateFilteredPosts();
        fetchPosts();
        initializeSwipeEngine();
      }
    } catch (e) {
      debugPrint('❌ Error in fetchPostsByLocation: $e');
    }
  }

  void setTravelingMode(bool isTraveling) {
    isTravelingMode.value = isTraveling;
    updateFilteredPosts();
  }

  // ----------------- COMMENTS -----------------

  /// Fetch comments for a post and set loading state
  Future<void> fetchComments(int postId) async {
    const String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
    final url = Uri.parse('$baseUrl/comments/$postId');
    final token = box.read('token');

    debugPrint('📥 fetchComments() called for post: $postId');

    commentsLoading[postId] = true;
    commentsMap[postId] = commentsMap[postId] ?? [];
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': token != null ? 'Bearer $token' : '',
          'Accept': 'application/json',
        },
      );

      debugPrint('📥 fetchComments status: ${response.statusCode}');
      debugPrint('📥 fetchComments body: ${response.body}');

      if (response.statusCode == 200) {
        final data = commentPostModelFromJson(response.body);
        if (data.status) {
          commentsMap[postId] = data.data.toList();
          debugPrint('✅ Comments updated for post $postId (count: ${data.data.length})');
        } else {
          debugPrint('❌ API returned status=false for comments');
        }
      } else {
        debugPrint('❌ fetchComments failed with status ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error in fetchComments: $e');
    } finally {
      commentsLoading[postId] = false;
      commentsMap[postId] = commentsMap[postId]?.toList() ?? [];
      update();
    }
  }

  /// Add comment
  Future<void> addComment({
    required int postId,
    required String comment,
    int? parentId,
  }) async {
    const String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
    final url = Uri.parse('$baseUrl/add-comments');
    final token = box.read('token');

    if (token == null) {
      Get.snackbar("Auth Error", "You must login first",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final body = {
        'post_id': postId.toString(),
        'comment': comment,
      };
      if (parentId != null) body['parent_id'] = parentId.toString();

      debugPrint("📝 addComment => $body");

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: body,
      );

      debugPrint("📥 addComment status: ${response.statusCode}");
      debugPrint("📥 addComment body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Comment added successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        await fetchComments(postId);
      } else {
        Get.snackbar("Error", "Failed to add comment",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint("❌ Error in addComment: $e");
      Get.snackbar("Error", "Something went wrong",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ----------------- Comment Like Toggle -----------------
  CommentDatum? _findCommentRef(List<CommentDatum> list, int commentId) {
    for (var c in list) {
      if (c.id == commentId) return c;
      if (c.replies.isNotEmpty) {
        final res = _findCommentRef(c.replies, commentId);
        if (res != null) return res;
      }
    }
    return null;
  }

  Future<void> toggleCommentLike({
    required int postId,
    required int commentId,
  }) async {
    const String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
    final url = Uri.parse('$baseUrl/comments/react');
    final token = box.read('token');

    if (token == null) {
      Get.snackbar("Auth Error", "You must login first",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    // Find the comment or reply
    final comments = commentsMap[postId] ?? [];
    final commentRef = _findCommentRef(comments, commentId);
    if (commentRef == null) {
      debugPrint('❌ Comment/Reply with ID $commentId not found for post $postId');
      await fetchComments(postId); // Refresh comments if not found
      return;
    }

    // Optimistic update
    final wasLiked = commentRef.userLiked == 1;
    final newReaction = wasLiked ? 'dislike' : 'like';
    final oldLikes = commentRef.likesCount;
    final oldUserLiked = commentRef.userLiked;

    commentRef.userLiked = wasLiked ? 0 : 1;
    commentRef.likesCount = wasLiked ? (oldLikes > 0 ? oldLikes - 1 : 0) : oldLikes + 1;

    // Update the comments map to trigger UI refresh
    commentsMap[postId] = comments.toList();
    update();

    debugPrint('📝 toggleCommentLike: postId=$postId, commentId=$commentId, reaction=$newReaction');

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'post_id': postId.toString(),
          'comment_id': commentId.toString(),
          'type': newReaction,
        }),
      );

      debugPrint('📥 toggleCommentLike status: ${response.statusCode}');
      debugPrint('📥 toggleCommentLike body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final Map<String, dynamic> resJson = jsonDecode(response.body);
        if (resJson.containsKey('likes_count')) {
          final updatedCount = int.tryParse('${resJson['likes_count']}') ?? commentRef.likesCount;
          commentRef.likesCount = updatedCount;
          commentRef.userLiked = newReaction == 'like' ? 1 : 0;
          commentsMap[postId] = comments.toList();
          update();
          debugPrint('✅ Comment/Reply like updated: likes=${commentRef.likesCount}, userLiked=${commentRef.userLiked}');
        } else {
          debugPrint('❌ No likes_count in response, refreshing comments');
          await fetchComments(postId);
        }
      } else {
        // Rollback on failure
        commentRef.userLiked = oldUserLiked;
        commentRef.likesCount = oldLikes;
        commentsMap[postId] = comments.toList();
        update();
        Get.snackbar('Error', 'Failed to update comment reaction',
            backgroundColor: Colors.red, colorText: Colors.white);
        debugPrint('❌ toggleCommentLike failed with status ${response.statusCode}');
      }
    } catch (e) {
      // Rollback on error
      commentRef.userLiked = oldUserLiked;
      commentRef.likesCount = oldLikes;
      commentsMap[postId] = comments.toList();
      update();
      Get.snackbar('Error', 'Something went wrong',
          backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint('❌ Error in toggleCommentLike: $e');
    }
  }

  // ----------------- Reply API -----------------
  Future<void> replyToComment({
    required int postId,
    required int parentId,
    required String reply,
  }) async {
    const String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
    final url = Uri.parse('$baseUrl/comment-on-comment');
    final token = box.read('token');

    if (token == null) {
      Get.snackbar("Auth Error", "You must login first",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    try {
      final body = {
        'post_id': postId.toString(),
        'parent_id': parentId.toString(),
        'comment': reply,
      };

      debugPrint('📝 replyToComment => $body');

      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
        body: body,
      );

      debugPrint('📥 replyToComment status: ${response.statusCode}');
      debugPrint('📥 replyToComment body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar("Success", "Reply added successfully",
            backgroundColor: Colors.green, colorText: Colors.white);
        await fetchComments(postId);
      } else {
        Get.snackbar("Error", "Failed to add reply",
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      debugPrint('❌ Error in replyToComment: $e');
      Get.snackbar("Error", "Something went wrong",
          backgroundColor: Colors.red, colorText: Colors.white);
    }
  }

  // ----------------- Post Like Toggle -----------------
  Future<void> toggleLike(int postId) async {
    const String baseUrl = 'https://kotiboxglobaltech.com/travel_app/api';
    final url = Uri.parse('$baseUrl/post/react');
    final token = box.read('token');

    if (token == null) {
      Get.snackbar("Auth Error", "You must login first",
          backgroundColor: Colors.red, colorText: Colors.white);
      return;
    }

    final indexAll = allPosts.indexWhere((p) => p.id == postId);
    if (indexAll == -1) return;

    final post = allPosts[indexAll];
    final alreadyLiked = post.isLiked == 1;
    final newReaction = alreadyLiked ? "dislike" : "like";

    final updatedPost = post.copyWith(
      isLiked: alreadyLiked ? 0 : 1,
      likesCount: alreadyLiked ? (post.likesCount > 0 ? post.likesCount - 1 : 0) : post.likesCount + 1,
    );

    allPosts[indexAll] = updatedPost;

    final indexFiltered = filteredPosts.indexWhere((p) => p.id == postId);
    if (indexFiltered != -1) filteredPosts[indexFiltered] = updatedPost;

    try {
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'post_id': postId.toString(), 'type': newReaction}),
      );

      debugPrint('📥 toggleLike status: ${response.statusCode}');
      debugPrint('📥 toggleLike body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final likesFromApi = data['likes_count'] != null
            ? int.tryParse('${data['likes_count']}') ?? updatedPost.likesCount
            : updatedPost.likesCount;

        final finalPost = updatedPost.copyWith(likesCount: likesFromApi);
        allPosts[indexAll] = finalPost;
        if (indexFiltered != -1) filteredPosts[indexFiltered] = finalPost;
      } else {
        allPosts[indexAll] = post;
        if (indexFiltered != -1) filteredPosts[indexFiltered] = post;
        Get.snackbar('Error', 'Failed to update post reaction',
            backgroundColor: Colors.red, colorText: Colors.white);
      }
    } catch (e) {
      allPosts[indexAll] = post;
      if (indexFiltered != -1) filteredPosts[indexFiltered] = post;
      Get.snackbar('Error', 'Something went wrong',
          backgroundColor: Colors.red, colorText: Colors.white);
      debugPrint('❌ Error in toggleLike: $e');
    }
  }
}