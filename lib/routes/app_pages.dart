
import 'package:get/get.dart';
import 'package:spendify/view/auth/login_screen.dart';
import 'package:spendify/view/home/home_screen.dart';
import 'package:spendify/view/landing/get_started_screen.dart';
import 'package:spendify/view/landing/splash_screen.dart';
import 'package:spendify/view/onboarding/onboarding_screen.dart';
import 'package:spendify/view/profile/profile_screen.dart';
import 'package:spendify/view/profile/support_screen.dart';
import 'package:spendify/view/admin/admin_dashboard.dart';
import 'package:spendify/view/admin/admin_login_screen.dart';
import 'package:spendify/widgets/bottom_navigation.dart';
import 'package:spendify/controller/nav_controller.dart';
import 'package:spendify/controller/home_controller/home_controller.dart';
import 'package:spendify/controller/walkthrough_controller.dart';
import 'package:spendify/controller/goals_controller/goals_controller.dart';
import 'package:spendify/controller/savings_controller/savings_controller.dart';
import 'package:spendify/controller/groups_controller/groups_controller.dart';
part 'app_routes.dart';

class AppPages {
  AppPages._();

  static const INITIAL = Routes.SPLASH;

  static final routes = [
    GetPage(
      name: _Paths.HOME,
      page: () => const HomeScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.LOGIN,
      page: () => const LoginScreen(),
    ),
    GetPage(
      name: _Paths.SPLASH,
      page: () => const SplashScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.GETSTARTED,
      page: () => const GetStartedScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.PROFILE,
      page: () => const ProfileScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.ONBOARDING,
      page: () => const OnboardingScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.SUPPORT,
      page: () => const SupportScreen(),
      transition: Transition.fadeIn,
    ),
    GetPage(
      name: _Paths.ADMIN_DASHBOARD,
      page: () => const AdminDashboard(),
      transition: Transition.rightToLeftWithFade,
    ),
    GetPage(
      name: _Paths.ADMIN_LOGIN,
      page: () => const AdminLoginScreen(),
      transition: Transition.cupertino,
    ),
    GetPage(
      name: _Paths.BOTTOM_NAV,
      page: () => const BottomNav(),
      binding: HomeBinding(),
      transition: Transition.fadeIn,
    ),
  ];
}

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NavController>()) Get.put(NavController(), permanent: true);
    if (!Get.isRegistered<HomeController>()) Get.put(HomeController(), permanent: true);
    if (!Get.isRegistered<WalkthroughController>()) Get.put(WalkthroughController(), permanent: true);
    if (!Get.isRegistered<GoalsController>()) Get.put(GoalsController(), permanent: true);
    if (!Get.isRegistered<SavingsController>()) Get.put(SavingsController(), permanent: true);
    if (!Get.isRegistered<GroupsController>()) Get.put(GroupsController(), permanent: true);
  }
}
