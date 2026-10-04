import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../theme/app_colors.dart';

class AuditLogsDialog extends StatefulWidget {
  const AuditLogsDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const AuditLogsDialog(),
    );
  }

  @override
  State<AuditLogsDialog> createState() => _AuditLogsDialogState();
}

class _AuditLogsDialogState extends State<AuditLogsDialog> {
  bool _isLoading = true;
  List<dynamic> _logs = [];

  // Mẫu dữ liệu fallback
  final List<Map<String, dynamic>> _mockLogs = [
    {
      'MaNhatKy': 105,
      'TenNguoiDung': 'Nguyễn Trường Duy',
      'HanhDong': 'Xuất kho FEFO 12kg Cá hồi (Lô LOT-240918)',
      'BangTacDong': 'GiaoDichKho, LoHang',
      'ThoiGian': '24/09/2026 10:24',
    },
    {
      'MaNhatKy': 104,
      'TenNguoiDung': 'Phan Ngọc Quỳnh Hương',
      'HanhDong': 'Phê duyệt Đơn mua hàng PO-260924-030 (18.920.000 đ)',
      'BangTacDong': 'DonMuaHang, YeuCauDuyet',
      'ThoiGian': '24/09/2026 09:45',
    },
    {
      'MaNhatKy': 103,
      'TenNguoiDung': 'Nguyễn Thành Trung',
      'HanhDong': 'Tạo phiếu Điều chuyển DC-260924-010 (Kho mát ➔ Bếp chính)',
      'BangTacDong': 'GiaoDichKho',
      'ThoiGian': '24/09/2026 08:30',
    },
    {
      'MaNhatKy': 102,
      'TenNguoiDung': 'Cao Thị Thu Uyên',
      'HanhDong': 'Khởi tạo đợt Kiểm kê KK-0926 cân bằng tồn kho',
      'BangTacDong': 'KiemKeKho, TonKhoTucThoi',
      'ThoiGian': '23/09/2026 17:15',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadLogs();
  }

  Future<void> _loadLogs() async {
    final res = await ApiService.getAuditLogs();
    if (mounted) {
      setState(() {
        _isLoading = false;
        if (res.success && res.data != null && res.data['Items'] != null) {
          _logs = res.data['Items'];
        } else {
          _logs = _mockLogs;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
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
                children: const [
                  Text('Nhật ký kiểm toán', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  SizedBox(height: 2),
                  Text('Ghi vết lịch sử thao tác hệ thống (Audit Trail)', style: TextStyle(fontSize: 12, color: AppColors.textSub)),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.primary),
                onPressed: () {
                  setState(() => _isLoading = true);
                  _loadLogs();
                },
              ),
            ],
          ),
          const Divider(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView.separated(
                    itemCount: _logs.length,
                    separatorBuilder: (_, _) => const Divider(height: 16),
                    itemBuilder: (context, index) {
                      final log = _logs[index];
                      final name = log['TenNguoiDung'] ?? 'Hệ thống';
                      final action = log['HanhDong'] ?? '';
                      final time = log['ThoiGian']?.toString().substring(0, 16) ?? '';
                      final table = log['BangTacDong'] ?? '';

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.primaryLight,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.shield_outlined, color: AppColors.primary, size: 20),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(action, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13, color: AppColors.textMain)),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text('$name · ', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: AppColors.primary)),
                                    Text(time, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                                  ],
                                ),
                                if (table.toString().isNotEmpty) ...[
                                  const SizedBox(height: 2),
                                  Text('Bảng: $table', style: const TextStyle(fontSize: 10, color: AppColors.textMuted)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
