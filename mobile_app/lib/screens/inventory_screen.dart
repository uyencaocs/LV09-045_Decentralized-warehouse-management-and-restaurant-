import 'package:flutter/material.dart';
import '../models/hang_hoa_item.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/custom_badge.dart';
import '../widgets/fefo_export_dialog.dart';
import '../widgets/inventory_audit_dialog.dart';
import '../widgets/notifications_dialog.dart';
import '../widgets/po_import_dialog.dart';
import '../widgets/responsive_layout.dart';
import '../widgets/user_profile_dialog.dart';

class InventoryScreen extends StatefulWidget {
  final VoidCallback onBackToDashboard;

  const InventoryScreen({super.key, required this.onBackToDashboard});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'Tất cả';
  String _selectedWarehouse = 'Tất cả';

  // Danh sách dữ liệu mẫu chuẩn nghiệp vụ nhà hàng (Không lộ ID kỹ thuật CSDL)
  final List<HangHoaItem> _items = [
    HangHoaItem(
      sku: 'TP - CH - 001',
      tenHangHoa: 'Cá hồi phi lê',
      danhMuc: 'Thực phẩm tươi',
      kho: 'Bếp chính',
      tonHienTai: 4,
      tonToiThieu: 10,
      donViTinh: 'kg',
      soLo: 'LOT - 240918',
      hanSuDung: '28/09/2026',
      trangThai: 'Tồn thấp',
      isWarning: true,
      isDanger: true,
    ),
    HangHoaItem(
      sku: 'SU - TU - 014',
      tenHangHoa: 'Sữa tươi nguyên kem',
      danhMuc: 'Sữa & chế phẩm',
      kho: 'Kho mát',
      tonHienTai: 18,
      tonToiThieu: 12,
      donViTinh: 'hộp',
      soLo: 'LOT - 240921',
      hanSuDung: '28/09/2026',
      trangThai: 'Sắp hết hạn',
      isWarning: true,
      isDanger: false,
    ),
    HangHoaItem(
      sku: 'DK - OL - 003',
      tenHangHoa: 'Dầu ô liu Extra Virgin',
      danhMuc: 'Đồ khô/Gia vị',
      kho: 'Kho khô',
      tonHienTai: 6,
      tonToiThieu: 15,
      donViTinh: 'chai',
      soLo: 'LOT - 240810',
      hanSuDung: '15/12/2026',
      trangThai: 'Tồn thấp',
      isWarning: true,
      isDanger: true,
    ),
    HangHoaItem(
      sku: 'TC - BO - 002',
      tenHangHoa: 'Thịt bò bít tết Úc',
      danhMuc: 'Thịt cá',
      kho: 'Kho đông',
      tonHienTai: 24,
      tonToiThieu: 10,
      donViTinh: 'kg',
      soLo: 'LOT - 240915',
      hanSuDung: '10/11/2026',
      trangThai: 'Bình thường',
      isWarning: false,
      isDanger: false,
    ),
    HangHoaItem(
      sku: 'RC - CA - 005',
      tenHangHoa: 'Cà rốt Đà Lạt hữu cơ',
      danhMuc: 'Rau củ',
      kho: 'Bếp chính',
      tonHienTai: 35,
      tonToiThieu: 10,
      donViTinh: 'kg',
      soLo: 'LOT - 240923',
      hanSuDung: '05/10/2026',
      trangThai: 'Bình thường',
      isWarning: false,
      isDanger: false,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          child: AdaptivePageContainer(
            padding: EdgeInsets.symmetric(horizontal: ResponsiveLayout.isMobile(context) ? 16 : 24, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. TOP HEADER (Bếp Kho + Nút Nhập Kho + Bell + Avatar)
                _buildTopHeader(context),
                const SizedBox(height: 16),

                // 2. TIÊU ĐỀ TRANG
                Text('Tra cứu tồn kho', style: AppTextStyles.pageTitle),
                const SizedBox(height: 4),
                Text(
                  'Theo dõi số lượng, lô hàng, hạn sử dụng và mức tồn tối thiểu.',
                  style: AppTextStyles.cardHeaderSub.copyWith(fontSize: 13),
                ),
                const SizedBox(height: 16),

                // 3. THANH TÌM KIẾM & BỘ LỌC
                _buildSearchAndFilters(),
                const SizedBox(height: 20),

                // 4. TIÊU ĐỀ DANH SÁCH & NÚT THAO TÁC XUẤT EXCEL / TÙY CHỈNH
                _buildListHeader(),
                const SizedBox(height: 12),

                // 5. DANH SÁCH THẺ HÀNG HÓA (Adaptive Grid trên Desktop, List trên Mobile)
                if (ResponsiveLayout.isMobile(context))
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _items.length,
                    separatorBuilder: (_, _) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildItemCard(_items[index]);
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
                      mainAxisExtent: 175,
                    ),
                    itemCount: _items.length,
                    itemBuilder: (context, index) => _buildItemCard(_items[index]),
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
        // Nút Nhập kho
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            elevation: 0,
          ),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Nhập kho', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          onPressed: () => PoImportDialog.show(context),
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
          // Ô Input tìm kiếm
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Tìm SKU hoặc tên hàng...',
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

          // 2 Ô Dropdown: Danh mục & Kho
          Row(
            children: [
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Danh mục',
                  value: _selectedCategory,
                  items: ['Tất cả', 'Thực phẩm tươi', 'Sữa & chế phẩm', 'Đồ khô/Gia vị', 'Thịt cá', 'Rau củ'],
                  onChanged: (val) => setState(() => _selectedCategory = val!),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildDropdownFilter(
                  label: 'Kho',
                  value: _selectedWarehouse,
                  items: ['Tất cả', 'Bếp chính', 'Kho mát', 'Kho đông', 'Kho khô'],
                  onChanged: (val) => setState(() => _selectedWarehouse = val!),
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
            label: const Text('Bộ lọc nâng cao (HSD & Ngưỡng an toàn)', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
            onPressed: _showAdvancedFilter,
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownFilter({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isDense: true,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down_rounded, size: 18, color: AppColors.textSub),
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.textMain),
              items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, overflow: TextOverflow.ellipsis))).toList(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Danh sách hàng hóa', style: AppTextStyles.cardHeaderTitle),
                const SizedBox(height: 2),
                Text('${_items.length} SKU hiển thị · Đồng bộ CSDL PostgreSQL', style: AppTextStyles.cardHeaderSub),
              ],
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textBody,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.file_download_outlined, size: 16),
                label: const Text('Xuất Excel', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                onPressed: _exportExcel,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textBody,
                  backgroundColor: Colors.white,
                  side: const BorderSide(color: Color(0xFFCBD5E1)),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                ),
                icon: const Icon(Icons.view_column_outlined, size: 16),
                label: const Text('Tùy chỉnh cột', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                onPressed: _customizeColumns,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildItemCard(HangHoaItem item) {
    return InkWell(
      onTap: () => _showItemDetails(item),
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
            // Dòng 1: Mã SKU & Badge cảnh báo
            Row(
              children: [
                Text(
                  item.sku,
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textMuted,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                if (item.trangThai == 'Tồn thấp')
                  const CustomBadge(
                    text: 'Tồn thấp',
                    textColor: AppColors.danger,
                    backgroundColor: AppColors.dangerBg,
                  )
                else if (item.trangThai == 'Sắp hết hạn')
                  const CustomBadge(
                    text: 'Sắp hết hạn',
                    textColor: AppColors.warning,
                    backgroundColor: AppColors.warningBg,
                  ),
                const SizedBox(width: 4),
                IconButton(
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  icon: const Icon(Icons.more_vert, size: 18, color: AppColors.textMuted),
                  onPressed: () => _showItemDetails(item),
                ),
              ],
            ),
            const SizedBox(height: 6),

            // Dòng 2: Tên mặt hàng
            Text(item.tenHangHoa, style: AppTextStyles.itemTitle.copyWith(fontSize: 16)),
            const SizedBox(height: 8),

            // Dòng 3: Chip danh mục & kho
            Row(
              children: [
                _buildTagChip(item.danhMuc),
                const SizedBox(width: 6),
                const Text('·', style: TextStyle(color: AppColors.textMuted, fontWeight: FontWeight.bold)),
                const SizedBox(width: 6),
                _buildTagChip(item.kho),
              ],
            ),
            const Divider(height: 18, color: AppColors.divider),

            // Dòng 4: Tồn kho & Lô/HSD
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    style: const TextStyle(fontSize: 13, color: AppColors.textSub),
                    children: [
                      const TextSpan(text: 'Tồn: '),
                      TextSpan(
                        text: '${item.tonHienTai} ${item.donViTinh}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: item.isDanger ? AppColors.danger : AppColors.textMain,
                        ),
                      ),
                      TextSpan(
                        text: ' (Tối thiểu: ${item.tonToiThieu} ${item.donViTinh})',
                        style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                      ),
                    ],
                  ),
                ),

                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      item.soLo,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.textSub),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'HSD: ${item.hanSuDung}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: item.trangThai == 'Sắp hết hạn' ? AppColors.warning : AppColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTagChip(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 11, color: AppColors.textSub, fontWeight: FontWeight.w500),
      ),
    );
  }

  // 1. Modal Chi tiết mặt hàng & Lô hàng FEFO
  void _showItemDetails(HangHoaItem item) {
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
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.sku, style: const TextStyle(fontFamily: 'monospace', color: AppColors.textMuted, fontSize: 12)),
                      const SizedBox(height: 2),
                      Text(item.tenHangHoa, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.textMain)),
                    ],
                  ),
                ),
                if (item.trangThai == 'Tồn thấp')
                  const CustomBadge(text: 'Tồn thấp', textColor: AppColors.danger, backgroundColor: AppColors.dangerBg)
                else if (item.trangThai == 'Sắp hết hạn')
                  const CustomBadge(text: 'Sắp hết hạn', textColor: AppColors.warning, backgroundColor: AppColors.warningBg),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 10),

            const Text('THÔNG TIN LƯU KHO & ĐỊNH MỨC:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            const SizedBox(height: 6),
            Text('• Danh mục: ${item.danhMuc} · Kho lưu trữ: ${item.kho}'),
            Text('• Tồn hiện tại: ${item.tonHienTai} ${item.donViTinh} (Định mức tối thiểu: ${item.tonToiThieu} ${item.donViTinh})'),
            Text('• Lô hàng ưu tiên FEFO: ${item.soLo} (Hạn dùng: ${item.hanSuDung})'),
            const SizedBox(height: 16),

            // Các nút thao tác nghiệp vụ
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
                    icon: const Icon(Icons.auto_awesome_rounded, size: 16),
                    label: const Text('Xuất FEFO'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      FefoExportDialog.show(context, defaultItemName: '${item.tenHangHoa} (${item.sku})');
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.fact_check_outlined, size: 16),
                    label: const Text('Kiểm kê'),
                    onPressed: () {
                      Navigator.pop(ctx);
                      InventoryAuditDialog.show(context);
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

  // 2. Modal Bộ lọc nâng cao
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
            const Text('Bộ lọc nâng cao Tồn kho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 14),
            ListTile(
              leading: const Icon(Icons.warning_amber_rounded, color: AppColors.danger),
              title: const Text('Chỉ hiện mặt hàng Dưới mức tối thiểu'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _items.retainWhere((i) => i.isDanger));
              },
            ),
            ListTile(
              leading: const Icon(Icons.schedule_rounded, color: AppColors.warning),
              title: const Text('Chỉ hiện lô hàng Sắp hết hạn (FEFO ≤ 7 ngày)'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() => _items.retainWhere((i) => i.trangThai == 'Sắp hết hạn'));
              },
            ),
            ListTile(
              leading: const Icon(Icons.restart_alt_rounded, color: AppColors.primary),
              title: const Text('Đặt lại tất cả bộ lọc'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {});
              },
            ),
          ],
        ),
      ),
    );
  }

  // 3. Xuất file Excel
  void _exportExcel() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Xuất báo cáo Tồn kho', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Text('Xác nhận xuất danh sách ${_items.length} mặt hàng ra định dạng Microsoft Excel (.xlsx)?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
            onPressed: () {
              Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xuất thành công file "Bao_Cao_Ton_Kho_2026.xlsx"!'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Tải về'),
          ),
        ],
      ),
    );
  }

  // 4. Tùy chỉnh cột
  void _customizeColumns() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        title: const Text('Tùy chỉnh cột hiển thị', style: TextStyle(fontWeight: FontWeight.bold)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CheckboxListTile(value: true, onChanged: null, title: Text('Mã SKU & Tên hàng')),
            CheckboxListTile(value: true, onChanged: null, title: Text('Số lượng tồn & Đơn vị tính')),
            CheckboxListTile(value: true, onChanged: null, title: Text('Số Lô & Hạn sử dụng (HSD)')),
            CheckboxListTile(value: true, onChanged: null, title: Text('Kho lưu trữ & Định mức an toàn')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Đóng')),
        ],
      ),
    );
  }
}

