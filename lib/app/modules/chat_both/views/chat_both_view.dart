import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:travel_app2/app/modules/chat/controllers/chat_controller.dart';
import 'package:travel_app2/app/modules/chat_with_expert/controllers/chat_with_expert_controller.dart';

class ChatBothView extends StatefulWidget {
  final String currentUser;
  final String otherUser;
  final String otherUserImage;
  final String otherUserId;
  final String chatId;
  final bool isExpert;

  const ChatBothView({
    super.key,
    required this.currentUser,
    required this.otherUser,
    required this.otherUserImage,
    required this.otherUserId,
    required this.chatId,
    required this.isExpert,
  });

  @override
  State<ChatBothView> createState() => _ChatBothViewState();
}

class _ChatBothViewState extends State<ChatBothView> {
  final ScrollController _scrollController = ScrollController();
  late final dynamic controller;
  final TextEditingController _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();

    if (widget.isExpert) {
      controller = Get.put(ChatWithExpertController());
      controller.fetchMessagesusertoexpert(receiverId: int.parse(widget.otherUserId));
    } else {
      controller = Get.put(ChatController());
      controller.fetchMessagesuser(widget.otherUserId);
    }
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    if (widget.isExpert) {
      controller.sendMessageToExpert(
        receiverId: int.parse(widget.otherUserId),
        message: text,
      );
    } else {
      controller.sendMessageusertouser(
        receiverId: widget.otherUserId,
        message: text,
      );
    }

    _messageController.clear();
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
          // ✅ Messages List
      Expanded(
  child: Obx(() {
    final isLoading = controller.isLoading.value;
    
    final messages = controller.messages;

     if (controller.isLoading.value) {
           return Center(
            child: SizedBox(
              height: 120,
              width: 120,
              child: Lottie.asset(
                'assets/lottie/Loading.json', // ✅ apna asset path yaha do
                repeat: true,
                animate: true,
          
              ),
            ),
          );
        }
    if (messages.isEmpty) {
        return Center(
            child: SizedBox(
              height: 120,
              width: 120,
              child: Lottie.asset(
                'assets/lottie/Loading.json', // ✅ apna asset path yaha do
                repeat: true,
                animate: true,
          
              ),
            ),
          );
    }

              return ListView.builder(
                controller: _scrollController,
                reverse: true,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final msg = messages[messages.length - 1 - index];
                  final isMe = widget.isExpert
                      ? msg['sender'] == "me"
                      : msg['sender_id'].toString() == widget.currentUser;

                  final timestamp = msg['created_at'] ?? DateTime.now().toString();
                  final time = DateFormat('hh:mm a').format(DateTime.parse(timestamp));

                  return Align(
                    alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.7),
                      decoration: BoxDecoration(
                        color: isMe ? const Color(0xFF056162) : const Color(0xFF262D31),
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: isMe ? const Radius.circular(18) : Radius.zero,
                          bottomRight: isMe ? Radius.zero : const Radius.circular(18),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            msg['message'] ?? '',
                            style: const TextStyle(color: Colors.white, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                time,
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade300),
                              ),
                              if (isMe && !widget.isExpert) ...[
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
            }),
          ),

          // ✅ Message Input & Buttons
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8),
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
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),

                  // ✅ Pay button only for non-experts
                  if (GetStorage().read('user_type') != 'user')
                    InkWell(
                      onTap: () {
                        print("Pay button clicked");
                        // Add your payment logic here
                      },
                      borderRadius: BorderRadius.circular(25),
                      child: Container(
                        width: 42,
                        height: 42,
                        decoration: const BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Text(
                            "₹",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(width: 8),

                  // ✅ Send button always
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


  Widget _buildAvatar(String? imageUrl, String name) {
    if (imageUrl != null && imageUrl.isNotEmpty && imageUrl.startsWith("http")) {
      return CircleAvatar(radius: 20, backgroundImage: NetworkImage(imageUrl));
    } else {
      final initials = (name.isNotEmpty ? name[0] : "?").toUpperCase();
      final colors = [
        Colors.redAccent,
        Colors.blueAccent,
        Colors.green,
        Colors.orange,
        Colors.purple,
        Colors.teal
      ];
      return CircleAvatar(
        radius: 20,
        backgroundColor: colors[name.hashCode % colors.length],
        child: Text(
          initials,
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      );
    }
  }
}
