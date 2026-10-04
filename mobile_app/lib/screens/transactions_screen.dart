import 'package:flutter/material.dart';
import '../models/transaction_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_badge.dart';
import '../widgets/fefo_export_dialog.dart';
import '../widgets/inventory_audit_dialog.dart';
import '../widgets/notifications_dialog.dart';
import '../widgets/po_import_dialog.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/user_profile_dialog.dart';

class TransactionsScreen extends StatefulWidget {
  final VoidCallback onBackToDashboard;

  const TransactionsScreen({super.key, required this.onBackToDashboard});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedType = 'Tất cả';
  String _selectedStatus = 'Tất cả';
  String _selectedTime = 'Tháng này';

  // Dữ liệu mẫu chuẩn hóa nghiệp vụ F&B (Mã phiếu kinh doanh, thời gian, tên kho, nhà cung cấp)
  final List<TransactionItem> _transactions = [
    TransactionItem(
      maPhieu: 'NK-260924-018',
      loaiGiaoDich: 'Nhập kho',
      diaDiemHoacNcc: 'Kho khô - NCC Thực Phẩm Xanh',
      thoiGian: '24/09/2026 10:24',
      soLuongMatHang: 16,
      tongGiaTri: '12.450.000 đ',
      trangThai: 'Hoàn tất',
    ),
    TransactionItem(
      maPhieu: 'XK-260924-042',
      loaiGiaoDich: 'Xuất kho',
      diaDiemHoacNcc: 'Kho mát ➔ Bếp chính (FEFO)',
      thoiGian: '24/09/2026 09:18',
      soLuongMatHang: 8,
      tongGiaTri: '3.280.000 đ',
      trangThai: 'Hoàn tất',
    ),
    TransactionItem(
      maPhieu: 'DC-260923-009',
      loaiGiaoDich: 'Điều chuyển',
      diaDiemHoacNcc: 'Kho khô ➔ Bếp chính',
      thoiGian: '23/09/2026 16:45',
      soLuongMatHang: 24,
      tongGiaTri: '5.120.000 đ',
      trangThai: 'Hoàn tất',
    ),
    TransactionItem(
      maPhieu: 'PO-260924-001',
      loaiGiaoDich: 'Mua hàng PO',
      diaDiemHoacNcc: 'NCC Hải Sản Biển Đông',
      thoiGian: '24/09/2026 08:30',
      soLuongMatHang: 5,
      tongGiaTri: '18.600.000 đ',
      trangThai: 'Chờ duyệt',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = ResponsiveLayout.isMobile(context);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: AdaptivePageContainer(
            padding: EdgeInsets.symmetric(horizontal: isMobile ? 16 : 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP HEADER (Bếp Kho + Nút Tạo Phiếu + Bell + Avatar)
                _buildTopHeader(context),
                const SizedBox(height: 16),

                // 2. TIÊU ĐỀ TRANG
                Text('Theo dõi luân chuyển kho', style: AppTextStyles.pageTitle),
                const SizedBox(height: 4),
                Text(
                  'Quản lý phiếu nhập, xuất và điều chuyển giữa các khu vực.',
                  style: AppTextStyles.cardHeaderSub.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 16),

                // 3. 2 THẺ THỐNG KÊ (Nhập trong tháng & Xuất trong tháng)
                _buildSummaryCards(),
                const SizedBox(height: 16),

                // 4. THANH TÌM KIẾM & BỘ LỌC 3 CẤP (Loại, Trạng thái, Thời gian)
                _buildSearchAndFilters(),
                const SizedBox(height: 20),

                // 5. TIÊU ĐỀ DANH SÁCH PHIẾU KHO
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Danh sách phiếu kho', style: AppTextStyles.cardHeaderTitle),
                    const SizedBox(height: 2),
                    Text('1.742 giao dịch · Dữ liệu đồng bộ thời gian thực', style: AppTextStyles.cardHeaderSub),
                  ],
                ),
                const SizedBox(height: 12),

                // 6. DANH SÁCH THẺ PHIẾU GIAO DỊCH (Adaptive: Grid trên Tablet/Desktop, List trên Mobile)
                if (isMobile)
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _transactions.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(_transactions[index]);
                    },
                  )
                else
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 14,
                      mainAxisSpacing: 14,
                      mainAxisExtent: 205,
                    ),
                    itemCount: _transactions.length,
                    itemBuilder: (context, index) {
                      return _buildTransactionCard(_transactions[index]);
                    },
                  ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
        // Nút Tạo phiếu
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Tạo phiếu', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          onPressed: _showCreateTransactionOptions,
        ),
        const SizedBox(width: 8),
        // Chuông thông báo
        Stack(
          clipBehavior: Clip.none,
          children: [
            GestureDetector(
              onTap: () => NotificationsDialog.show(context),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.border),
                ),
                child: const Icon(Icons.notifications_none_rounded, color: AppColors.textMain, size: 19),
              ),
            ),
            Positioned(
              top: -3,
              right: -3,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(color: AppColors.danger, shape: BoxShape.circle),
                child: const Text('3', style: TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
        const SizedBox(width: 8),
        // Avatar
        GestureDetector(
          onTap: () => UserProfileDialog.show(context),
          child: const CircleAvatar(
            radius: 18,
            backgroundColor: Color(0xFF0F5A67),
            child: Text('NA', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCards() {
    return Row(
      children: [
        // Thẻ Nhập trong tháng
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.successBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_downward_rounded, color: AppColors.success, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Nhập trong tháng',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSub),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('186,4 tr', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                const SizedBox(height: 4),
                const Text('↑ 8,4% so với tháng trước', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.success)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        // Thẻ Xuất trong tháng
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: AppColors.infoBlueBg,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(Icons.arrow_upward_rounded, color: AppColors.infoBlue, size: 18),
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Xuất trong tháng',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppColors.textSub),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('128,6 tr', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                const SizedBox(height: 4),
                const Text('1.284 lượt xuất kho', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textMuted)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilters() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          // Ô Tìm mã phiếu
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm mã phiếu...',
              hintStyle: const TextStyle(fontSize: 13, color: AppColors.textMuted),
              prefixIcon: const Icon(Icons.search_rounded, color: AppColors.textMuted, size: 20),
              filled: true,
              fillColor: const Color(0xFFF8FAFC),
              contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // 3 Ô Dropdown: LOẠI, TRẠNG THÁI, THỜI GIAN
          Row(
            children: [
              Expanded(
                child: _buildCompactFilter(
                  label: 'LOẠI',
                  value: _selectedType,
                  items: ['Tất cả', 'Nhập kho', 'Xuất kho', 'Điều chuyển', 'PO'],
                  onChanged: (val) => setState(() => _selectedType = val!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactFilter(
                  label: 'TRẠNG THÁI',
                  value: _selectedStatus,
                  items: ['Tất cả', 'Hoàn tất', 'Chờ duyệt', 'Đã hủy'],
                  onChanged: (val) => setState(() => _selectedStatus = val!),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildCompactFilter(
                  label: 'THỜI GIAN',
                  value: _selectedTime,
                  items: ['Tháng này', 'Hôm nay', 'Tuần này', 'Quý này'],
                  onChanged: (val) => setState(() => _selectedTime = val!),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Nút Bộ lọc nâng cao
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.textBody,
              minimumSize: const Size(double.infinity, 40),
              side: const BorderSide(color: Color(0xFFCBD5E1)),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.tune_rounded, size: 16),
            label: const Text('Bộ lọc nâng cao theo Kho & Nhân viên', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            onPressed: _showAdvancedFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildCompactFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.textMuted)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: AppColors.textSub),
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textMain),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(TransactionItem item) {
    Color typeColor = AppColors.success;
    Color typeBg = AppColors.successBg;

    if (item.loaiGiaoDich == 'Xuất kho') {
      typeColor = AppColors.infoBlue;
      typeBg = AppColors.infoBlueBg;
    } else if (item.loaiGiaoDich == 'Điều chuyển') {
      typeColor = const Color(0xFF0D9488);
      typeBg = const Color(0xFFCCFBF1);
    } else if (item.loaiGiaoDich == 'Mua hàng PO') {
      typeColor = Colors.orange;
      typeBg = const Color(0xFFFFFBEB);
    }

    return InkWell(
      onTap: () => _showTransactionDetails(item),
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Dòng 1: Mã phiếu + Badge loại phiếu + Icon 3 chấm
            Row(
              children: [
                Text(
                  item.maPhieu,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: AppColors.textMain),
                ),
                const SizedBox(width: 8),
                CustomBadge(
                  text: item.loaiGiaoDich,
                  textColor: typeColor,
                  backgroundColor: typeBg,
                ),
                const Spacer(),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.more_horiz_rounded, color: AppColors.textMuted, size: 20),
                  onPressed: () => _showTransactionDetails(item),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Dòng 2: Địa điểm / Kho / Nhà cung cấp
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: AppColors.textSub),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    item.diaDiemHoacNcc,
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: AppColors.textBody),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Dòng 3: Thời gian & Số lượng mặt hàng
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(item.thoiGian, style: const TextStyle(fontSize: 12, color: AppColors.textMuted)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    '${item.soLuongMatHang} mặt hàng',
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.textSub),
                  ),
                ),
              ],
            ),
            const Divider(height: 20, color: AppColors.divider),

            // Dòng 4: GIÁ TRỊ & Trạng thái Hoàn tất / Chờ duyệt
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('GIÁ TRỊ', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
                    const SizedBox(height: 2),
                    Text(
                      item.tongGiaTri,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textMain),
                    ),
                  ],
                ),
                CustomBadge(
                  text: item.trangThai,
                  textColor: item.trangThai == 'Hoàn tất' ? AppColors.success : AppColors.warning,
                  backgroundColor: item.trangThai == 'Hoàn tất' ? AppColors.successBg : AppColors.warningBg,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // 1. Modal Tùy chọn Tạo phiếu kho
  void _showCreateTransactionOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tạo Phiếu Kho Mới', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            const SizedBox(height: 14),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFF0FDF4), shape: BoxShape.circle),
                child: const Icon(Icons.auto_awesome_rounded, color: Color(0xFF16A34A)),
              ),
              title: const Text('Xuất kho theo FEFO', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Tự động chọn lô cận hạn dùng nhất xuất trước'),
              onTap: () {
                Navigator.pop(ctx);
                FefoExportDialog.show(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFEFF6FF), shape: BoxShape.circle),
                child: const Icon(Icons.inventory_2_outlined, color: Color(0xFF2563EB)),
              ),
              title: const Text('Nhập kho theo Đơn PO', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Đối soát số lượng và ghi nhận số lô, HSD'),
              onTap: () {
                Navigator.pop(ctx);
                PoImportDialog.show(context);
              },
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(color: Color(0xFFFFF7ED), shape: BoxShape.circle),
                child: const Icon(Icons.fact_check_outlined, color: Color(0xFFEA580C)),
              ),
              title: const Text('Lập phiếu Kiểm kê kho', style: TextStyle(fontWeight: FontWeight.w600)),
              subtitle: const Text('Cân bằng số lượng thực tế và sổ sách'),
              onTap: () {
                Navigator.pop(ctx);
                InventoryAuditDialog.show(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  // 2. Modal Chi tiết phiếu giao dịch
  void _showTransactionDetails(TransactionItem item) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(color: Colors.grey.shade300, borderRadius: BorderRadius.circular(2)),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.maPhieu, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textMain)),
                    const SizedBox(height: 2),
                    Text(item.diaDiemHoacNcc, style: const TextStyle(fontSize: 13, color: AppColors.textSub)),
                  ],
                ),
                CustomBadge(
                  text: item.trangThai,
                  textColor: item.trangThai == 'Hoàn tất' ? AppColors.success : AppColors.warning,
                  backgroundColor: item.trangThai == 'Hoàn tất' ? AppColors.successBg : AppColors.warningBg,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            const Text('THÔNG TIN GIAO DỊCH:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Text('• Loại phiếu: ${item.loaiGiaoDich}'),
            Text('• Thời gian thực hiện: ${item.thoiGian}'),
            Text('• Quy mô: ${item.soLuongMatHang} mặt hàng'),
            Text('• Tổng giá trị: ${item.tongGiaTri}', style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primary)),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.print_outlined, size: 16),
                    label: const Text('In phiếu'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đang chuẩn bị file in cho phiếu ${item.maPhieu}...')),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    icon: const Icon(Icons.share_outlined, size: 16),
                    label: const Text('Chia sẻ'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã sao chép mã phiếu ${item.maPhieu}')),
                      );
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  // 3. Modal Bộ lọc nâng cao
  void _showAdvancedFilter() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Bộ lọc nâng cao Giao dịch', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.filter_alt_outlined, color: AppColors.primary),
              title: const Text('Lọc theo Kho nguồn (Kho mát, Kho đông, Kho khô)'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _selectedType = 'Tất cả');
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_outline_rounded, color: AppColors.primary),
              title: const Text('Lọc theo Nhân viên thực hiện'),
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

