import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/modules/dm/views/dm_view.dart';
import 'package:travel_app2/app/modules/experts_profile/controllers/experts_profile_controller.dart';
import 'package:travel_app2/app/modules/experts_profile/views/experts_profile_view.dart';
import '../controllers/expert_controller.dart';

// ignore: must_be_immutable
class ExpertView extends GetView<ExpertController> {
  ExpertController controller = Get.put(ExpertController());
  final ExpertsProfileController profileController = Get.put(ExpertsProfileController());


  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        title: const Text('Experts'),
        backgroundColor: AppColors.appbar,
        foregroundColor: Colors.white,
        elevation: 1,
        centerTitle: true,
        actions: [
               Padding(
                 padding: const EdgeInsets.only(right:20.0),
                 child: InkWell(
                  onTap: () {
  Get.to(DmView());
                  },
                  child: Image.asset(
                    'assets/icons/telegram.png',
                    height: 32,
                    width: 32,
                    fit: BoxFit.contain,
                    color: AppColors.buttonBg,
                  ),
                               ),
               ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            // 🔍 Search Bar
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: TextField(
                controller: controller.searchController,
                onChanged: controller.searchExperts,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: "Search experts...",
                  hintStyle: const TextStyle(color: Colors.white70),
                  prefixIcon: const Icon(Icons  .search, color: Colors.white70),
                  filled: true,
                  fillColor: AppColors.cardBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),

            // 🟢 Experts Grid OR Empty Text
            Expanded(
              child: controller.experts.isEmpty
                  ? const Center(
                      child: Text(
                        "No Experts Found",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : GridView.builder(
                      padding: EdgeInsets.all(screenWidth * 0.04),
                      itemCount: controller.experts.length,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: screenWidth < 600 ? 2 : 3,
                        mainAxisSpacing: screenWidth * 0.04,
                        crossAxisSpacing: screenWidth * 0.04,
                        childAspectRatio: screenWidth < 600 ? 0.65 : 0.75,
                      ),
                      itemBuilder: (context, index) {
                        final expert = controller.experts[index];
                        return ExpertCard(
                          expert: expert,
                          screenWidth: screenWidth,
                        );
                      },
                    ),
            ),
          ],
        );
      }),
    );
  }
}

class ExpertCard extends StatelessWidget {
  final Map<String, dynamic> expert;
  final double screenWidth;

  const ExpertCard({
    super.key,
    required this.expert,
    required this.screenWidth,
  });

  @override
  Widget build(BuildContext context) {
    final imageUrl = (expert['image'] != null && expert['image'].toString().isNotEmpty)
        ? expert['image']
        : "https://via.placeholder.com/150"; // 🔄 fallback

    return GestureDetector(
      onTap: () {
           print("🟢 Selected Expert ID: ${expert['user_id']}");
        Get.to(() => ExpertsProfileView(
              expertId: expert['id'],
              expertuserId: expert['user_id'],
            ));
      },
      child: Card(
        color: AppColors.cardBg,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: AppColors.buttonBg, width: 0.1),
        ),
        child: Padding(
          padding: EdgeInsets.all(screenWidth * 0.03),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(screenWidth * 0.08),
                child: Image.network(
                  imageUrl,
                  height: screenWidth * 0.18,
                  width: screenWidth * 0.18,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: screenWidth * 0.03),
               Text(
                expert['expert_name'] ?? "",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              SizedBox(height: screenWidth * 0.03),
              Text(
                expert['title'] ?? "",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.035,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
              // Text(
              //   expert['sub_title'] ?? "",
              //   textAlign: TextAlign.center,
              //   overflow: TextOverflow.ellipsis,
              //   style: GoogleFonts.poppins(
              //     fontSize: screenWidth * 0.03,
              //     color: Colors.white70,
              //   ),
              // ),
              Text(
                expert['location'] ?? "",
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.028,
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: screenWidth * 0.01),
              Text(
                (expert['language'] as List? ?? [])
                    .map((lang) => lang['value'].toString())
                    .join(', '),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.028,
                  color: Colors.white54,
                ),
              ),
              SizedBox(height: screenWidth * 0.015),
              Text(
                "₹${expert['price']}/day",
                style: GoogleFonts.poppins(
                  fontSize: screenWidth * 0.032,
                  fontWeight: FontWeight.bold,
                  color: Colors.tealAccent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}