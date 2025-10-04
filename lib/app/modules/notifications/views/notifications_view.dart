import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/notifications/controllers/notifications_controller.dart';

class NotificationView extends StatelessWidget {
  NotificationView({super.key});
  final NotificationController controller = Get.put(NotificationController());

  String _formatTime(String time) {
    try {
      final dateTime = DateTime.parse(time);
      return DateFormat('hh:mm a, dd MMM').format(dateTime);
    } catch (_) {
      return time;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: AppColors.appbar,
        elevation: 0,
        foregroundColor: Colors.white,
        title: Text(
          'Notifications',
          style: GoogleFonts.openSans(
            color: AppColors.titleText,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  'assets/images/search_image.png',
                  width: 180,
                  color: Colors.white24,
                ),
                const SizedBox(height: 12),
                Text(
                  "No notifications",
                  style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: controller.notifications.length,
          separatorBuilder: (_, __) => const Divider(
            color: Colors.white12,
            thickness: 0.3,
            indent: 72,
          ),
          itemBuilder: (context, index) {
            final notification = controller.notifications[index];

            return Dismissible(
              key: Key(notification.time + index.toString()),
              direction: DismissDirection.endToStart,
              background: Container(
                color: Colors.redAccent,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: const Icon(Icons.delete, color: Colors.white),
              ),
              onDismissed: (_) {
                controller.notifications.removeAt(index);
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white10,
                      child: Text(
                        notification.title.isNotEmpty
                            ? notification.title[0].toUpperCase()
                            : 'N',
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              text: notification.title,
                              style: GoogleFonts.montserrat(
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                                fontSize: 15,
                              ),
                              children: [
                                TextSpan(
                                  text: ' ${notification.message}',
                                  style: GoogleFonts.montserrat(
                                    color: Colors.grey.shade400,
                                    fontWeight: FontWeight.normal,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatTime(notification.time),
                            style: GoogleFonts.montserrat(
                              color: Colors.grey.shade500,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Icon(Icons.more_vert, color: Colors.white24, size: 18),
                  ],
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
