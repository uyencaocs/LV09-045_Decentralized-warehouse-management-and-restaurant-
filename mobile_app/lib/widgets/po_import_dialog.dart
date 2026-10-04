import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class PoImportDialog {
  static void show(BuildContext context) {
    String selectedPO = 'PO-260924-031 (Công ty Thực Phẩm Xanh)';
    String selectedKho = 'Kho mát';
    final lotController = TextEditingController(text: 'LOT-260927-VN');
    final expiryController = TextEditingController(text: '30/10/2026');
    final tempController = TextEditingController(text: '2 - 4 °C');
    final qtyController = TextEditingController(text: '18');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.inventory_2_outlined, color: AppColors.primary, size: 22),
              SizedBox(width: 8),
              Expanded(
                child: Text('Nhập kho theo Đơn PO', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Chọn đơn mua hàng (PO):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedPO,
                      items: [
                        'PO-260924-031 (Công ty Thực Phẩm Xanh)',
                        'PO-260924-030 (Hải Sản Minh Phú)',
                        'PO-260923-029 (Nông Trại Đà Lạt)',
                      ].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 12)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedPO = val);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),

                const Text('Kho tiếp nhận:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.border)),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      isExpanded: true,
                      value: selectedKho,
                      items: ['Kho mát', 'Kho đông', 'Kho khô'].map((e) => DropdownMenuItem(value: e, child: Text(e, style: const TextStyle(fontSize: 13)))).toList(),
                      onChanged: (val) {
                        if (val != null) setState(() => selectedKho = val);
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
                          const Text('Số lượng nhận:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: qtyController,
                            keyboardType: TextInputType.number,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                          const Text('Mã Số Lô (LOT):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: lotController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Hạn sử dụng (HSD):', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: expiryController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
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
                          const Text('Nhiệt độ bảo quản:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSub)),
                          const SizedBox(height: 6),
                          TextField(
                            controller: tempController,
                            decoration: InputDecoration(
                              contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
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

                await ApiService.nhapKhoPO(
                  maDonMua: 1,
                  maKho: selectedKho == 'Kho mát' ? 1 : 2,
                  chiTiet: [
                    {
                      'MaHangHoa': 1,
                      'SoLuongThucNhan': double.tryParse(qtyController.text) ?? 10.0,
                      'DonGia': 250000,
                      'SoLo': lotController.text,
                      'HanSuDung': DateTime.now().add(const Duration(days: 30)).toIso8601String(),
                      'NhietDoBaoQuan': tempController.text,
                    }
                  ],
                );

                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã đối soát và nhập kho thành công từ đơn $selectedPO!'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
              child: const Text('Nhập kho'),
            ),
          ],
        ),
      ),
    );
  }
}
