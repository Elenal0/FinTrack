import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:phosphor_flutter/phosphor_flutter.dart';
import 'package:intl/intl.dart';
import 'package:spendify/config/app_color.dart';
import 'package:spendify/main.dart';
import 'package:spendify/widgets/toast/custom_toast.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  final RxBool _isLoading = true.obs;
  final RxList<Map<String, dynamic>> _users = <Map<String, dynamic>>[].obs;
  final RxDouble _totalAppVolume = 0.0.obs;
  final RxInt _totalTransactions = 0.obs;

  @override
  void initState() {
    super.initState();
    _loadAdminData();
  }

  Future<void> _loadAdminData() async {
    _isLoading.value = true;
    try {
      // 1. Fetch all users
      final usersData = await supabaseC.from('users').select().order('name');
      _users.value = List<Map<String, dynamic>>.from(usersData);

      // 2. Fetch app-wide stats
      final txData = await supabaseC.from('transactions').select('amount');
      double total = 0;
      for (var row in txData) {
        total += (row['amount'] as num).toDouble();
      }
      _totalAppVolume.value = total;
      _totalTransactions.value = txData.length;

    } catch (e) {
      debugPrint('Admin load error: $e');
      CustomToast.errorToast('Error', 'Failed to load admin data');
    } finally {
      _isLoading.value = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColor.darkBg : const Color(0xFFF6F5F3);
    final cardBg = isDark ? AppColor.darkSurface : Colors.white;
    final textPrimary = isDark ? AppColor.textPrimary : const Color(0xFF09090B);
    final textMuted = isDark ? AppColor.textSecondary : const Color(0xFF71717A);
    final divColor = isDark ? AppColor.darkBorder : const Color(0xFFF4F4F5);

    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text('Admin Control',
            style: TextStyle(
                color: textPrimary, fontSize: 17, fontWeight: FontWeight.w600)),
        leading: IconButton(
          icon: PhosphorIcon(PhosphorIconsLight.arrowLeft,
              color: textPrimary, size: 22),
          onPressed: Get.back,
        ),
        actions: [
          IconButton(
            icon: PhosphorIcon(PhosphorIconsLight.arrowClockwise,
                color: textPrimary, size: 20),
            onPressed: _loadAdminData,
          ),
        ],
      ),
      body: Obx(() {
        if (_isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: AppColor.primary));
        }

        final fmt = NumberFormat('#,##0', 'en_IN');

        return CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // ── Stats Row ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Global Overview',
                        style: TextStyle(
                            color: textMuted,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5)),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _StatItem(
                          label: 'Total Users',
                          value: '${_users.length}',
                          icon: PhosphorIconsLight.users,
                          color: AppColor.primary,
                          cardBg: cardBg,
                          isDark: isDark,
                        ),
                        const SizedBox(width: 12),
                        _StatItem(
                          label: 'App Volume',
                          value: '₹${fmt.format(_totalAppVolume.value)}',
                          icon: PhosphorIconsLight.chartLineUp,
                          color: AppColor.income,
                          cardBg: cardBg,
                          isDark: isDark,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            // ── User List ──────────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 10),
                child: Text('Registered Users',
                    style: TextStyle(
                        color: textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5)),
              ),
            ),

            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final user = _users[index];
                  final name = user['name'] ?? 'Unknown';
                  final email = user['email'] ?? 'No email';
                  final balance = (user['balance'] ?? 0.0).toDouble();
                  final avatarUrl = user['url'] as String?;
                  final initials = name.isNotEmpty ? name[0].toUpperCase() : '?';

                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: cardBg,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: divColor),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 18,
                            backgroundColor: AppColor.primary.withValues(alpha: 0.1),
                            backgroundImage: (avatarUrl != null && avatarUrl.isNotEmpty)
                                ? NetworkImage(avatarUrl)
                                : null,
                            child: (avatarUrl == null || avatarUrl.isEmpty)
                                ? Text(initials,
                                    style: const TextStyle(
                                        color: AppColor.primary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600))
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(name,
                                    style: TextStyle(
                                        color: textPrimary,
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600)),
                                Text(email,
                                    style: TextStyle(
                                        color: textMuted, fontSize: 11)),
                              ],
                            ),
                          ),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              const Text('••••',
                                  style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      letterSpacing: 2)),
                              const Text('Balance',
                                  style: TextStyle(
                                      color: Colors.grey, fontSize: 9)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: _users.length,
              ),
            ),

            const SliverToBoxAdapter(child: SizedBox(height: 100)),
          ],
        );
      }),
    );
  }
}

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final PhosphorIconData icon;
  final Color color;
  final Color cardBg;
  final bool isDark;

  const _StatItem({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.cardBg,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: isDark ? AppColor.darkBorder : const Color(0xFFF4F4F5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: PhosphorIcon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 12),
            Text(value,
                style: TextStyle(
                    color: isDark ? Colors.white : Colors.black,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.5)),
            Text(label,
                style: const TextStyle(
                    color: Colors.grey, fontSize: 11, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
