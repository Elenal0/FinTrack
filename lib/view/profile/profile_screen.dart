import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spendify/config/app_color.dart';
import 'package:spendify/controller/home_controller/home_controller.dart';
import 'package:spendify/controller/nav_controller.dart';
import 'package:spendify/controller/theme_controller.dart';
import 'package:spendify/routes/app_pages.dart';
import 'package:spendify/view/profile/edit_profile_screen.dart';
import 'package:spendify/widgets/toast/custom_toast.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    HapticFeedback.mediumImpact();
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 85,
    );
    if (picked != null) {
      await Get.find<NavController>().setProfileImage(picked.path);
      CustomToast.successToast('Updated', 'Profile photo changed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = Get.find<HomeController>();
    final themeCtrl = ThemeController.to;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColor.darkBg : const Color(0xFFF6F5F3);
    final cardBg = isDark ? AppColor.darkSurface : Colors.white;
    final textPrimary =
        isDark ? AppColor.textPrimary : const Color(0xFF09090B);
    final textMuted =
        isDark ? AppColor.textSecondary : const Color(0xFF71717A);
    final divColor = isDark ? AppColor.darkBorder : const Color(0xFFF4F4F5);

    return Scaffold(
      backgroundColor: bg,
      body: FadeTransition(
        opacity: _fadeAnim,
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Hero header with profile picture ───────────────────────
            SliverToBoxAdapter(
              child: _buildProfileHeader(
                  ctrl, isDark, textPrimary, textMuted, cardBg),
            ),

            // ── Stats cards ─────────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
                child: Obx(() {
                  final fmt = NumberFormat('#,##0', 'en_IN');
                  final net =
                      ctrl.totalIncome.value - ctrl.totalExpense.value;
                  final isPos = net >= 0;
                  return Row(
                    children: [
                      _StatCard(
                        icon: PhosphorIconsLight.arrowsDownUp,
                        label: 'Transactions',
                        value: '${ctrl.transactions.length}',
                        color: AppColor.primary,
                        isDark: isDark,
                        cardBg: cardBg,
                      ),
                      const SizedBox(width: 12),
                      _StatCard(
                        icon: isPos
                            ? PhosphorIconsLight.trendUp
                            : PhosphorIconsLight.trendDown,
                        label: 'Net balance',
                        value:
                            '${isPos ? '+' : '-'}${ctrl.currencySymbol.value}${fmt.format(net.abs())}',
                        color: isPos ? AppColor.income : AppColor.expense,
                        isDark: isDark,
                        cardBg: cardBg,
                      ),
                    ],
                  );
                }),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 20)),

            // ── Settings section ──────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text('Settings',
                    style: TextStyle(
                        color: textMuted,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
              ),
            ),

            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: divColor, width: 1),
                  ),
                  child: Column(
                    children: [
                      _SettingTile(
                        icon: PhosphorIconsLight.sliders,
                        label: 'Edit Preferences',
                        subtitle: 'Currency, occupation, budget & categories',
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        divColor: divColor,
                        showDivider: true,
                        onTap: () =>
                            Get.to(() => const EditProfileScreen()),
                      ),
                      Obx(() => _SettingTile(
                            icon: themeCtrl.isDarkMode
                                ? PhosphorIconsLight.moon
                                : PhosphorIconsLight.sun,
                            label: 'Dark Mode',
                            subtitle: themeCtrl.isDarkMode
                                ? 'Currently dark'
                                : 'Currently light',
                            textPrimary: textPrimary,
                            textMuted: textMuted,
                            divColor: divColor,
                            showDivider: true,
                            trailing: Transform.scale(
                              scale: 0.8,
                              child: Switch(
                                value: themeCtrl.isDarkMode,
                                onChanged: (_) => themeCtrl.toggleTheme(),
                                activeThumbColor: Colors.white,
                                activeTrackColor: AppColor.primary,
                                inactiveThumbColor: Colors.white,
                                inactiveTrackColor: isDark
                                    ? AppColor.darkElevated
                                    : const Color(0xFFE4E4E7),
                                trackOutlineColor:
                                    WidgetStateProperty.all(Colors.transparent),
                              ),
                            ),
                          )),
                      _SettingTile(
                        icon: PhosphorIconsLight.headset,
                        label: 'Help & Support',
                        subtitle: 'Report a bug or ask for help',
                        textPrimary: textPrimary,
                        textMuted: textMuted,
                        divColor: divColor,
                        showDivider: false,
                        onTap: () => Get.toNamed(Routes.SUPPORT),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 16)),

            // ── Logout section ────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Container(
                  decoration: BoxDecoration(
                    color: cardBg,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: divColor, width: 1),
                  ),
                  child: _SettingTile(
                    icon: PhosphorIconsLight.signOut,
                    label: 'Sign Out',
                    subtitle: 'Log out of your account',
                    iconColor: AppColor.expense,
                    labelColor: AppColor.expense,
                    textPrimary: textPrimary,
                    textMuted: textMuted,
                    divColor: divColor,
                    showDivider: false,
                    onTap: () async {
                      await ctrl.signOut();
                      CustomToast.successToast('Success', 'Logged out');
                    },
                  ),
                ),
              ),
            ),

            SliverToBoxAdapter(
              child:
                  SizedBox(height: MediaQuery.of(context).padding.bottom + 100),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(HomeController ctrl, bool isDark,
      Color textPrimary, Color textMuted, Color cardBg) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [
                  AppColor.primary.withValues(alpha: 0.15),
                  AppColor.darkBg,
                ]
              : [
                  AppColor.primary.withValues(alpha: 0.08),
                  const Color(0xFFF6F5F3),
                ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            const SizedBox(height: 16),

            // Title
            Text('Profile',
                style: TextStyle(
                    color: textPrimary,
                    fontSize: 17,
                    fontWeight: FontWeight.w600)),

            const SizedBox(height: 24),

            // ── Profile picture ────────────────────────────────────
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  // Glow ring
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [AppColor.primary, AppColor.income],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColor.primary.withValues(alpha: 0.3),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(3),
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isDark ? AppColor.darkBg : Colors.white,
                      ),
                      padding: const EdgeInsets.all(3),
                      child: ClipOval(
                        child: Obx(() {
                          final imgPath = Get.find<NavController>().profileImagePath.value;
                          if (imgPath != null && File(imgPath).existsSync()) {
                            return Image.file(
                              File(imgPath),
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                            );
                          }
                          final name = ctrl.userName.value;
                          final initials = _initials(name);
                          return Container(
                            width: 100,
                            height: 100,
                            color: AppColor.primary.withValues(alpha: 0.12),
                            child: Center(
                              child: Text(
                                initials,
                                style: const TextStyle(
                                  color: AppColor.primary,
                                  fontSize: 36,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),

                  // Camera badge
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColor.primary,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isDark ? AppColor.darkBg : Colors.white,
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(Icons.camera_alt_rounded,
                          color: Colors.white, size: 15),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Name ──────────────────────────────────────────────
            Obx(() => Text(
                  ctrl.userName.value.isNotEmpty
                      ? ctrl.userName.value
                      : 'Your Name',
                  style: TextStyle(
                    color: textPrimary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5,
                  ),
                )),

            const SizedBox(height: 4),

            // ── Email ─────────────────────────────────────────────
            Obx(() => Text(
                  ctrl.userEmail.value,
                  style: TextStyle(
                    color: textMuted,
                    fontSize: 14,
                  ),
                )),

            const SizedBox(height: 8),

            // ── Occupation badge ──────────────────────────────────
            Obx(() {
              if (ctrl.occupation.value.isEmpty) {
                return const SizedBox.shrink();
              }
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: AppColor.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(100),
                  border: Border.all(
                    color: AppColor.primary.withValues(alpha: 0.25),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    PhosphorIcon(PhosphorIconsLight.briefcase,
                        color: AppColor.primary, size: 13),
                    const SizedBox(width: 5),
                    Text(ctrl.occupation.value,
                        style: const TextStyle(
                            color: AppColor.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500)),
                  ],
                ),
              );
            }),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return '?';
    final p = name.trim().split(' ');
    return '${p.first.isNotEmpty ? p.first[0] : ''}${p.length > 1 && p.last.isNotEmpty ? p.last[0] : ''}'
        .toUpperCase();
  }
}

// ── Stat Card ──────────────────────────────────────────────────────────────────

class _StatCard extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final String value;
  final Color color;
  final bool isDark;
  final Color cardBg;

  const _StatCard({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.isDark,
    required this.cardBg,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor =
        isDark ? AppColor.darkBorder : const Color(0xFFF4F4F5);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: PhosphorIcon(icon, color: color, size: 16),
              ),
            ),
            const SizedBox(height: 10),
            Text(label,
                style: TextStyle(
                    color: color.withValues(alpha: 0.7), fontSize: 11)),
            const SizedBox(height: 3),
            Text(value,
                style: TextStyle(
                    color: color,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5)),
          ],
        ),
      ),
    );
  }
}

// ── Setting Tile ───────────────────────────────────────────────────────────────

class _SettingTile extends StatelessWidget {
  final PhosphorIconData icon;
  final String label;
  final String? subtitle;
  final Color textPrimary;
  final Color textMuted;
  final Color divColor;
  final Color? iconColor;
  final Color? labelColor;
  final Widget? trailing;
  final bool showDivider;
  final VoidCallback? onTap;

  const _SettingTile({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.textPrimary,
    required this.textMuted,
    required this.divColor,
    this.iconColor,
    this.labelColor,
    this.trailing,
    this.showDivider = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: onTap,
          borderRadius: showDivider
              ? null
              : BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: (iconColor ?? textMuted).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Center(
                    child: PhosphorIcon(icon,
                        color: iconColor ?? textMuted, size: 18),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label,
                          style: TextStyle(
                              color: labelColor ?? textPrimary,
                              fontSize: 14,
                              fontWeight: FontWeight.w500)),
                      if (subtitle != null && subtitle!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Text(subtitle!,
                              style:
                                  TextStyle(color: textMuted, fontSize: 12)),
                        ),
                    ],
                  ),
                ),
                trailing ??
                    PhosphorIcon(PhosphorIconsLight.caretRight,
                        size: 16, color: textMuted),
              ],
            ),
          ),
        ),
        if (showDivider)
          Padding(
            padding: const EdgeInsets.only(left: 64),
            child: Divider(height: 1, color: divColor),
          ),
      ],
    );
  }
}
