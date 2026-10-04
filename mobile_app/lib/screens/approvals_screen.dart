import 'package:flutter/material.dart';
import '../models/approval_request_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_badge.dart';
import '../widgets/notifications_dialog.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/user_profile_dialog.dart';

class ApprovalsScreen extends StatefulWidget {
  final VoidCallback onBackToDashboard;

  const ApprovalsScreen({super.key, required this.onBackToDashboard});

  @override
  State<ApprovalsScreen> createState() => _ApprovalsScreenState();
}

class _ApprovalsScreenState extends State<ApprovalsScreen> {
  int _selectedTab = 0; // 0: Chờ duyệt, 1: Đã duyệt, 2: Đã từ chối
  String _currentBranch = 'Nhà hàng An Nhiên';
  String _currentBranchAddress = 'Quận 1, TP. Hồ Chí Minh';

  // Danh sách các phiếu phê duyệt ban đầu chuẩn xác theo thiết kế Figma
  final List<ApprovalRequestItem> _allRequests = [
    ApprovalRequestItem(
      maPhieu: 'PO-260924-030',
      tieuDe: 'Đơn mua Hải Sản Minh Phú',
      chiTiet: '6 mặt hàng • Giao ngày 25/09/2026 • Tạo bởi Trần Khoa • 36 phút trước',
      giaTri: '18.920.000 đ',
      mucDo: 'Khẩn',
      loaiPhieu: ApprovalType.donMua,
      trangThai: 'Chờ duyệt',
    ),
    ApprovalRequestItem(
      maPhieu: 'NK-260923-017',
      tieuDe: 'Phiếu nhập kho mát',
      chiTiet: '8 mặt hàng • Lô hải sản đông lạnh • Tạo bởi Minh Anh • 1 giờ trước',
      giaTri: '18.720.000 đ',
      mucDo: 'Bình thường',
      loaiPhieu: ApprovalType.nhapKho,
      trangThai: 'Chờ duyệt',
    ),
    ApprovalRequestItem(
      maPhieu: 'DC-260924-010',
      tieuDe: 'Điều chuyển sang Bếp chính',
      chiTiet: '24 mặt hàng • Phục vụ tiệc tối • Tạo bởi Thu Hà • 2 giờ trước',
      giaTri: '5.860.000 đ',
      mucDo: 'Khẩn',
      loaiPhieu: ApprovalType.dieuChuyen,
      trangThai: 'Chờ duyệt',
    ),
    ApprovalRequestItem(
      maPhieu: 'ADJ-260924-004',
      tieuDe: 'Điều chỉnh chênh lệch kiểm kê',
      chiTiet: '4 mặt hàng • Biên bản KK-0926 • Tạo bởi Quốc Bảo • 3 giờ trước',
      giaTri: '- 420.000 đ',
      isNegative: true,
      mucDo: 'Bình thường',
      loaiPhieu: ApprovalType.kiemKe,
      trangThai: 'Chờ duyệt',
    ),
    ApprovalRequestItem(
      maPhieu: 'PO-260924-029',
      tieuDe: 'Đơn mua Gia Vị Việt',
      chiTiet: '12 mặt hàng • Giao ngày 24/09/2026 • Tạo bởi Minh Anh • 5 giờ trước',
      giaTri: '7.340.000 đ',
      mucDo: 'Bình thường',
      loaiPhieu: ApprovalType.donMua,
      trangThai: 'Chờ duyệt',
    ),
  ];

  int get _pendingCount => _allRequests.where((r) => r.trangThai == 'Chờ duyệt').length;
  int get _approvedCount => _allRequests.where((r) => r.trangThai == 'Đã duyệt').length + 12; // 12 mẫu figma

  List<ApprovalRequestItem> get _filteredList {
    if (_selectedTab == 0) {
      return _allRequests.where((r) => r.trangThai == 'Chờ duyệt').toList();
    } else if (_selectedTab == 1) {
      return _allRequests.where((r) => r.trangThai == 'Đã duyệt').toList();
    } else {
      return _allRequests.where((r) => r.trangThai == 'Đã từ chối').toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    final list = _filteredList;
    final isMobile = ResponsiveLayout.isMobile(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: AdaptivePageContainer(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER APP BAR
              _buildTopHeader(context),
              const SizedBox(height: 20),

              // 2. TIÊU ĐỀ CHÍNH & BADGE YÊU CẦU MỚI
              Text('Phê duyệt', style: AppTextStyles.pageTitle),
              const SizedBox(height: 10),
              Row(
                children: [
                  Text(
                    'Yêu cầu chờ duyệt',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textMain),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '$_pendingCount yêu cầu mới',
                      style: const TextStyle(
                        color: Color(0xFFB45309),
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                'Xử lý các đề nghị theo vai trò Quản lý kho và hạn mức được phân quyền.',
                style: AppTextStyles.cardHeaderSub.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 18),

              // 3. THẺ THỐNG KÊ (Row trên tablet/desktop, cuộn ngang trên mobile)
              _buildHorizontalStats(isMobile),
              const SizedBox(height: 20),

              // 4. TAB PHÂN LOẠI & NÚT LỌC
              _buildTabsAndFilter(),
              const SizedBox(height: 16),

              // 5. DANH SÁCH CÁC PHIẾU CẦN PHÊ DUYỆT (Grid trên tablet/desktop, List trên mobile)
              if (list.isEmpty)
                _buildEmptyState()
              else if (isMobile)
                ...list.map((item) => _buildApprovalCard(item))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 200,
                  ),
                  itemCount: list.length,
                  itemBuilder: (context, index) => _buildApprovalCard(list[index], removeMargin: true),
                ),

              const SizedBox(height: 20),

              // 6. CARD CHI NHÁNH ĐANG DÙNG (CUỐI TRANG FIGMA)
              _buildBranchCard(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // 1. Top Header App Bar
  Widget _buildTopHeader(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: const Icon(Icons.restaurant_menu_rounded, color: Colors.white, size: 22),
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
        // Chuông thông báo
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded, color: AppColors.textMain, size: 26),
              onPressed: () => NotificationsDialog.show(context),
            ),
            Positioned(
              top: 8,
              right: 8,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        // Avatar NA
        GestureDetector(
          onTap: () => UserProfileDialog.show(context),
          child: const CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFF0F4C5C),
            child: Text('NA', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
          ),
        ),
      ],
    );
  }

  // 3. Thẻ thống kê lướt ngang (hoặc dạng Row trên desktop)
  Widget _buildHorizontalStats(bool isMobile) {
    final card1 = _buildStatCard(
      icon: Icons.mail_outline_rounded,
      iconBg: const Color(0xFFFFF7ED),
      iconColor: const Color(0xFFEA580C),
      title: 'Chờ tôi duyệt',
      number: '$_pendingCount',
      subtitle: '2 yêu cầu ưu tiên cao',
      subtitleColor: const Color(0xFFEA580C),
      width: isMobile ? 155 : null,
    );
    final card2 = _buildStatCard(
      icon: Icons.check_circle_outline_rounded,
      iconBg: const Color(0xFFECFDF5),
      iconColor: const Color(0xFF10B981),
      title: 'Đã duyệt hôm nay',
      number: '$_approvedCount',
      subtitle: 'Tổng giá trị 86,4 triệu',
      subtitleColor: const Color(0xFF10B981),
      width: isMobile ? 155 : null,
    );
    final card3 = _buildStatCard(
      icon: Icons.access_time_rounded,
      iconBg: const Color(0xFFEFF6FF),
      iconColor: const Color(0xFF3B82F6),
      title: 'Thời gian TB',
      number: '1g 18p',
      subtitle: 'Nhanh hơn SLA quy định',
      subtitleColor: const Color(0xFF3B82F6),
      width: isMobile ? 155 : null,
    );

    if (!isMobile) {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 14),
          Expanded(child: card2),
          const SizedBox(width: 14),
          Expanded(child: card3),
        ],
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          card1,
          const SizedBox(width: 12),
          card2,
          const SizedBox(width: 12),
          card3,
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String number,
    required String subtitle,
    required Color subtitleColor,
    double? width = 155,
  }) {
    return Container(
      width: width,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 12, color: AppColors.textSub, fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(number, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: AppColors.textMain)),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: subtitleColor),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // 4. Tab Switcher & Nút Lọc
  Widget _buildTabsAndFilter() {
    return Row(
      children: [
        _buildUnderlineTab('Chờ duyệt', '($_pendingCount)', 0),
        const SizedBox(width: 16),
        _buildUnderlineTab('Đã duyệt', '', 1),
        const SizedBox(width: 16),
        _buildUnderlineTab('Đã từ chối', '', 2),
        const Spacer(),
        // Nút Lọc
        OutlinedButton.icon(
          onPressed: _showFilterDialog,
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textMain,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          ),
          icon: const Icon(Icons.tune_rounded, size: 16),
          label: const Text('Lọc', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  Widget _buildUnderlineTab(String title, String count, int tabIndex) {
    final isSelected = _selectedTab == tabIndex;

    return GestureDetector(
      onTap: () => setState(() => _selectedTab = tabIndex),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppColors.primary : AppColors.textSub,
                ),
              ),
              if (count.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  count,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? AppColors.primary : AppColors.textSub,
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Container(
            height: 2.5,
            width: 55,
            decoration: BoxDecoration(
              color: isSelected ? AppColors.primary : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
    );
  }

  // 5. Thẻ Phê duyệt từng phiếu
  Widget _buildApprovalCard(ApprovalRequestItem item, {bool removeMargin = false}) {
    IconData icon;
    Color iconBg;
    Color iconColor;

    switch (item.loaiPhieu) {
      case ApprovalType.donMua:
        icon = Icons.shopping_bag_outlined;
        iconBg = const Color(0xFFEFF6FF);
        iconColor = const Color(0xFF2563EB);
        break;
      case ApprovalType.nhapKho:
        icon = Icons.inventory_2_outlined;
        iconBg = const Color(0xFFCCFBF1);
        iconColor = const Color(0xFF0D9488);
        break;
      case ApprovalType.dieuChuyen:
        icon = Icons.swap_horiz_rounded;
        iconBg = const Color(0xFFE0F2FE);
        iconColor = const Color(0xFF0284C7);
        break;
      case ApprovalType.kiemKe:
        icon = Icons.fact_check_outlined;
        iconBg = const Color(0xFFDCFCE7);
        iconColor = const Color(0xFF16A34A);
        break;
    }

    final isUrgent = item.mucDo == 'Khẩn';

    return Container(
      margin: removeMargin ? EdgeInsets.zero : const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: Icon loại phiếu + Mã phiếu & Mức độ + Tiêu đề
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          item.maPhieu,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: item.loaiPhieu == ApprovalType.donMua ? const Color(0xFF2563EB) : AppColors.primary,
                          ),
                        ),
                        const SizedBox(width: 6),
                        CustomBadge(
                          text: item.mucDo,
                          textColor: isUrgent ? const Color(0xFFDC2626) : const Color(0xFF0284C7),
                          backgroundColor: isUrgent ? const Color(0xFFFEE2E2) : const Color(0xFFE0F2FE),
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.tieuDe,
                      style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textMain),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Chi tiết phiếu
          Padding(
            padding: const EdgeInsets.only(left: 44),
            child: Text(
              item.chiTiet,
              style: const TextStyle(fontSize: 12, color: AppColors.textSub, height: 1.3),
            ),
          ),
          const SizedBox(height: 12),

          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 12),

          // Giá trị & Nút thao tác
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'GIÁ TRỊ',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.giaTri,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: item.isNegative ? const Color(0xFFDC2626) : AppColors.textMain,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (item.trangThai == 'Chờ duyệt') ...[
                // Nút "Từ chối"
                OutlinedButton.icon(
                  onPressed: () => _handleReject(item),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.textMain,
                    side: const BorderSide(color: Color(0xFFD1D5DB)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  ),
                  icon: const Icon(Icons.close_rounded, size: 16, color: AppColors.textMain),
                  label: const Text('Từ chối', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 8),
                // Nút "Duyệt"
                ElevatedButton.icon(
                  onPressed: () => _handleApprove(item),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F4C5C),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  ),
                  icon: const Icon(Icons.check_rounded, size: 16),
                  label: const Text('Duyệt', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                ),
              ] else ...[
                CustomBadge(
                  text: item.trangThai,
                  textColor: item.trangThai == 'Đã duyệt' ? const Color(0xFF15803D) : const Color(0xFFB91C1C),
                  backgroundColor: item.trangThai == 'Đã duyệt' ? const Color(0xFFDCFCE7) : const Color(0xFFFEE2E2),
                  fontSize: 12,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  // 6. Card Chi nhánh đang dùng
  Widget _buildBranchCard() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFECFDF5),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(Icons.verified_user_outlined, color: Color(0xFF059669), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'CHI NHÁNH ĐANG DÙNG',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5),
                ),
                const SizedBox(height: 2),
                Text(
                  _currentBranch,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain),
                ),
                Text(
                  _currentBranchAddress,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                ),
              ],
            ),
          ),
          OutlinedButton(
            onPressed: _showChangeBranchDialog,
            style: OutlinedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: AppColors.textMain,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            ),
            child: const Text('Đổi', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.inbox_outlined, size: 48, color: AppColors.textMuted),
          const SizedBox(height: 12),
          Text('Không có yêu cầu nào trong mục này', style: TextStyle(color: AppColors.textSub, fontSize: 14)),
        ],
      ),
    );
  }

  // Xử lý phê duyệt
  void _handleApprove(ApprovalRequestItem item) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Xác nhận phê duyệt', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Bạn có chắc chắn muốn phê duyệt phiếu "${item.tieuDe}" (${item.maPhieu}) với giá trị ${item.giaTri}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: AppColors.textSub))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0F4C5C), foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                item.trangThai = 'Đã duyệt';
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã phê duyệt thành công phiếu ${item.maPhieu}!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Phê duyệt'),
          ),
        ],
      ),
    );
  }

  // Xử lý từ chối
  void _handleReject(ApprovalRequestItem item) {
    final reasonController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Từ chối phiếu', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nhập lý do từ chối cho phiếu ${item.maPhieu}:'),
            const SizedBox(height: 10),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(
                hintText: 'VD: Vượt định mức ngân sách tháng...',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: AppColors.textSub))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.danger, foregroundColor: Colors.white),
            onPressed: () {
              setState(() {
                item.trangThai = 'Đã từ chối';
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Đã từ chối phiếu ${item.maPhieu}!'),
                  backgroundColor: AppColors.danger,
                ),
              );
            },
            child: const Text('Từ chối'),
          ),
        ],
      ),
    );
  }

  // Dialog Đổi chi nhánh
  void _showChangeBranchDialog() {
    final branches = [
      {'name': 'Nhà hàng An Nhiên', 'addr': 'Quận 1, TP. Hồ Chí Minh'},
      {'name': 'Nhà hàng An Nhiên - Chi nhánh 2', 'addr': 'Quận 7, TP. Hồ Chí Minh'},
      {'name': 'Kho Trung Tâm Miền Nam', 'addr': 'TP. Thủ Đức, TP. Hồ Chí Minh'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Chọn chi nhánh hoạt động', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: branches.map((b) {
            return ListTile(
              leading: const Icon(Icons.storefront_outlined, color: AppColors.primary),
              title: Text(b['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text(b['addr']!, style: const TextStyle(fontSize: 12)),
              onTap: () {
                setState(() {
                  _currentBranch = b['name']!;
                  _currentBranchAddress = b['addr']!;
                });
                Navigator.pop(ctx);
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  // Dialog Lọc
  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bộ lọc yêu cầu phê duyệt', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.priority_high_rounded, color: AppColors.danger),
              title: const Text('Chỉ hiển thị yêu cầu "Khẩn"'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              leading: const Icon(Icons.attach_money_rounded, color: AppColors.primary),
              title: const Text('Sắp xếp theo giá trị cao nhất'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}
