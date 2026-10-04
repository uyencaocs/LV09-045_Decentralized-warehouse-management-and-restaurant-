import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/audit_logs_dialog.dart';
import '../widgets/custom_badge.dart';
import '../widgets/fefo_export_dialog.dart';
import '../widgets/inventory_health_bar.dart';
import '../widgets/notifications_dialog.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/stat_box.dart';
import '../widgets/user_profile_dialog.dart';
import '../widgets/weekly_chart.dart';
import 'approvals_screen.dart';
import 'inventory_screen.dart';
import 'purchasing_screen.dart';
import 'transactions_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentTabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final displayName = auth.hoTen.isNotEmpty ? auth.hoTen : 'Nguyễn Văn An';
    final userInitials = displayName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase();
    final isMobile = ResponsiveLayout.isMobile(context);

    final pages = [
      _buildDashboardTab(context, displayName, userInitials, auth),
      InventoryScreen(onBackToDashboard: () => setState(() => _currentTabIndex = 0)),
      TransactionsScreen(onBackToDashboard: () => setState(() => _currentTabIndex = 0)),
      PurchasingScreen(onBackToDashboard: () => setState(() => _currentTabIndex = 0)),
      ApprovalsScreen(onBackToDashboard: () => setState(() => _currentTabIndex = 0)),
    ];

    if (isMobile) {
      return Scaffold(
        backgroundColor: AppColors.background,
        body: IndexedStack(
          index: _currentTabIndex,
          children: pages,
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      );
    }

    // Giao diện Tablet & Desktop Enterprise đẳng cấp với Sidebar
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Row(
        children: [
          _buildEnterpriseSidebar(context, auth),
          Expanded(
            child: IndexedStack(
              index: _currentTabIndex,
              children: pages,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardTab(BuildContext context, String displayName, String userInitials, AuthProvider auth) {
    final isWide = !ResponsiveLayout.isMobile(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: AdaptivePageContainer(
          padding: EdgeInsets.symmetric(horizontal: isWide ? 24 : 16, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER APP BAR
              _buildTopHeader(context, userInitials, auth),
              const SizedBox(height: 18),

              // 2. PAGE TITLE & TẠO GIAO DỊCH BUTTON
              _buildTitleAndActionButton(context),
              const SizedBox(height: 16),

              // 3. USER GREETING & UPDATE STATUS CHIP
              _buildGreetingBanner(displayName),
              const SizedBox(height: 18),

              // 4. LƯỚI 4 THẺ THỐNG KÊ (Responsive 4 cột trên PC, 2 cột trên Mobile)
              _buildStatGrid(isWide),
              const SizedBox(height: 20),

              // Bố cục thích ứng (Responsive Multi-Column)
              if (isWide) ...[
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Cột trái: Biểu đồ & Hoạt động gần đây
                    Expanded(
                      flex: 6,
                      child: Column(
                        children: [
                          _buildWeeklyChartCard(),
                          const SizedBox(height: 16),
                          _buildRecentActivitiesCard(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    // Cột phải: Sức khỏe tồn kho, Cảnh báo & Chi nhánh
                    Expanded(
                      flex: 4,
                      child: Column(
                        children: [
                          _buildInventoryHealthCard(),
                          const SizedBox(height: 16),
                          _buildAlertListCard(),
                          const SizedBox(height: 16),
                          _buildBranchCard(),
                        ],
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Cột đơn cuộn mượt cho điện thoại
                _buildWeeklyChartCard(),
                const SizedBox(height: 16),
                _buildInventoryHealthCard(),
                const SizedBox(height: 16),
                _buildAlertListCard(),
                const SizedBox(height: 16),
                _buildRecentActivitiesCard(),
                const SizedBox(height: 16),
                _buildBranchCard(),
              ],
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }


  // 1. Top Header
  Widget _buildTopHeader(BuildContext context, String userInitials, AuthProvider auth) {
    return Row(
      children: [
        // Icon thương hiệu Bếp Kho
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Center(
            child: Icon(Icons.restaurant_rounded, color: Colors.white, size: 22),
          ),
        ),
        const SizedBox(width: 10),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bếp Kho', style: AppTextStyles.brandName),
            Text('Quản lý nhà hàng', style: AppTextStyles.brandSub),
          ],
        ),
        const Spacer(),
        // Chuông thông báo có badge số 3
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () => NotificationsDialog.show(context),
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.notifications_none_rounded, color: AppColors.textMain, size: 20),
              ),
            ),
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.danger,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(width: 10),
        // Avatar chữ cái
        GestureDetector(
          onTap: () => UserProfileDialog.show(context),
          child: CircleAvatar(
            radius: 19,
            backgroundColor: const Color(0xFF0F5A67),
            child: Text(
              userInitials.isNotEmpty ? userInitials : 'NA',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
            ),
          ),
        ),
      ],
    );
  }

  // 2. Title & Action Button
  Widget _buildTitleAndActionButton(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Tổng quan', style: AppTextStyles.pageTitle),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Tạo giao dịch', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          onPressed: () {
            setState(() => _currentTabIndex = 2);
          },
        ),
      ],
    );
  }

  // 3. Greeting & Chip
  Widget _buildGreetingBanner(String displayName) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Xin chào, $displayName', style: AppTextStyles.itemTitle.copyWith(fontSize: 16)),
              const SizedBox(height: 2),
              Text(
                'Tình hình vận hành kho của Nhà hàng An Nhiên hôm nay.',
                style: AppTextStyles.cardHeaderSub.copyWith(fontSize: 13),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: const Color(0xFFEBF5FF),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Text(
            'Cập nhật 10:30',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF2563EB),
            ),
          ),
        ),
      ],
    );
  }

  // 4. 4 Stat Boxes (Chuyển tab mượt mà theo nghiệp vụ)
  Widget _buildStatGrid(bool isWide) {
    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: isWide ? 1.55 : 1.35,
      children: [
        StatBox(
          icon: const Icon(Icons.inventory_2_outlined, color: AppColors.success, size: 18),
          iconBgColor: AppColors.successBg,
          title: 'Giá trị tồn kho',
          value: '486,2 tr',
          subText: '↑ 3,2% so với tháng trước',
          subTextColor: AppColors.success,
          onTap: () => setState(() => _currentTabIndex = 1),
        ),
        StatBox(
          icon: const Icon(Icons.warning_amber_rounded, color: AppColors.danger, size: 18),
          iconBgColor: AppColors.dangerBg,
          title: 'Mặt hàng tồn thấp',
          value: '18',
          subText: '6 mặt hàng cần xử lý ngay',
          subTextColor: AppColors.danger,
          onTap: () => setState(() => _currentTabIndex = 1),
        ),
        StatBox(
          icon: const Icon(Icons.calendar_today_outlined, color: AppColors.warning, size: 18),
          iconBgColor: AppColors.warningBg,
          title: 'Sắp hết hạn',
          value: '9 lô',
          subText: 'Trong vòng 7 ngày tới',
          subTextColor: AppColors.textSub,
          onTap: () => setState(() => _currentTabIndex = 1),
        ),
        StatBox(
          icon: const Icon(Icons.pending_actions_rounded, color: AppColors.infoBlue, size: 18),
          iconBgColor: AppColors.infoBlueBg,
          title: 'Phiếu chờ duyệt',
          value: '5',
          subText: 'Tổng giá trị 42,8 triệu',
          subTextColor: AppColors.infoBlue,
          onTap: () => setState(() => _currentTabIndex = 4),
        ),
      ],
    );
  }

  // 5. Weekly Chart Card
  Widget _buildWeeklyChartCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nhập – xuất 7 ngày', style: AppTextStyles.cardHeaderTitle),
          const SizedBox(height: 2),
          Text('Giá trị theo triệu đồng', style: AppTextStyles.cardHeaderSub),
          const SizedBox(height: 16),
          const WeeklyChart(),
        ],
      ),
    );
  }

  // 6. Inventory Health Card
  Widget _buildInventoryHealthCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Sức khỏe tồn kho', style: AppTextStyles.cardHeaderTitle),
          const SizedBox(height: 2),
          Text('Theo tổng số 326 SKU', style: AppTextStyles.cardHeaderSub),
          const SizedBox(height: 16),
          const InventoryHealthBar(
            label: 'Ổn định',
            percentage: 82,
            color: AppColors.success,
          ),
          const SizedBox(height: 12),
          const InventoryHealthBar(
            label: 'Cần chú ý',
            percentage: 12,
            color: AppColors.warning,
          ),
          const SizedBox(height: 12),
          const InventoryHealthBar(
            label: 'Rủi ro',
            percentage: 6,
            color: AppColors.danger,
          ),
        ],
      ),
    );
  }

  // 7. Alert List Card
  Widget _buildAlertListCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Cảnh báo cần xử lý', style: AppTextStyles.cardHeaderTitle),
          const SizedBox(height: 2),
          Text('Ưu tiên theo mức độ ảnh hưởng', style: AppTextStyles.cardHeaderSub),
          const SizedBox(height: 14),

          _buildAlertItem(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.danger,
            iconBgColor: AppColors.dangerBg,
            title: 'Cá hồi phi lê',
            subtitle: 'Bếp chính · Còn 4 kg',
            tag: 'Tồn thấp',
            tagColor: AppColors.danger,
            tagBgColor: AppColors.dangerBg,
          ),
          const Divider(height: 20, color: AppColors.divider),

          _buildAlertItem(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.warning,
            iconBgColor: AppColors.warningBg,
            title: 'Sữa tươi nguyên kem',
            subtitle: 'Lô LOT-240921 · 28/09/2026',
            tag: 'Sắp hết hạn',
            tagColor: AppColors.warning,
            tagBgColor: AppColors.warningBg,
          ),
          const Divider(height: 20, color: AppColors.divider),

          _buildAlertItem(
            icon: Icons.warning_amber_rounded,
            iconColor: AppColors.danger,
            iconBgColor: AppColors.dangerBg,
            title: 'Dầu ô liu Extra Virgin',
            subtitle: 'Kho khô · Còn 6 chai',
            tag: 'Tồn thấp',
            tagColor: AppColors.danger,
            tagBgColor: AppColors.dangerBg,
          ),
        ],
      ),
    );
  }

  Widget _buildAlertItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String tag,
    required Color tagColor,
    required Color tagBgColor,
  }) {
    return InkWell(
      onTap: () {
        FefoExportDialog.show(context, defaultItemName: title);
      },
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.itemTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.itemSub),
                ],
              ),
            ),
            CustomBadge(
              text: tag,
              textColor: tagColor,
              backgroundColor: tagBgColor,
            ),
          ],
        ),
      ),
    );
  }

  // 8. Recent Activities Card
  Widget _buildRecentActivitiesCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Hoạt động kho gần đây', style: AppTextStyles.cardHeaderTitle),
              TextButton(
                onPressed: () => AuditLogsDialog.show(context),
                child: const Text('Xem tất cả', style: TextStyle(fontSize: 12, color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('Đồng bộ theo thời gian thực', style: AppTextStyles.cardHeaderSub),
          const SizedBox(height: 14),

          _buildActivityItem(
            icon: Icons.download_rounded,
            iconColor: AppColors.success,
            iconBgColor: AppColors.successBg,
            title: 'Đã nhập kho NK-260924-018',
            subtitle: 'Minh Anh · 10:24 hôm nay',
            trailingText: '+ 12.450.000 đ',
            trailingColor: AppColors.textMain,
          ),
          const Divider(height: 20, color: AppColors.divider),

          _buildActivityItem(
            icon: Icons.upload_rounded,
            iconColor: AppColors.infoBlue,
            iconBgColor: AppColors.infoBlueBg,
            title: 'Đã xuất kho XK-260924-042',
            subtitle: 'Trần Khoa · 09:18 hôm nay',
            trailingText: '– 3.280.000 đ',
            trailingColor: AppColors.textMain,
          ),
          const Divider(height: 20, color: AppColors.divider),

          _buildActivityItem(
            icon: Icons.swap_horiz_rounded,
            iconColor: const Color(0xFF0D9488),
            iconBgColor: const Color(0xFFCCFBF1),
            title: 'Điều chuyển DC-260923-009',
            subtitle: 'Kho khô ➔ Bếp chính · Hôm qua',
            trailingText: '24 mặt hàng',
            trailingColor: AppColors.textSub,
          ),
          const Divider(height: 20, color: AppColors.divider),

          _buildActivityItem(
            icon: Icons.fact_check_outlined,
            iconColor: const Color(0xFF475569),
            iconBgColor: const Color(0xFFF1F5F9),
            title: 'Hoàn tất kiểm kê KK-0926',
            subtitle: 'Nguyễn Văn An · Hôm qua',
            trailingText: 'Chênh 420.000 đ',
            trailingColor: AppColors.textSub,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String trailingText,
    required Color trailingColor,
  }) {
    return InkWell(
      onTap: () => AuditLogsDialog.show(context),
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: iconBgColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.itemTitle),
                  const SizedBox(height: 2),
                  Text(subtitle, style: AppTextStyles.itemSub),
                ],
              ),
            ),
            Text(
              trailingText,
              style: AppTextStyles.itemAmount.copyWith(color: trailingColor),
            ),
          ],
        ),
      ),
    );
  }

  // 9. Branch Footer Card
  Widget _buildBranchCard() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primaryLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHI NHÁNH ĐANG DÙNG',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 2),
                RichText(
                  text: TextSpan(
                    style: AppTextStyles.itemTitle.copyWith(fontSize: 13),
                    children: const [
                      TextSpan(text: 'Nhà hàng An Nhiên', style: TextStyle(fontWeight: FontWeight.bold)),
                      TextSpan(text: ' · Quận 1, TP. Hồ Chí Minh', style: TextStyle(color: AppColors.textSub, fontWeight: FontWeight.normal)),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // 10. Bottom Navigation Bar with Badge
  Widget _buildBottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentTabIndex,
      onTap: (index) {
        setState(() => _currentTabIndex = index);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: Colors.white,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textMuted,
      selectedFontSize: 11,
      unselectedFontSize: 11,
      selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
      elevation: 8,
      items: [
        const BottomNavigationBarItem(
          icon: Icon(Icons.grid_view_rounded),
          label: 'Tổng quan',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.inventory_2_outlined),
          label: 'Tồn kho',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.swap_horiz_rounded),
          label: 'Giao dịch',
        ),
        const BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart_outlined),
          label: 'Mua hàng',
        ),
        BottomNavigationBarItem(
          icon: Stack(
            clipBehavior: Clip.none,
            children: [
              const Icon(Icons.check_circle_outline_rounded),
              Positioned(
                top: -4,
                right: -8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                  decoration: const BoxDecoration(
                    color: AppColors.badgeOrange,
                    shape: BoxShape.circle,
                  ),
                  child: const Text(
                    '5',
                    style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
          label: 'Phê duyệt',
        ),
      ],
    );
  }

  // 11. Enterprise Sidebar cho Tablet & Desktop
  Widget _buildEnterpriseSidebar(BuildContext context, AuthProvider auth) {
    final width = MediaQuery.of(context).size.width;
    final isCompact = width < 1100; // Tablet thu nhỏ icon

    return Container(
      width: isCompact ? 80 : 260,
      decoration: BoxDecoration(
        color: AppColors.sidebarBg,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Logo & Tên ứng dụng
          Container(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 20, vertical: 24),
            child: Row(
              mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Icon(Icons.restaurant_rounded, color: Colors.white, size: 24),
                  ),
                ),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Bếp Kho',
                          style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Quản lý kho nhà hàng',
                          style: TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF1E293B)),
          const SizedBox(height: 16),

          // Menu Điều hướng chính
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              children: [
                _buildSidebarNavItem(0, 'Tổng quan', Icons.grid_view_rounded, isCompact),
                _buildSidebarNavItem(1, 'Tra cứu tồn kho', Icons.inventory_2_outlined, isCompact),
                _buildSidebarNavItem(2, 'Luân chuyển kho', Icons.swap_horiz_rounded, isCompact),
                _buildSidebarNavItem(3, 'Quản lý mua hàng', Icons.shopping_cart_outlined, isCompact),
                _buildSidebarNavItem(4, 'Phê duyệt phiếu', Icons.check_circle_outline_rounded, isCompact, badge: '5'),

                const SizedBox(height: 20),
                if (!isCompact) ...[
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    child: Text(
                      'HỆ THỐNG & GIÁM SÁT',
                      style: TextStyle(color: Color(0xFF64748B), fontSize: 10, fontWeight: FontWeight.bold, letterSpacing: 0.8),
                    ),
                  ),
                ],
                ListTile(
                  leading: const Icon(Icons.history_rounded, color: Color(0xFF94A3B8), size: 22),
                  title: isCompact ? null : const Text('Nhật ký kiểm toán', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () => AuditLogsDialog.show(context),
                ),
                ListTile(
                  leading: const Icon(Icons.notifications_none_rounded, color: Color(0xFF94A3B8), size: 22),
                  title: isCompact ? null : const Text('Cảnh báo Telegram', style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  onTap: () => NotificationsDialog.show(context),
                ),
              ],
            ),
          ),

          // Thông tin tài khoản ở chân Sidebar
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Color(0xFF0F172A),
              border: Border(top: BorderSide(color: Color(0xFF1E293B))),
            ),
            child: InkWell(
              onTap: () => UserProfileDialog.show(context),
              borderRadius: BorderRadius.circular(10),
              child: Row(
                mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: AppColors.primary,
                    child: Text(
                      auth.hoTen.isNotEmpty ? auth.hoTen[0].toUpperCase() : 'A',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                  if (!isCompact) ...[
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            auth.hoTen.isNotEmpty ? auth.hoTen : 'Nguyễn Trường Duy',
                            style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            auth.viTri.isNotEmpty ? auth.viTri : 'Nhân viên kho',
                            style: const TextStyle(color: Color(0xFF94A3B8), fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.more_vert, color: Color(0xFF64748B), size: 18),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarNavItem(int index, String title, IconData icon, bool isCompact, {String? badge}) {
    final isSelected = _currentTabIndex == index;

    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      child: Material(
        color: isSelected ? AppColors.primary : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => setState(() => _currentTabIndex = index),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: isCompact ? 12 : 14, vertical: 12),
            child: Row(
              mainAxisAlignment: isCompact ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                Icon(icon, color: isSelected ? Colors.white : const Color(0xFF94A3B8), size: 20),
                if (!isCompact) ...[
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        color: isSelected ? Colors.white : const Color(0xFFCBD5E1),
                        fontSize: 13,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      ),
                    ),
                  ),
                  if (badge != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.badgeOrange,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        badge,
                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
