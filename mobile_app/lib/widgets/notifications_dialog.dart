import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../widgets/custom_badge.dart';

class NotificationsDialog extends StatelessWidget {
  const NotificationsDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const NotificationsDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final notifications = [
      {
        'title': 'Cảnh báo Tồn kho an toàn',
        'content': 'Cá hồi phi lê chỉ còn 4 kg (ngưỡng tối thiểu 10 kg). Đã tự động gửi thông báo Telegram đến Quản lý.',
        'time': '10 phút trước',
        'type': 'danger',
        'badge': 'Khẩn cấp',
      },
      {
        'title': 'Cảnh báo Hạn dùng FEFO',
        'content': 'Lô sữa tươi LOT-240921 sẽ hết hạn trong 5 ngày tới (28/09/2026). Đề xuất ưu tiên xuất trước.',
        'time': '45 phút trước',
        'type': 'warning',
        'badge': 'Cận hạn',
      },
      {
        'title': 'Yêu cầu phê duyệt Đơn mua',
        'content': 'Đơn mua hàng PO-260924-030 (18.920.000 đ) đang chờ Quản lý phê duyệt.',
        'time': '1 giờ trước',
        'type': 'info',
        'badge': 'Chờ duyệt',
      },
    ];

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
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
              Row(
                children: [
                  const Text('Thông báo hệ thống', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textMain)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(color: AppColors.danger, borderRadius: BorderRadius.circular(10)),
                    child: const Text('3 mới', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Đã đánh dấu đã đọc tất cả thông báo')),
                  );
                },
                child: const Text('Đọc tất cả', style: TextStyle(fontSize: 13, color: AppColors.primary, fontWeight: FontWeight.w600)),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Danh sách thông báo
          ...notifications.map((item) {
            Color iconBg;
            Color iconColor;
            IconData iconData;

            if (item['type'] == 'danger') {
              iconBg = AppColors.dangerBg;
              iconColor = AppColors.danger;
              iconData = Icons.warning_rounded;
            } else if (item['type'] == 'warning') {
              iconBg = AppColors.warningBg;
              iconColor = AppColors.warning;
              iconData = Icons.schedule_rounded;
            } else {
              iconBg = AppColors.infoBlueBg;
              iconColor = AppColors.infoBlue;
              iconData = Icons.assignment_outlined;
            }

            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
                    child: Icon(iconData, color: iconColor, size: 20),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(item['title']!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textMain)),
                            Text(item['time']!, style: const TextStyle(fontSize: 11, color: AppColors.textMuted)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(item['content']!, style: const TextStyle(fontSize: 12, color: AppColors.textSub, height: 1.3)),
                        const SizedBox(height: 6),
                        CustomBadge(
                          text: item['badge']!,
                          textColor: iconColor,
                          backgroundColor: iconBg,
                          fontSize: 10,
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: const Text('Đóng'),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
