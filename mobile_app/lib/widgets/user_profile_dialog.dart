import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../screens/login_screen.dart';
import '../theme/app_colors.dart';
import '../widgets/audit_logs_dialog.dart';

class UserProfileDialog {
  static void show(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final role = auth.viTri.isNotEmpty ? auth.viTri : 'Nhân viên kho';
    final name = auth.hoTen.isNotEmpty ? auth.hoTen : 'Nguyễn Trường Duy';

    // Hạn mức phê duyệt theo CSDL Backend
    String approvalLimit;
    switch (role) {
      case 'Admin':
        approvalLimit = '999.999.999 VNĐ (Toàn quyền)';
        break;
      case 'Quản lý':
        approvalLimit = '50.000.000 VNĐ';
        break;
      case 'Kế toán':
        approvalLimit = '20.000.000 VNĐ';
        break;
      case 'Bếp trưởng':
        approvalLimit = '10.000.000 VNĐ';
        break;
      default:
        approvalLimit = '0 VNĐ (Chỉ tạo đề xuất, không phê duyệt)';
    }

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: AppColors.primary,
              child: Text(
                name.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join('').toUpperCase(),
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  Text(role, style: const TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(),
            const SizedBox(height: 6),
            const Text('HẠN MỨC PHÊ DUYỆT (RBAC):', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            Text(approvalLimit, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Color(0xFF0F172A))),
            const SizedBox(height: 12),
            const Text('PHẠM VI TRÁCH NHIỆM:', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: AppColors.textMuted)),
            const SizedBox(height: 2),
            const Text('Kho Nhà hàng An Nhiên · Bếp chính & Kho bảo quản', style: TextStyle(fontSize: 13, color: AppColors.textSub)),
            const SizedBox(height: 16),
            const Divider(),

            // Nút Xem nhật ký kiểm toán hệ thống
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.history_rounded, color: AppColors.primary),
              title: const Text('Nhật ký kiểm toán (Audit Logs)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                AuditLogsDialog.show(context);
              },
            ),

            // Nút Đổi tài khoản nhanh (Switch Role Demo)
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.swap_horizontal_circle_outlined, color: Color(0xFF0D9488)),
              title: const Text('Đổi tài khoản nhanh (Demo RBAC)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
              onTap: () {
                Navigator.pop(ctx);
                _showSwitchRoleDialog(context);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Đóng'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            icon: const Icon(Icons.logout_rounded, size: 16),
            label: const Text('Đăng xuất'),
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pop(ctx);
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  static void _showSwitchRoleDialog(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final demoUsers = [
      {'user': 'admin_duy', 'name': 'Cao Thị Thu Uyên', 'role': 'Admin', 'limit': '999 tr'},
      {'user': 'quanly_lan', 'name': 'Phan Ngọc Quỳnh Hương', 'role': 'Quản lý', 'limit': '50 tr'},
      {'user': 'beptruong_hung', 'name': 'Nguyễn Thành Trung', 'role': 'Bếp trưởng', 'limit': '10 tr'},
      {'user': 'nvkho_tuan', 'name': 'Nguyễn Trường Duy', 'role': 'Nhân viên kho', 'limit': '0 đ'},
      {'user': 'ketoan_an', 'name': 'Lê Hoàng An', 'role': 'Kế toán', 'limit': '20 tr'},
    ];

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Chọn tài khoản chuyển đổi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: demoUsers.map((u) {
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primaryLight,
                child: Text(u['role']![0], style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
              ),
              title: Text(u['name']!, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
              subtitle: Text('${u['role']} · Hạn mức: ${u['limit']}', style: const TextStyle(fontSize: 12)),
              onTap: () async {
                Navigator.pop(ctx);
                await auth.login(u['user']!, '123456');
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Đã chuyển sang tài khoản ${u['name']} (${u['role']})'),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Hủy')),
        ],
      ),
    );
  }
}
