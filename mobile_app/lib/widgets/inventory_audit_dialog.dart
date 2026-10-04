import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class InventoryAuditDialog {
  static void show(BuildContext context) {
    String selectedKho = 'Kho mát';
    final items = [
      {'name': 'Cá hồi phi lê (TP-CH-001)', 'book': 4.0, 'actual': 3.5, 'unit': 'kg', 'diff': -0.5},
      {'name': 'Sữa tươi nguyên kem (SU-TU-014)', 'book': 18.0, 'actual': 18.0, 'unit': 'hộp', 'diff': 0.0},
      {'name': 'Dầu ô liu Extra Virgin (DK-OL-003)', 'book': 6.0, 'actual': 7.0, 'unit': 'chai', 'diff': 1.0},
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.fact_check_outlined, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text('Lập Phiếu Kiểm Kê Kho', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Khu vực kiểm kê:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedKho,
                      items: ['Kho mát', 'Kho đông', 'Kho khô', 'Bếp chính'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedKho = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                const Text('Đối soát số lượng Sổ sách vs Thực tế:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                const SizedBox(height: 8),

                ...items.map((item) {
                  final diff = (item['diff'] as double);
                  final isLoss = diff < 0;
                  final isMatch = diff == 0;

                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                        const SizedBox(height: 4),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('Sổ sách: ${item['book']} ${item['unit']}', style: const TextStyle(fontSize: 11, color: AppColors.textSub)),
                            Row(
                              children: [
                                Text('Thực tế: ${item['actual']} ${item['unit']}  ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: isMatch ? const Color(0xFFECFDF5) : (isLoss ? const Color(0xFFFEF2F2) : const Color(0xFFEFF6FF)),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isMatch ? 'Khớp' : '${diff > 0 ? '+' : ''}$diff ${item['unit']}',
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.bold,
                                      color: isMatch ? const Color(0xFF10B981) : (isLoss ? const Color(0xFFEF4444) : const Color(0xFF3B82F6)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                }),
                const SizedBox(height: 8),

                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFBEB),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFFDE68A)),
                  ),
                  child: const Text(
                    'Lưu ý: Sau khi Quản lý duyệt phiếu này, hệ thống sẽ tự động điều chỉnh số tồn tức thời (bút toán DIEU_CHINH) để cân bằng kho.',
                    style: TextStyle(fontSize: 11, color: Color(0xFFB45309)),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Hủy', style: TextStyle(color: AppColors.textSub)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white),
              onPressed: () async {
                Navigator.pop(ctx);

                await ApiService.createKiemKe(
                  maKho: selectedKho == 'Kho mát' ? 1 : 2,
                  chiTiet: [
                    {'MaHangHoa': 1, 'SoLuongThucTe': 3.5, 'LyDoChenhLech': 'Hao hụt rã đông'},
                    {'MaHangHoa': 2, 'SoLuongThucTe': 18.0, 'LyDoChenhLech': 'Khớp tồn'},
                    {'MaHangHoa': 3, 'SoLuongThucTe': 7.0, 'LyDoChenhLech': 'Thừa do chưa ghi nhận xuất'},
                  ],
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã lập thành công Biên bản kiểm kê kho $selectedKho và gửi Quản lý phê duyệt!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Gửi phê duyệt'),
            ),
          ],
        ),
      ),
    );
  }
}
