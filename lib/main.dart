import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:spendify/config/app_theme.dart';
import 'package:spendify/controller/theme_controller.dart';
import 'package:spendify/routes/app_pages.dart';
import 'package:spendify/services/connectivity_service.dart';
import 'package:spendify/services/notification_service.dart';
import 'package:spendify/services/widget_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart' as dotenv;
import 'package:spendify/controller/nav_controller.dart';
import 'package:spendify/controller/home_controller/home_controller.dart';
import 'package:spendify/controller/walkthrough_controller.dart';
import 'package:spendify/controller/goals_controller/goals_controller.dart';
import 'package:spendify/controller/savings_controller/savings_controller.dart';
import 'package:spendify/controller/groups_controller/groups_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  GoogleFonts.config.allowRuntimeFetching = true;

  await dotenv.dotenv.load(fileName: 'assets/.env');
  await NotificationService.initialize();
  await WidgetService.init();
  Get.put(ConnectivityService(), permanent: true);
  final supaUri = dotenv.dotenv.env['SUPABASE_URL'];
  final supaAnon = dotenv.dotenv.env['SUPABASE_ANONKEY'];
  await Supabase.initialize(
    url: supaUri!,
    anonKey: supaAnon!,
  );

  runApp(const MyApp());
}

final supabaseC = Supabase.instance.client;
final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(NavController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(WalkthroughController(), permanent: true);
    Get.put(GoalsController(), permanent: true);
    Get.put(SavingsController(), permanent: true);
    Get.put(GroupsController(), permanent: true);
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialise the theme controller so it persists for the app lifetime.
    final themeController = Get.put(ThemeController());

    return Obx(
      () => GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Spense',
        theme: AppTheme.lightTheme(),
        darkTheme: AppTheme.darkTheme(),
        themeMode: themeController.themeMode,
        scaffoldMessengerKey: scaffoldMessengerKey,
        initialBinding: InitialBinding(),
        initialRoute: Routes.SPLASH,
        getPages: AppPages.routes,
        defaultTransition: Transition.fadeIn,
        transitionDuration: const Duration(milliseconds: 250),
      ),
    );
  }
}
