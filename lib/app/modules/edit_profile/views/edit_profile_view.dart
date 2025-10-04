import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart'; // ✅ Lottie import
import 'package:travel_app2/app/constants/app_color.dart';
import 'package:travel_app2/app/constants/custom_button.dart';
import 'package:travel_app2/app/modules/edit_profile/controllers/edit_profile_controller.dart';

class EditProfileView extends StatelessWidget {
  EditProfileView({super.key});
  String baseUrl = "https://kotiboxglobaltech.com/travel_app/storage/";

  final EditProfileController controller = Get.put(EditProfileController());
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    controller.fetchProfile(); // Fetch data on view load

    return Scaffold(
      backgroundColor: AppColors.mainBg,
      appBar: AppBar(
        elevation: 5,
        backgroundColor: AppColors.mainBg,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          'Edit Profile',
          style: GoogleFonts.openSans(color: Colors.white, fontSize: 18),
        ),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.centerleft, AppColors.centerright],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          // ✅ Lottie loader instead of CircularProgressIndicator
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

        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _buildProfileImage(),
                  const SizedBox(height: 20),

                  // Personal Info
                  _buildCard(
                    title: "Personal Information",
                    children: [
                      _buildTextField("First Name", controller.firstNameController),
                      const SizedBox(height: 12),
                      _buildTextField("Last Name", controller.lastNameController),
                      const SizedBox(height: 12),
                      _buildTextField("Bio", controller.bioController, maxLines: 3),
                      const SizedBox(height: 12),
                      _buildTextField("Email", controller.emailController,
                          keyboardType: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _buildTextField("Phone", controller.phoneController,
                          keyboardType: TextInputType.phone),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Travel Info
                  _buildCard(
                    title: "Travel Details",
                    children: [
                      _buildTextField("Location", controller.locationController),
                      const SizedBox(height: 12),
                      _buildTextField("Travel Interest", controller.travelInterestController,
                          maxLines: 2),
                      const SizedBox(height: 12),
                      _buildTextField("Visited Places", controller.visitedPlacesController,
                          maxLines: 2),
                      const SizedBox(height: 12),
                      _buildTextField("Dream Destination", controller.dreamDestinationController),
                      const SizedBox(height: 12),
                      _buildTextField("Language", controller.languageController),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Travel Type (multi-select)
                  _buildCard(
                    title: "Travel Type",
                    children: [
                      Obx(() => Wrap(
                            spacing: 10,
                            children: ["Solo", "Group", "Family"].map((type) {
                              final isSelected = controller.selectedTravelTypes.contains(type);
                              return FilterChip(
                                label: Text(type),
                                selected: isSelected,
                                onSelected: (selected) {
                                  if (selected) {
                                    controller.selectedTravelTypes.add(type);
                                  } else {
                                    controller.selectedTravelTypes.remove(type);
                                  }
                                },
                                selectedColor: AppColors.buttonBg,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                labelStyle: TextStyle(
                                  color: isSelected ? Colors.white : Colors.grey[300],
                                  fontWeight: FontWeight.w600,
                                ),
                              );
                            }).toList(),
                          )),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ✅ Save Button with loading only inside button
                  CustomButton(
                    isLoading: controller.isUpdating, // Button ke andar loader
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        controller.updateProfile();
                      }
                    },
                    text: 'Save Changes',
                    backgroundColor: AppColors.buttonBg,
                    textColor: Colors.white,
                  ),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // Profile Image Widget
  Widget _buildProfileImage() {
    return Center(
      child: Stack(
        children: [
          Obx(() {
            final imageFile = controller.selectedImage.value;
            final apiImage = controller.profileImageUrl.value;

            Widget imageWidget;
            if (imageFile != null) {
              imageWidget = CircleAvatar(
                radius: 55,
                backgroundImage: FileImage(imageFile),
              );
            } else if (apiImage.isNotEmpty) {
              imageWidget = CircleAvatar(
                radius: 55,
                backgroundImage: NetworkImage(apiImage),
              );
            } else {
              imageWidget = CircleAvatar(
                radius: 55,
                backgroundColor: Colors.white24,
                child: const Icon(
                  Icons.person,
                  size: 50,
                  color: Colors.white70,
                ),
              );
            }
            return imageWidget;
          }),
          Positioned(
            bottom: 0,
            right: 4,
            child: GestureDetector(
              onTap: controller.pickImage,
              child: Container(
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 4)],
                ),
                padding: const EdgeInsets.all(6),
                child: const Icon(Icons.edit, size: 20, color: Colors.black87),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title,
              style: GoogleFonts.poppins(
                  color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1, TextInputType keyboardType = TextInputType.text}) {
    return TextFormField(
      controller: controller,
      style: GoogleFonts.poppins(color: Colors.white),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$label can’t be empty';
        }
        return null;
      },
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(color: Colors.grey.shade400, fontSize: 14),
        filled: true,
        fillColor: Colors.white.withOpacity(0.07),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white24),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.white),
        ),
      ),
    );
  }
}
