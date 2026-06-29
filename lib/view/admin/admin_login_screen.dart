import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:spendify/config/app_color.dart';
import 'package:spendify/main.dart';
import 'package:spendify/routes/app_pages.dart';
import 'package:spendify/widgets/toast/custom_toast.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final RxBool _isLoading = false.obs;
  final RxBool _isPasswordVisible = false.obs;

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      CustomToast.errorToast('Error', 'Please fill all fields');
      return;
    }

    _isLoading.value = true;
    try {
      // Sign in with Supabase
      final response = await supabaseC.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        // Success
        CustomToast.successToast('Welcome', 'Admin authenticated');
        Get.offAllNamed(Routes.BOTTOM_NAV);
      }
    } catch (e) {
      debugPrint('Admin login error: $e');
      CustomToast.errorToast('Login Failed', 'Invalid admin credentials');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColor.darkBg : Colors.white;
    final textPrimary = isDark ? AppColor.textPrimary : const Color(0xFF09090B);
    final textMuted = isDark ? AppColor.textSecondary : const Color(0xFF71717A);
    final cardBg = isDark ? AppColor.darkCard : const Color(0xFFF4F4F5);
    final border = isDark ? AppColor.darkBorder : const Color(0xFFE4E4E7);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIconsLight.arrowLeft, color: textPrimary),
          onPressed: Get.back,
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColor.primary.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const PhosphorIcon(
                PhosphorIconsLight.shieldCheck,
                color: AppColor.primary,
                size: 32,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Admin Portal',
              style: TextStyle(
                color: textPrimary,
                fontSize: 28,
                fontWeight: FontWeight.w800,
                letterSpacing: -1,
              ),
            ),
            Text(
              'Secure access for system administrators only.',
              style: TextStyle(color: textMuted, fontSize: 15),
            ),
            const SizedBox(height: 40),

            // Email Field
            Text('Email Address',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                style: TextStyle(color: textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: 'admin@spense.com',
                  hintStyle: TextStyle(color: textMuted, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Password Field
            Text('Security Password',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border),
              ),
              child: Obx(() => TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible.value,
                style: TextStyle(color: textPrimary, fontSize: 15),
                decoration: InputDecoration(
                  hintText: '••••••••',
                  hintStyle: TextStyle(color: textMuted, fontSize: 15),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  suffixIcon: IconButton(
                    icon: PhosphorIcon(
                      _isPasswordVisible.value
                          ? PhosphorIconsLight.eye
                          : PhosphorIconsLight.eyeSlash,
                      color: textMuted,
                      size: 20,
                    ),
                    onPressed: () => _isPasswordVisible.toggle(),
                  ),
                ),
              )),
            ),
            const SizedBox(height: 40),

            // Login Button
            Obx(() => GestureDetector(
              onTap: _isLoading.value ? null : _handleLogin,
              child: Container(
                width: double.infinity,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColor.primary,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: AppColor.primary.withValues(alpha: 0.25),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Center(
                  child: _isLoading.value
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                        )
                      : const Text(
                          'Authenticate',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              ),
            )),

            const SizedBox(height: 24),
            Center(
              child: Text(
                'Unauthorized access is strictly prohibited.',
                style: TextStyle(color: textMuted, fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
