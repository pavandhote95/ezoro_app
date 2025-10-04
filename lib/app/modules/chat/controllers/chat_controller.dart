import 'dart:convert';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app2/app/modules/chat/views/chat_view.dart';

class ChatController extends GetxController {
  final box = GetStorage();

  /// Messages list
  RxList<Map<String, dynamic>> messages = <Map<String, dynamic>>[].obs;
RxBool isLoading = false.obs;
  /// Add message instantly (optimistic UI)
  void addLocalMessage(Map<String, dynamic> msg) {
    messages.insert(0, msg); // reverse list
  }

  /// Fetch messages from API
  Future<void> fetchMessagesuser(String receiverId) async {
    final userId = box.read('user_id').toString();
    final token = box.read('token');
    if (token == null) return;

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse("https://kotiboxglobaltech.com/travel_app/api/messages"),
      )
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..fields['sender_id'] = userId
        ..fields['receiver_id'] = receiverId;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['status'] == true && data['data'] != null) {
          final serverMessages = List<Map<String, dynamic>>.from(data['data']);

          // convert all server times to local
          for (var msg in serverMessages) {
            if (msg['created_at'] != null) {
              msg['created_at'] =
                  DateTime.parse(msg['created_at']).toLocal().toIso8601String();
            }
          }

          // merge with local (avoid duplicates)
          messages.removeWhere((m) =>
              m['is_local'] == true &&
              serverMessages.any((s) => s['message'] == m['message']));

          messages.value = [
            ...serverMessages,
            ...messages.where((m) => m['is_local'] == true),
          ];
        }
      }
    } catch (e) {
      print("⚠️ Fetch exception: $e");
    }
  }

  /// Send message instantly (optimistic UI)
  Future<void> sendMessageusertouser({
    required String receiverId,
    required String message,
    String messageType = "text",
  }) async {
    final userId = box.read('user_id').toString();
    final token = box.read('token');
    if (token == null) return;

    // Add local message
    addLocalMessage({
      "sender_id": userId,
      "receiver_id": receiverId,
      "message": message,
      "created_at": DateTime.now().toLocal().toIso8601String(),
      "is_read": 0,
      "is_local": true,
    });

    // Send to server
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(
            "https://kotiboxglobaltech.com/travel_app/api/messages/send"),
      )
        ..headers.addAll({
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        })
        ..fields['receiver_id'] = receiverId
        ..fields['sender_id'] = userId
        ..fields['message'] = message
        ..fields['message_type'] = messageType;

      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.body.isNotEmpty) {
        final data = jsonDecode(response.body);
        if (data['status'] == true) {
          // Refresh immediately
          await fetchMessagesuser(receiverId);
        }
      }
    } catch (e) {
      print("⚠️ Send exception: $e");
    }
  }

  /// Fast Stream (poll every 3 seconds instead of 1 to avoid flicker)
  Stream<List<Map<String, dynamic>>> messageStream(String receiverId) async* {
    while (true) {
      await fetchMessagesuser(receiverId);
      yield messages;
      await Future.delayed(const Duration(seconds: 1));
    }
  }

  /// Generate unique chatId
  String getChatId(dynamic userA, dynamic userB) {
    final idA = userA.toString();
    final idB = userB.toString();
    return idA.hashCode <= idB.hashCode ? '${idA}_$idB' : '${idB}_$idA';
  }

  /// Start chat with user and navigate to ChatView
  void startChatWithUser(Map<String, dynamic> otherUserProfile) {
    final currentUserId = box.read('user_id').toString();
    final otherUserId = otherUserProfile['id'].toString();
    final otherUserName = otherUserProfile['name'] ?? "Unknown";
    final otherUserImage = otherUserProfile['profile'] ?? "";
    final chatId = getChatId(currentUserId, otherUserId);

    Get.to(() => ChatView(
          currentUser: currentUserId,
          otherUser: otherUserName,
          otherUserImage: otherUserImage,
          otherUserId: otherUserId,
          chatId: chatId,
        ));
  }

  /// Format message time nicely (HH:mm)
  String formatLocalTime(String utcTime) {
    try {
      final dateTime = DateTime.parse(utcTime).toLocal();
      return "${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return utcTime;
    }
  }
}
