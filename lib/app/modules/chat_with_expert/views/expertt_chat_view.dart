
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:travel_app2/app/modules/chat_with_expert/controllers/chat_with_expert_controller.dart';

class ChatWithExpertView extends StatefulWidget {
  final int expertId;
  final String expertName;
  final String expertImage;
  final String expertPrice;

  const ChatWithExpertView({
    super.key,
    required this.expertId,
    required this.expertName,
    required this.expertImage,
    required this.expertPrice,
  });

  @override
  State<ChatWithExpertView> createState() => _ChatWithExpertViewState();
}

class _ChatWithExpertViewState extends State<ChatWithExpertView> {
  late ChatWithExpertController controller;
  final TextEditingController messageController = TextEditingController();
  final ScrollController scrollController = ScrollController();
  late Razorpay _razorpay;

  final box = GetStorage();
  late String userType;

  @override
  void initState() {
    super.initState();
    controller = Get.put(ChatWithExpertController());
    controller.fetchMessagesusertoexpert(receiverId: widget.expertId);
    ever(controller.messages, (_) => scrollToBottom());

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);

    userType = box.read('role') ?? "user"; // user or expert
  }

  @override
  void dispose() {
    _razorpay.clear();
    messageController.dispose();
    scrollController.dispose();
    super.dispose();
  }

  void scrollToBottom() {
    if (scrollController.hasClients) {
      scrollController.animateTo(
        scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _sendMessage() {
    final text = messageController.text.trim();
    if (text.isNotEmpty) {
      controller.sendMessageToExpert(
        receiverId: widget.expertId,
        message: text,
      );
      messageController.clear();
      scrollToBottom();
    }
  }

  /// Smart Timestamp Formatter (Today, Yesterday, or Date)
  String formatMessageTime(String time) {
    try {
      final dt = DateTime.parse(time).toLocal();
      final now = DateTime.now();

      // Today
      if (dt.day == now.day && dt.month == now.month && dt.year == now.year) {
        return DateFormat('hh:mm a').format(dt); // 3:37 PM
      }

      // Yesterday
      final yesterday = now.subtract(const Duration(days: 1));
      if (dt.day == yesterday.day && dt.month == yesterday.month && dt.year == yesterday.year) {
        return "Yesterday ${DateFormat('hh:mm a').format(dt)}";
      }

      // Older
      return DateFormat('dd MMM, hh:mm a').format(dt); // 24 Sep, 03:37 PM
    } catch (_) {
      return '';
    }
  }

  void _showPaymentModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
        height: MediaQuery.of(context).size.height * 0.45,
        decoration: const BoxDecoration(
          color: Color(0xFF1A1A1A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 10),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade600,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    'Pay Expert',
                    style: GoogleFonts.poppins(
                        fontSize: 24, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    widget.expertName,
                    style: GoogleFonts.poppins(fontSize: 16, color: Colors.grey.shade300),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade800,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade600),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.currency_rupee, color: Colors.white, size: 22),
                    const SizedBox(width: 8),
                    Text(
                      widget.expertPrice,
                      style: GoogleFonts.poppins(
                          fontSize: 20, fontWeight: FontWeight.w600, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close modal
                        _openRazorpayPayment(widget.expertPrice);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green.shade600,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Pay Now',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: Text(
                      'Cancel',
                      style: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 16),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openRazorpayPayment(String amount) {
    var options = {
      'key': 'rzp_test_RIcVT1kjDlJh9q',
      'amount': (double.parse(amount) * 100).toInt(), // Amount in paise
      'name': widget.expertName,
      'description': 'Consultation Payment',
      'prefill': {'contact': '9942549844', 'email': 'Bidyawantp@gmail.com'},
      'theme': {'color': '#F37254'}
    };

    try {
      _razorpay.open(options);
    } catch (e) {
      debugPrint('Error opening Razorpay: $e');
      Get.snackbar(
        'Error',
        'Failed to open payment gateway: $e',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
    }
  }

  void _handlePaymentSuccess(PaymentSuccessResponse response) async {
    final paymentId = response.paymentId ?? '';
    final expertId = widget.expertId.toString();

    print('💳 Payment Success: payment_id=$paymentId, expert_id=$expertId');

    if (paymentId.isEmpty) {
      Get.snackbar(
        'Error',
        'Payment ID is empty. Cannot verify payment.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    final token = box.read('token') ?? '';
    if (token.isEmpty) {
      Get.snackbar(
        'Error',
        'User token not found. Please login again.',
        backgroundColor: Colors.red.shade600,
        colorText: Colors.white,
      );
      return;
    }

    // Verify payment with amount for capture
    await controller.verifyPayment(
      paymentId: paymentId,
      expertId: expertId,
      amount: widget.expertPrice, // Pass amount for capture
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    print("❌ Payment Failed");
    print("Code: ${response.code}");
    print("Message: ${response.message}");

    final orderId = response.error?['metadata']?['order_id'] ?? 'N/A';
    final paymentId = response.error?['metadata']?['payment_id'] ?? 'Not generated';

    Get.snackbar(
      'Payment Failed',
      'Code: ${response.code}\n'
          'Message: ${response.message}\n'
          'Order ID: $orderId\n'
          'Payment ID: $paymentId',
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
      duration: const Duration(seconds: 5),
    );
  }

  void _handleExternalWallet(ExternalWalletResponse response) {
    Get.snackbar(
      'Wallet',
      'External wallet: ${response.walletName}',
      backgroundColor: Colors.orange.shade600,
      colorText: Colors.white,
    );

    
  }

  Widget _buildMessageBubble(Map<String, dynamic> msg) {
    final isSender = msg['sender'] == "me";
    final timeString = msg['created_at'] != null ? formatMessageTime(msg['created_at']) : '';

    return Align(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSender ? Colors.blue.shade600 : Colors.grey[800],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: isSender ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              msg['message'] ?? '',
              style: GoogleFonts.poppins(color: Colors.white),
            ),
            const SizedBox(height: 4),
            if (timeString.isNotEmpty)
              Text(
                timeString,
                style: GoogleFonts.poppins(color: Colors.grey.shade300, fontSize: 10),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: GestureDetector(
          onTap: () {
            Get.toNamed(
              '/user-profile', // Update with your actual route
              arguments: {"user_id": widget.expertId},
            );
          },
          child: Row(
            children: [
              CircleAvatar(backgroundImage: NetworkImage(widget.expertImage)),
              const SizedBox(width: 10),
              Text(
                widget.expertName,
                style: GoogleFonts.poppins(color: Colors.white),
              ),
            ],
          ),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
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
              return ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                itemCount: controller.messages.length,
                itemBuilder: (context, index) {
                  return _buildMessageBubble(controller.messages[index]);
                },
              );
            }),
          ),
          SafeArea(
            child: Container(
              padding: const EdgeInsets.all(12),
              color: Colors.grey.shade900,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: messageController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: "Type a message...",
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: Colors.grey.shade800,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (userType != "expert")
                    InkWell(
                      onTap: _showPaymentModal,
                      borderRadius: BorderRadius.circular(30),
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
                  IconButton(
                    onPressed: _sendMessage,
                    icon: const Icon(Icons.send, color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
 
 
        ],
      ),
    );
  }
}