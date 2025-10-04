import 'package:get/get.dart';

import '../modules/chat/bindings/chat_binding.dart';
import '../modules/chat/views/chat_view.dart';
import '../modules/chat_both/bindings/chat_both_binding.dart';
import '../modules/chat_both/views/chat_both_view.dart';
import '../modules/chat_with_expert/bindings/chat_with_expert_binding.dart';
import '../modules/chat_with_expert/views/expertt_chat_view.dart';
import '../modules/community_search/bindings/community_search_binding.dart';
import '../modules/community_search/views/community_search_view.dart';
import '../modules/dashboard/bindings/dashboard_binding.dart';
import '../modules/dashboard/views/dashboard_view.dart';
import '../modules/dm/bindings/dm_binding.dart';
import '../modules/dm/views/dm_view.dart';
import '../modules/edit_profile/bindings/edit_profile_binding.dart';
import '../modules/edit_profile/views/edit_profile_view.dart';
import '../modules/expert/bindings/expert_binding.dart';
import '../modules/expert/views/expert_view.dart';
import '../modules/expert_user_profile/bindings/expert_user_profile_binding.dart';
import '../modules/expert_user_profile/views/expert_user_profile_view.dart';
import '../modules/experts_profile/bindings/experts_profile_binding.dart';
import '../modules/experts_profile/views/experts_profile_view.dart';
import '../modules/forgot_password/bindings/forgot_password_binding.dart';
import '../modules/forgot_password/views/forgot_password_view.dart';
import '../modules/home/bindings/home_binding.dart';
import '../modules/home/views/home_view.dart';
import '../modules/login/bindings/login_binding.dart';
import '../modules/login/views/login_view.dart';
import '../modules/my_profile/bindings/my_profile_binding.dart';
import '../modules/my_profile/views/my_profile_view.dart';
import '../modules/notifications/bindings/notifications_binding.dart';
import '../modules/notifications/views/notifications_view.dart';
import '../modules/onboarding/bindings/onboarding_binding.dart';
import '../modules/onboarding/views/onboarding_view.dart';
import '../modules/otp/bindings/otp_binding.dart';
import '../modules/otp/views/otp_view.dart';
import '../modules/otp_verification/bindings/otp_verification_binding.dart';
import '../modules/otp_verification/views/otp_verification_view.dart';
import '../modules/phone_login/bindings/phone_login_binding.dart';
import '../modules/phone_login/views/phone_login_view.dart';
import '../modules/post_quesions/bindings/post_quesions_binding.dart';
import '../modules/post_quesions/views/bottom_sheet_questions.dart';
import '../modules/register/bindings/register_binding.dart';
import '../modules/register/views/register_view.dart';
import '../modules/reset_password/bindings/reset_password_binding.dart';
import '../modules/reset_password/views/reset_password_view.dart';
import '../modules/splash/bindings/splash_binding.dart';
import '../modules/splash/views/splash_view.dart';
import '../modules/talk_to_travellers_chat/bindings/talk_to_travellers_chat_binding.dart';
import '../modules/talk_to_travellers_chat/views/talk_to_travellers_chat_view.dart';
import '../modules/travellers/bindings/travellers_binding.dart';
import '../modules/travellers/views/travellers_view.dart';
import '../modules/user_profile/bindings/user_profile_binding.dart';
import '../modules/user_profile/views/user_profile_view.dart';

part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.LOGIN,
      page: () => LoginView(),
      binding: LoginBinding(),
    ),
    GetPage(
      name: _Paths.REGISTER,
      page: () => RegisterView(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashView(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: _Paths.HOME,
      page: () => HomeView(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingView(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: _Paths.OTP,
      page: () => OtpView(),
      binding: OtpBinding(),
    ),
    // GetPage(
    //   name: _Paths.BOTTOMNAVIGATIONBAR,
    //   page: () => const BottomnavigationbarView(),
    //   binding: BottomnavigationbarBinding(),
    // ),
    GetPage(
      name: _Paths.DASHBOARD,
      page: () => DashboardView(),
      binding: DashboardBinding(),
    ),

    GetPage(
      name: _Paths.COMMUNITY_SEARCH,
      page: () => CommunitySearchView(),
      binding: CommunitySearchBinding(),
    ),
    GetPage(
      name: _Paths.NOTIFICATIONS,
      page: () => NotificationView(),
      binding: NotificationsBinding(),
    ),
    GetPage(
      name: _Paths.MY_PROFILE,
      page: () => MyProfileView(),
      binding: MyProfileBinding(),
    ),
    GetPage(
      name: _Paths.USER_PROFILE,
      page: () => UserProfileView(),
      binding: UserProfileBinding(),
    ),

    GetPage(
      name: _Paths.POST_QUESIONS,
      page: () => BottomSheetQuestionsView(),
      binding: PostQuesionsBinding(),
    ),
    GetPage(
      name: _Paths.FORGOT_PASSWORD,
      page: () => ForgotPasswordView(),
      binding: ForgotPasswordBinding(),
    ),
    GetPage(
      name: _Paths.RESET_PASSWORD,
      page: () => ResetPasswordView(),
      binding: ResetPasswordBinding(),
    ),

    GetPage(
      name: _Paths.EDIT_PROFILE,
      page: () => EditProfileView(),
      binding: EditProfileBinding(),
    ),
    GetPage(
      name: _Paths.EXPERT,
      page: () => ExpertView(),
      binding: ExpertBinding(),
    ),
    GetPage(
      name: _Paths.EXPERTS_PROFILE,
      page: () {
        final args = Get.arguments as Map<String, dynamic>;
        return ExpertsProfileView(
          expertId: args['expertId'],
          expertuserId: args['expertuserId'],
        );
      },
      binding: ExpertsProfileBinding(),
    ),
    GetPage(
      name: _Paths.PHONE_LOGIN,
      page: () => PhoneLoginView(),
      binding: PhoneLoginBinding(),
    ),
    GetPage(
      name: _Paths.OTP_VERIFICATION,
      page: () => OtpVerificationView(
        phoneNumber: Get.parameters['phone'] ?? '', // Pass phone via parameters
      ),
      binding: OtpVerificationBinding(),
    ),
    GetPage(
      name: _Paths.DM,
      page: () => DmView(),
      binding: DmBinding(),
    ),
    GetPage(
      name: _Paths.CHAT,
      page: () => ChatView(
        currentUser: Get.parameters['currentUser'] ?? '',
        otherUser: Get.parameters['otherUser'] ?? '',
        chatId: Get.parameters['chatId'] ?? '',
        otherUserImage:
            Get.parameters['otherUserImage'] ?? '', // ✅ profile image added
        otherUserId: Get.parameters['otherUserId'] ?? '', // ✅ otherUserId added
      ),
      binding: ChatBinding(),
    ),
    GetPage(
      name: _Paths.CHAT_WITH_EXPERT,
      page: () {
        // Read arguments safely
        final args = Get.arguments as Map<String, dynamic>? ?? {};

        return ChatWithExpertView(
          expertId: args['expertId'] ?? 0,
          expertName: args['expertName'] ?? "Expert",
          expertImage: args['expertImage'] ?? "",
          expertPrice: args['amount'].toString(), // ✅ Added amount argument
        );
      },
      binding: ChatWithExpertBinding(),
    ),

    GetPage(
      name: _Paths.TRAVELLERS,
      page: () {
        final args = Get.arguments as Map<String, dynamic>? ?? {};
        return TravellersView(
          expertuserId: args['expertId'] ?? 0,
        );
      },
      binding: TravellersBinding(),
    ),
    GetPage(
      name: _Paths.TALK_TO_TRAVELLERS_CHAT,
      page: () {
        final args = Get.arguments ?? {};
        return TalkToTravellersChatView(
          travellerId: args['travellerId'] ?? 0,
          travellerName: args['travellerName'] ?? "Traveller",
          travellerImage: args['travellerImage'] ?? "",
          price: args['price'] ?? "0", // ✅ pass price here
        );
      },
      binding: TalkToTravellersChatBinding(),
    ),




    GetPage(
      name: _Paths.CHAT_BOTH,
      page: () => ChatBothView(
        currentUser: Get.arguments['currentUser'],
        otherUser: Get.arguments['otherUser'],
        otherUserImage: Get.arguments['otherUserImage'],
        otherUserId: Get.arguments['otherUserId'],
        chatId: Get.arguments['chatId'],
        isExpert: Get.arguments['isExpert'] ?? false,
      ),
      binding: ChatBothBinding(),
    ),
    GetPage(
      name: _Paths.EXPERT_USER_PROFILE,
      page: () =>  ExpertUserProfileView(),
      binding: ExpertUserProfileBinding(),
    ),
  ];
}
