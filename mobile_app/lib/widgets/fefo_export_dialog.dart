import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class FefoExportDialog {
  static void show(BuildContext context, {String? defaultItemName, String? defaultSku}) {
    final qtyController = TextEditingController(text: '2.5');
    final noteController = TextEditingController(text: 'Xuất nguyên liệu phục vụ Bếp chính ca trưa');
    String selectedItem = defaultItemName ?? 'Cá hồi phi lê (TP-CH-001)';
    String selectedSource = 'Kho mát';
    String selectedDest = 'Bếp chính';

    final items = [
      'Cá hồi phi lê (TP-CH-001)',
      'Sữa tươi nguyên kem (SU-TU-014)',
      'Dầu ô liu Extra Virgin (DK-OL-003)',
      'Thịt bò bít tết Úc (TC-BO-002)',
      'Cà rốt Đà Lạt hữu cơ (RC-CA-005)',
    ];

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.auto_awesome_rounded, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text('Xuất kho theo FEFO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Mặt hàng cần xuất:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.border),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedItem,
                      items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedItem = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Từ kho:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedSource,
                                items: ['Kho mát', 'Kho đông', 'Kho khô'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => selectedSource = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Đích đến:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedDest,
                                items: ['Bếp chính', 'Quầy bar', 'Bếp nướng'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                                onChanged: (val) {
                                  if (val != null) setState(() => selectedDest = val);
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                const Text('Số lượng xuất (kg/hộp/chai):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                const SizedBox(height: 6),
                TextField(
                  controller: qtyController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 12),

                // Giải thuật FEFO trực quan
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0FDF4),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xFFBBF7D0)),
                  ),
                  child: Row(
                    children: const [
                      Icon(Icons.check_circle_outline_rounded, color: Color(0xFF16A34A), size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Thuật toán FEFO: Tự động chọn lô LOT-240918 (HSD: 28/09/2026 cận nhất) để xuất trước.',
                          style: TextStyle(fontSize: 11, color: Color(0xFF15803D), fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Ghi chú điều chuyển:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                const SizedBox(height: 6),
                TextField(
                  controller: noteController,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                final qty = double.tryParse(qtyController.text) ?? 1.0;
                Navigator.pop(ctx);

                // Gọi API backend FEFO
                await ApiService.xuatKhoFEFO(
                  maHangHoa: 1,
                  maKhoXuat: selectedSource == 'Kho mát' ? 1 : 2,
                  soLuongXuat: qty,
                  ghiChu: noteController.text,
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Xuất kho thành công $qty đơn vị "$selectedItem" theo FEFO!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Xác nhận xuất'),
            ),
          ],
        ),
      ),
    );
  }
}
