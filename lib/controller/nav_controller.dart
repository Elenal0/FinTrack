import 'dart:io';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Lightweight controller to share the bottom-nav tab index
/// and the profile image path across widgets.
class NavController extends GetxController {
  final currentIndex = 0.obs;
  final profileImagePath = Rxn<String>();

  @override
  void onInit() {
    super.onInit();
    _loadProfileImage();
  }

  void goToTab(int index) => currentIndex.value = index;

  Future<void> _loadProfileImage() async {
    final prefs = await SharedPreferences.getInstance();
    final path = prefs.getString('profile_image_path');
    if (path != null && File(path).existsSync()) {
      profileImagePath.value = path;
    }
  }

  Future<void> setProfileImage(String path) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_image_path', path);
    profileImagePath.value = path;
  }
}
