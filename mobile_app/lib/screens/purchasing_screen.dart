import 'package:flutter/material.dart';
import '../models/purchase_order_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_badge.dart';
import '../widgets/notifications_dialog.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/user_profile_dialog.dart';

class PurchasingScreen extends StatefulWidget {
  final VoidCallback onBackToDashboard;

  const PurchasingScreen({super.key, required this.onBackToDashboard});

  @override
  State<PurchasingScreen> createState() => _PurchasingScreenState();
}

class _PurchasingScreenState extends State<PurchasingScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedStatusFilter = 'Tất cả trạng thái';

  // Dữ liệu mẫu danh sách Đơn mua hàng khớp chuẩn thiết kế
  final List<PurchaseOrderItem> _allOrders = [
    PurchaseOrderItem(
      maDon: 'PO-260924-031',
      tenNhaCungCap: 'Công ty Thực Phẩm Xanh',
      ngayGiao: '26/09/2026',
      soMatHang: 18,
      nguoiTao: 'Minh Anh',
      tongTien: '24.680.000 đ',
      trangThai: 'Đã xác nhận',
    ),
    PurchaseOrderItem(
      maDon: 'PO-260924-030',
      tenNhaCungCap: 'Hải Sản Minh Phú',
      ngayGiao: '25/09/2026',
      soMatHang: 6,
      nguoiTao: 'Trần Khoa',
      tongTien: '18.920.000 đ',
      trangThai: 'Chờ duyệt',
    ),
    PurchaseOrderItem(
      maDon: 'PO-260923-029',
      tenNhaCungCap: 'Nông Trại Đà Lạt',
      ngayGiao: '25/09/2026',
      soMatHang: 14,
      nguoiTao: 'Thu Hà',
      tongTien: '9.560.000 đ',
      trangThai: 'Đang giao',
    ),
    PurchaseOrderItem(
      maDon: 'PO-260922-028',
      tenNhaCungCap: 'Công ty Gia Vị Việt',
      ngayGiao: '24/09/2026',
      soMatHang: 9,
      nguoiTao: 'Quốc Bảo',
      tongTien: '6.450.000 đ',
      trangThai: 'Đã xác nhận',
    ),
    PurchaseOrderItem(
      maDon: 'PO-260921-027',
      tenNhaCungCap: 'Thịt Bò Nhập Khẩu US',
      ngayGiao: '23/09/2026',
      soMatHang: 5,
      nguoiTao: 'Minh Anh',
      tongTien: '32.100.000 đ',
      trangThai: 'Hoàn thành',
    ),
    PurchaseOrderItem(
      maDon: 'PO-260920-026',
      tenNhaCungCap: 'Rau Sạch EcoFarm',
      ngayGiao: '22/09/2026',
      soMatHang: 12,
      nguoiTao: 'Trần Khoa',
      tongTien: '4.890.000 đ',
      trangThai: 'Hoàn thành',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<PurchaseOrderItem> get _filteredOrders {
    return _allOrders.where((item) {
      final matchSearch = item.maDon.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          item.tenNhaCungCap.toLowerCase().contains(_searchController.text.toLowerCase()) ||
          item.nguoiTao.toLowerCase().contains(_searchController.text.toLowerCase());

      final matchStatus = _selectedStatusFilter == 'Tất cả trạng thái' || item.trangThai == _selectedStatusFilter;

      return matchSearch && matchStatus;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredOrders;
    final isMobile = ResponsiveLayout.isMobile(context);

    return SafeArea(
      child: SingleChildScrollView(
        child: AdaptivePageContainer(
          padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. TOP HEADER APP BAR KHỚP THIẾT KẾ
              _buildTopHeader(context),
              const SizedBox(height: 20),

              // 2. TIÊU ĐỀ TRANG
              Text('Quản lý mua hàng', style: AppTextStyles.pageTitle),
              const SizedBox(height: 4),
              Text(
                'Lập kế hoạch, theo dõi đơn mua và hiệu suất nhà cung cấp.',
                style: AppTextStyles.cardHeaderSub.copyWith(fontSize: 13),
              ),
              const SizedBox(height: 18),

              // 3. LƯỚI THẺ THỐNG KÊ (4 cột trên desktop/tablet, 2x2 trên mobile)
              _buildStatGrid(isMobile),
              const SizedBox(height: 16),

              // 4 & 5. TIẾN ĐỘ NGÂN SÁCH & NHÀ CUNG CẤP CẦN CHÚ Ý
              if (isMobile) ...[
                _buildBudgetProgressCard(),
                const SizedBox(height: 14),
                _buildSupplierWarningCard(),
              ] else
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(child: _buildBudgetProgressCard()),
                    const SizedBox(width: 14),
                    Expanded(child: _buildSupplierWarningCard()),
                  ],
                ),
              const SizedBox(height: 22),

              // 6. SECTION ĐƠN MUA GẦN ĐÂY
              _buildRecentOrdersHeader(filtered.length),
              const SizedBox(height: 12),

              // Thanh tìm kiếm
              _buildSearchBar(),
              const SizedBox(height: 12),

              // Hàng bộ lọc và xuất dữ liệu
              _buildFilterRow(),
              const SizedBox(height: 14),

              // Danh sách các thẻ đơn mua (Grid trên tablet/desktop, List trên mobile)
              if (isMobile)
                ...filtered.map((order) => _buildOrderCard(order))
              else
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 14,
                    mainAxisSpacing: 14,
                    mainAxisExtent: 160,
                  ),
                  itemCount: filtered.length,
                  itemBuilder: (context, index) => _buildOrderCard(filtered[index], removeMargin: true),
                ),
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
        // Nút "+ Tạo đơn"
        ElevatedButton.icon(
          onPressed: _showCreateOrderDialog,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          icon: const Icon(Icons.add, size: 18),
          label: const Text('Tạo đơn', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
        ),
        const SizedBox(width: 8),
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

  // 3. Lưới 4 Thẻ Thống Kê
  Widget _buildStatGrid(bool isMobile) {
    final card1 = _buildSmallStatCard(
      icon: Icons.account_balance_wallet_outlined,
      iconBg: const Color(0xFFEEF2FF),
      iconColor: const Color(0xFF4F46E5),
      title: 'Chi mua tháng này',
      value: '248,6 tr',
      subtitle: '76% ngân sách tháng',
      subtitleColor: const Color(0xFF4F46E5),
    );
    final card2 = _buildSmallStatCard(
      icon: Icons.inbox_outlined,
      iconBg: const Color(0xFFFFF7ED),
      iconColor: const Color(0xFFEA580C),
      title: 'Đơn đang mở',
      value: '14',
      subtitle: '4 đơn cần nhận hôm nay',
      subtitleColor: const Color(0xFFC2410C),
    );
    final card3 = _buildSmallStatCard(
      icon: Icons.local_shipping_outlined,
      iconBg: const Color(0xFFECFDF5),
      iconColor: const Color(0xFF059669),
      title: 'Giao đúng hạn',
      value: '94,2%',
      subtitle: '↑ 1,8% trong 30 ngày',
      subtitleColor: const Color(0xFF059669),
    );
    final card4 = _buildSmallStatCard(
      icon: Icons.savings_outlined,
      iconBg: const Color(0xFFF0FDF4),
      iconColor: const Color(0xFF16A34A),
      title: 'Tiết kiệm ước tính',
      value: '18,4 tr',
      subtitle: 'Từ so sánh báo giá',
      subtitleColor: AppColors.textSub,
    );

    if (!isMobile) {
      return Row(
        children: [
          Expanded(child: card1),
          const SizedBox(width: 12),
          Expanded(child: card2),
          const SizedBox(width: 12),
          Expanded(child: card3),
          const SizedBox(width: 12),
          Expanded(child: card4),
        ],
      );
    }

    return Column(
      children: [
        Row(
          children: [
            Expanded(child: card1),
            const SizedBox(width: 12),
            Expanded(child: card2),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(child: card3),
            const SizedBox(width: 12),
            Expanded(child: card4),
          ],
        ),
      ],
    );
  }

  Widget _buildSmallStatCard({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String value,
    required String subtitle,
    required Color subtitleColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(height: 12),
          Text(title, style: TextStyle(fontSize: 12, color: AppColors.textSub, fontWeight: FontWeight.w500)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.textMain)),
          const SizedBox(height: 4),
          Text(subtitle, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: subtitleColor)),
        ],
      ),
    );
  }

  // 4. Thẻ Tiến độ ngân sách tháng 9
  Widget _buildBudgetProgressCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Tiến độ ngân sách tháng 9', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain)),
              Text('248,6 / 325 triệu đồng', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppColors.primary)),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: 0.765,
              minHeight: 10,
              backgroundColor: const Color(0xFFE2E8F0),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Đã sử dụng 76%', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
              Text('76,4 triệu còn lại', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.primary)),
            ],
          ),
        ],
      ),
    );
  }

  // 5. Thẻ Nhà cung cấp cần chú ý
  Widget _buildSupplierWarningCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Nhà cung cấp cần chú ý', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain)),
          const SizedBox(height: 2),
          Text('Theo chất lượng giao hàng', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFFBEB),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFDE68A)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEF3C7),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.warning_amber_rounded, color: Color(0xFFD97706), size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Bếp Sạch Sài Gòn', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain)),
                      const SizedBox(height: 2),
                      Text('2 lần giao trễ trong tháng', style: TextStyle(fontSize: 12, color: Color(0xFFB45309), fontWeight: FontWeight.w500)),
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

  // 6. Section Đơn mua gần đây
  Widget _buildRecentOrdersHeader(int count) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Đơn mua gần đây', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16, color: AppColors.textMain)),
        Text('$count đơn hàng', style: TextStyle(fontSize: 13, color: AppColors.textSub)),
      ],
    );
  }

  // Thanh tìm kiếm
  Widget _buildSearchBar() {
    return TextField(
      controller: _searchController,
      onChanged: (_) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'Tìm đơn mua...',
        hintStyle: TextStyle(color: AppColors.textMuted, fontSize: 14),
        prefixIcon: const Icon(Icons.search, color: AppColors.textMuted, size: 20),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  // Hàng filter
  Widget _buildFilterRow() {
    final statusList = ['Tất cả trạng thái', 'Đã xác nhận', 'Chờ duyệt', 'Đang giao', 'Hoàn thành'];

    return Row(
      children: [
        // Dropdown trạng thái
        Expanded(
          child: Container(
            height: 40,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.border),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: _selectedStatusFilter,
                isExpanded: true,
                icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: AppColors.textSub),
                style: const TextStyle(fontSize: 13, color: AppColors.textMain, fontWeight: FontWeight.w500),
                items: statusList.map((String s) {
                  return DropdownMenuItem<String>(value: s, child: Text(s));
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => _selectedStatusFilter = val);
                },
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        // Nút Xuất dữ liệu
        OutlinedButton.icon(
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Đang xuất danh sách đơn mua hàng ra file Excel...')),
            );
          },
          style: OutlinedButton.styleFrom(
            backgroundColor: Colors.white,
            foregroundColor: AppColors.textMain,
            side: const BorderSide(color: AppColors.border),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          ),
          icon: const Icon(Icons.file_download_outlined, size: 18),
          label: const Text('Xuất dữ liệu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ),
      ],
    );
  }

  // Card từng đơn mua hàng
  Widget _buildOrderCard(PurchaseOrderItem order, {bool removeMargin = false}) {
    Color badgeBg;
    Color badgeColor;

    switch (order.trangThai) {
      case 'Đã xác nhận':
        badgeBg = const Color(0xFFDCFCE7);
        badgeColor = const Color(0xFF15803D);
        break;
      case 'Chờ duyệt':
        badgeBg = const Color(0xFFFEF3C7);
        badgeColor = const Color(0xFFB45309);
        break;
      case 'Đang giao':
        badgeBg = const Color(0xFFDBEAFE);
        badgeColor = const Color(0xFF1D4ED8);
        break;
      case 'Hoàn thành':
        badgeBg = const Color(0xFFF1F5F9);
        badgeColor = const Color(0xFF475569);
        break;
      default:
        badgeBg = const Color(0xFFF1F5F9);
        badgeColor = AppColors.textSub;
    }

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
          // Dòng 1: Mã đơn, Badge trạng thái, Menu 3 chấm
          Row(
            children: [
              Text(
                order.maDon,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textMain),
              ),
              const SizedBox(width: 8),
              CustomBadge(
                text: order.trangThai,
                textColor: badgeColor,
                backgroundColor: badgeBg,
                fontSize: 11,
              ),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: const Icon(Icons.more_horiz, color: AppColors.textSub, size: 20),
                onPressed: () => _showOrderOptions(order),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // Dòng 2: Tên nhà cung cấp
          Text(
            order.tenNhaCungCap,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15, color: AppColors.textMain),
          ),
          const SizedBox(height: 4),

          // Dòng 3: Chi tiết giao & tạo
          Text(
            'Giao: ${order.ngayGiao} • ${order.soMatHang} mặt hàng • Tạo: ${order.nguoiTao}',
            style: const TextStyle(fontSize: 12, color: AppColors.textSub),
          ),
          const SizedBox(height: 12),

          const Divider(height: 1, color: AppColors.divider),
          const SizedBox(height: 10),

          // Dòng 4: Tổng tiền
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'TỔNG TIỀN',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textMuted, letterSpacing: 0.5),
              ),
              Text(
                order.tongTien,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppColors.textMain),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Tùy chọn 3 chấm cho đơn hàng
  void _showOrderOptions(PurchaseOrderItem order) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility_outlined, color: AppColors.primary),
              title: Text('Xem chi tiết đơn ${order.maDon}'),
              onTap: () {
                Navigator.pop(ctx);
                _showOrderDetails(order);
              },
            ),
            ListTile(
              leading: const Icon(Icons.print_outlined),
              title: const Text('In phiếu đặt hàng (PDF)'),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Đang tạo file in cho đơn ${order.maDon}...')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showOrderDetails(PurchaseOrderItem order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: Text(order.maDon, style: const TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Nhà cung cấp: ${order.tenNhaCungCap}', style: const TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 6),
            Text('Trạng thái: ${order.trangThai}'),
            Text('Ngày giao dự kiến: ${order.ngayGiao}'),
            Text('Số lượng mặt hàng: ${order.soMatHang} items'),
            Text('Người lập đơn: ${order.nguoiTao}'),
            const SizedBox(height: 10),
            Text('Tổng giá trị: ${order.tongTien}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }

  // Dialog Tạo đơn mua hàng mới
  void _showCreateOrderDialog() {
    final nccController = TextEditingController();
    final itemsCountController = TextEditingController(text: '5');
    final amountController = TextEditingController(text: '12.500.000');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Tạo Đơn Mua Hàng (PO)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nccController,
                decoration: const InputDecoration(labelText: 'Tên nhà cung cấp *', hintText: 'VD: Nông Trại Xanh'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: itemsCountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Số mặt hàng', hintText: 'VD: 8'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Tổng tiền ước tính (VNĐ)', hintText: 'VD: 15000000'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy', style: TextStyle(color: AppColors.textSub))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              if (nccController.text.trim().isEmpty) return;
              final newId = 'PO-260924-03${_allOrders.length + 1}';
              setState(() {
                _allOrders.insert(
                  0,
                  PurchaseOrderItem(
                    maDon: newId,
                    tenNhaCungCap: nccController.text.trim(),
                    ngayGiao: '27/09/2026',
                    soMatHang: int.tryParse(itemsCountController.text) ?? 1,
                    nguoiTao: 'Nguyễn Trường Duy',
                    tongTien: '${amountController.text} đ',
                    trangThai: 'Chờ duyệt',
                  ),
                );
              });
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đã tạo thành công đơn mua $newId'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Lưu đơn'),
          ),
        ],
      ),
    );
  }
}
