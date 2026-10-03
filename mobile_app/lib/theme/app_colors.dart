import 'package:flutter/material.dart';

class AppColors {
  // Primary Teal - Nhận diện thương hiệu "Bếp Kho" sang trọng & chuyên nghiệp
  static const Color primary = Color(0xFF0F5A67);       // Teal đậm chiều sâu
  static const Color primaryHover = Color(0xFF136E7D);
  static const Color primaryDark = Color(0xFF0A3E47);
  static const Color primaryLight = Color(0xFFE6F4F6);  // Nền nhạt cho chip/icon
  static const Color primarySurface = Color(0xFFF0F9FA);
  static const Color secondaryTeal = Color(0xFF2DD4BF); // Accent highlight

  // Gradients thương hiệu
  static const LinearGradient primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF0F5A67), Color(0xFF1E8294)],
  );

  static const LinearGradient cardAccentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFF8FAFC), Color(0xFFF1F5F9)],
  );

  // Nền & Khung
  static const Color background = Color(0xFFF8FAFC);    // Nền xám nhạt toàn app
  static const Color cardBg = Colors.white;             // Nền các thẻ trắng
  static const Color sidebarBg = Color(0xFF0A192F);     // Sidebar nền tối phong cách Enterprise cho Tablet/Desktop
  static const Color border = Color(0xFFE2E8F0);        // Viền thẻ sắc nét
  static const Color borderLight = Color(0xFFF1F5F9);
  static const Color divider = Color(0xFFE2E8F0);

  // Text Colors
  static const Color textMain = Color(0xFF0F172A);      // Chữ đen đậm tiêu đề
  static const Color textBody = Color(0xFF334155);      // Chữ nội dung
  static const Color textSub = Color(0xFF64748B);       // Chữ mô tả xám
  static const Color textMuted = Color(0xFF94A3B8);     // Chữ phụ / ngày giờ

  // Trạng thái & Cảnh báo chuẩn Design System
  static const Color success = Color(0xFF10B981);       // Xanh lá (Ổn định, Hoàn tất)
  static const Color successBg = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFF59E0B);       // Vàng cam (Cần chú ý, Cận hạn)
  static const Color warningBg = Color(0xFFFFFBEB);
  static const Color danger = Color(0xFFEF4444);        // Đỏ (Rủi ro, Tồn thấp, Khẩn)
  static const Color dangerBg = Color(0xFFFEF2F2);
  static const Color infoBlue = Color(0xFF3B82F6);      // Xanh dương (Phiếu chờ duyệt)
  static const Color infoBlueBg = Color(0xFFEFF6FF);

  // Badge đếm phê duyệt
  static const Color badgeOrange = Color(0xFFF97316);   // Badge số 5 ở Bottom Bar

  // Đổ bóng (Box Shadows) chuẩn UI hiện đại
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.04),
      blurRadius: 10,
      offset: const Offset(0, 3),
    ),
    BoxShadow(
      color: const Color(0xFF0F172A).withValues(alpha: 0.02),
      blurRadius: 3,
      offset: const Offset(0, 1),
    ),
  ];

  static List<BoxShadow> get hoverShadow => [
    BoxShadow(
      color: const Color(0xFF0F5A67).withValues(alpha: 0.12),
      blurRadius: 16,
      offset: const Offset(0, 6),
    ),
  ];
}
