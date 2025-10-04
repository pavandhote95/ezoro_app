import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import '../controllers/chat_controller.dart';

class ChatView extends StatefulWidget {
  final String currentUser;      // logged in user id
  final String otherUser;        // name of other user
  final String chatId;           // combined id (for history / stream)
  final String otherUserImage;   // profile image url
  final String otherUserId;      // receiver user id

  const ChatView({
    super.key,
    required this.currentUser,
    required this.otherUser,
    required this.chatId,
    required this.otherUserImage,
    required this.otherUserId,
  });

  @override
  State<ChatView> createState() => _ChatViewState();
}

class _ChatViewState extends State<ChatView> {
  final TextEditingController _messageController = TextEditingController();
  final ChatController controller = Get.put(ChatController());
  final ScrollController _scrollController = ScrollController();

  late String receiverId;

  @override
  void initState() {
    super.initState();
    // ✅ Always take direct receiverId
    receiverId = widget.otherUserId;
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    // ✅ API call
    controller.sendMessageusertouser(receiverId: receiverId, message: text);

    _messageController.clear();

    // ✅ Auto scroll to bottom after sending
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121B22),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F2C34),
        elevation: 0,
        title: Row(
          children: [
            _buildAvatar(widget.otherUserImage, widget.otherUser),
            const SizedBox(width: 12),
            Text(
              widget.otherUser,
              style: GoogleFonts.openSans(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: controller.messageStream(receiverId),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return Center(
                    child: SizedBox(
                      height: 100,
                      width: 100,
                      child: Lottie.asset('assets/lottie/Loading.json'),
                    ),
                  );
                }

                final messages = snapshot.data ?? [];
                if (messages.isEmpty) {
                  return const Center(
                    child: Text("No messages yet",
                        style: TextStyle(color: Colors.white70)),
                  );
                }

                return ListView.builder(
                  controller: _scrollController,
                  reverse: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final msg = messages[messages.length - 1 - index];
                    final isMe =
                        msg['sender_id'].toString() == widget.currentUser;

                    final timestamp =
                        msg['created_at'] ?? DateTime.now().toString();
                    DateTime date =
                        DateTime.tryParse(timestamp) ?? DateTime.now();
                    final time = DateFormat('hh:mm a').format(date);

                    return Align(
                      alignment: isMe
                          ? Alignment.centerRight
                          : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                            vertical: 4, horizontal: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.7,
                        ),
                        decoration: BoxDecoration(
                          color: isMe
                              ? const Color(0xFF056162)
                              : const Color(0xFF262D31),
                          borderRadius: BorderRadius.only(
                            topLeft: const Radius.circular(18),
                            topRight: const Radius.circular(18),
                            bottomLeft: isMe
                                ? const Radius.circular(18)
                                : Radius.zero,
                            bottomRight: isMe
                                ? Radius.zero
                                : const Radius.circular(18),
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              msg['message'] ?? '',
                              style: const TextStyle(
                                  color: Colors.white, fontSize: 15),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  time,
                                  style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey.shade300),
                                ),
                                if (isMe) ...[
                                  const SizedBox(width: 4),
                                  Icon(
                                    Icons.done_all,
                                    size: 16,
                                    color: msg['is_read'] == 1
                                        ? Colors.lightBlueAccent
                                        : Colors.grey.shade400,
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          SafeArea(
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Message',
                        hintStyle: TextStyle(color: Colors.grey.shade400),
                        filled: true,
                        fillColor: const Color(0xFF2C2C2C),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(25),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  CircleAvatar(
                    backgroundColor: Colors.blue.shade700,
                    radius: 24,
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🔹 Avatar function (same as in DmView)
  Widget _buildAvatar(String? imageUrl, String name) {
    if (imageUrl != null &&
        imageUrl.isNotEmpty &&
        imageUrl.startsWith("http")) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: NetworkImage(imageUrl),
        backgroundColor: Colors.grey[800],
        onBackgroundImageError: (_, __) {},
      );
    } else {
      final initials = (name.isNotEmpty ? name[0] : "?").toUpperCase();
      final bgColors = [
        Colors.redAccent,
        Colors.blueAccent,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal,
      ];
      final colorIndex = name.hashCode % bgColors.length;

      return CircleAvatar(
        radius: 20,
        backgroundColor: bgColors[colorIndex],
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      );
    }
  }
}
