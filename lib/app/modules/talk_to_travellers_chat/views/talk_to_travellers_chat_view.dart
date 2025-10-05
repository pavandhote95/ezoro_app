import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:razorpay_flutter/razorpay_flutter.dart';
import 'package:travel_app2/app/modules/chat_with_expert/controllers/chat_with_expert_controller.dart';
import '../controllers/talk_to_travellers_chat_controller.dart';

class TalkToTravellersChatView extends StatefulWidget {
  final int travellerId;
  final String travellerName;
  final String travellerImage;
  final String price;

  const TalkToTravellersChatView({
    super.key,
    required this.travellerId,
    required this.travellerName,
    required this.travellerImage,
    required this.price,
  });

  @override
  State<TalkToTravellersChatView> createState() =>
      _TalkToTravellersChatViewState();
}

class _TalkToTravellersChatViewState extends State<TalkToTravellersChatView> {
  final TalkToTravellersChatController controller = Get.put(
    TalkToTravellersChatController(),
  );
  final ChatWithExpertController chatWithController = Get.put(
    ChatWithExpertController(),
  );

  final TextEditingController msgController = TextEditingController();
  final TextEditingController amountController = TextEditingController();
  final box = GetStorage();
  late String userType;
  late Razorpay _razorpay;

  @override
  void initState() {
    super.initState();
    userType = box.read("user_type") ?? "traveller";

    chatWithController.fetchMessagesusertoexpert(
      receiverId: widget.travellerId,
    );

    _razorpay = Razorpay();
    _razorpay.on(Razorpay.EVENT_PAYMENT_SUCCESS, _handlePaymentSuccess);
    _razorpay.on(Razorpay.EVENT_PAYMENT_ERROR, _handlePaymentError);
    _razorpay.on(Razorpay.EVENT_EXTERNAL_WALLET, _handleExternalWallet);
  }

  @override
  void dispose() {
    _razorpay.clear();
    msgController.dispose();
    amountController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final text = msgController.text.trim();
    if (text.isEmpty) return;

    try {
      controller.isSending.value = true;

      // Send message to expert
      await controller.sendMessageToExpert(
        receiverId: widget.travellerId,
        message: text,
      );

      msgController.clear();

      // Check for any API error messages
      // if (chatWithController.lastErrorMessage.value.isNotEmpty) {
      //   _showMessageErrorDialog(chatWithController.lastErrorMessage.value);
      // }
    } catch (e) {
      _showMessageErrorDialog("Failed to send message: $e");
    } finally {
      controller.isSending.value = false;
    }
  }

  void _showMessageErrorDialog(String message) {
    Get.defaultDialog(
      title: "Message Failed",
      middleText: message,
      backgroundColor: Colors.grey.shade900,
      titleStyle: const TextStyle(color: Colors.white, fontSize: 20),
      middleTextStyle: const TextStyle(color: Colors.white70),
      textCancel: "Cancel",
      textConfirm: "Pay Now",
      confirmTextColor: Colors.white,
      cancelTextColor: Colors.white,
      onCancel: () {
        Get.back();
      },
      onConfirm: () {
        Get.back();
        _openRazorpayPayment(widget.price);
      },
    );
  }

  void _showPaymentModal() {
    // Prefill with expert price
    amountController.text = widget.price;

    Get.defaultDialog(
      title: "Pay Traveller",
      titleStyle: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: Colors.white,
      ),
      backgroundColor: const Color(0xFF1A1A1A),
      contentPadding: const EdgeInsets.all(16),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            widget.travellerName,
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade300),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: amountController,
            keyboardType: TextInputType.number,
            readOnly: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              prefixIcon: const Icon(Icons.currency_rupee, color: Colors.white),
              hintText: "Enter amount",
              hintStyle: TextStyle(color: Colors.grey.shade400),
              filled: true,
              fillColor: Colors.grey.shade800,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.symmetric(
                vertical: 16,
                horizontal: 16,
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              final amount = amountController.text.trim();
              if (amount.isEmpty) {
                Get.snackbar(
                  "Error",
                  "Please enter an amount",
                  backgroundColor: Colors.red.shade600,
                  colorText: Colors.white,
                );
                return;
              }
              Get.back(); // Close the dialog
              _openRazorpayPayment(amount);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green.shade600,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text(
              "Pay Now",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _openRazorpayPayment(String amount) {
    var options = {
      'key': 'rzp_test_RIcVT1kjDlJh9q',
      'amount': (double.parse(amount) * 100).toInt(),
      'name': widget.travellerName,
      'description': 'Chat Payment',
      'prefill': {'contact': '9942549844', 'email': 'user@example.com'},
      'theme': {'color': '#F37254'},
    };

    try {
      _razorpay.open(options);
    } catch (e) {
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
    final travellerId = widget.travellerId.toString();

    await chatWithController.verifyPayment(
      paymentId: paymentId,
      expertId: travellerId,
      amount: amountController.text.trim(),
    );
  }

  void _handlePaymentError(PaymentFailureResponse response) {
    Get.snackbar(
      'Payment Failed',
      'Code: ${response.code}\nMessage: ${response.message}',
      backgroundColor: Colors.red.shade600,
      colorText: Colors.white,
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

  void _endChat() {
    Get.defaultDialog(
      title: "End Chat?",
      middleText: "Are you sure you want to end this chat?",
      textCancel: "Cancel",
      textConfirm: "End",
      confirmTextColor: Colors.white,
      onConfirm: () {
        Get.back();
        controller.endChat();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage: widget.travellerImage.isNotEmpty
                  ? NetworkImage(widget.travellerImage)
                  : null,
              child: widget.travellerImage.isEmpty
                  ? Text(widget.travellerName[0])
                  : null,
            ),
            const SizedBox(width: 10),
            Text(widget.travellerName),
          ],
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.isLoading.value) {
                  return Center(
                    child: SizedBox(
                      height: 120,
                      width: 120,
                      child: Lottie.asset(
                        'assets/lottie/Loading.json',
                        repeat: true,
                        animate: true,
                      ),
                    ),
                  );
                }
                if (controller.messages.isEmpty) {
                             return Center(
                    child: SizedBox(
                      height: 120,
                      width: 120,
                      child: Lottie.asset(
                        'assets/lottie/Loading.json',
                        repeat: true,
                        animate: true,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  controller: controller.scrollController,
                  padding: const EdgeInsets.all(12),
                  itemCount: controller.messages.length,
                  itemBuilder: (context, index) {
                    final msg = controller.messages[index];
                    final isMe = msg["sender_id"] == controller.myUserId;
                    String time = "";
                    try {
                      if (msg["created_at"] != null) {
                        // Parse UTC timestamp and convert to local time
                        final dateTime = DateTime.parse(msg["created_at"]).toLocal();
                        time = DateFormat("hh:mm a").format(dateTime);
                      }
                    } catch (e) {
                      // Fallback to empty string if parsing fails
                      time = "";
                    }
                    return Align(
                      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
                      child: Container(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey[800],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: isMe
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Text(
                              msg["message"] ?? "",
                              style: const TextStyle(color: Colors.white),
                            ),
                            if (time.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                time,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  },
                );
              }),
            ),

            /// Message Input
            SafeArea(
              child: Container(
                padding: const EdgeInsets.all(12),
                color: Colors.grey.shade900,
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: msgController,
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
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 10,
                            horizontal: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    /// Button based on user type
                    if (userType == "expert")
                      InkWell(
                        onTap: _endChat,
                        borderRadius: BorderRadius.circular(30),
                        child: Container(
                          width: 42,
                          height: 42,
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 22,
                          ),
                        ),
                      )
                    else
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
      ),
    );
  }
}