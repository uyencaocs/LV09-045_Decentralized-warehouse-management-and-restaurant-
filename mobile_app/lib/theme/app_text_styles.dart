import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTextStyles {
  // Tiêu đề lớn "Tổng quan"
  static TextStyle pageTitle = GoogleFonts.inter(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    letterSpacing: -0.3,
  );

  // Brand Name "Bếp Kho"
  static TextStyle brandName = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );

  // Subtitle "Quản lý nhà hàng"
  static TextStyle brandSub = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSub,
  );

  // Tên thẻ "Nhập – xuất 7 ngày", "Sức khỏe tồn kho", "Cảnh báo cần xử lý"
  static TextStyle cardHeaderTitle = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
    letterSpacing: -0.2,
  );

  // Mô tả dưới tiêu đề thẻ "Đồng bộ theo thời gian thực", "Theo tổng số 326 SKU"
  static TextStyle cardHeaderSub = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSub,
  );

  // Số liệu lớn trong thẻ thống kê "486,2 tr", "18", "9 lô", "5"
  static TextStyle statNumber = GoogleFonts.inter(
    fontSize: 20,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );

  // Tiêu đề nhỏ thẻ thống kê "Giá trị tồn kho", "Mặt hàng tồn thấp"
  static TextStyle statTitle = GoogleFonts.inter(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    color: AppColors.textSub,
  );

  // Dòng phụ thẻ thống kê
  static TextStyle statSub = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w500,
  );

  // Tên hàng hóa / hoạt động trong danh sách
  static TextStyle itemTitle = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textMain,
  );

  // Chi tiết phụ trong item list
  static TextStyle itemSub = GoogleFonts.inter(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.textSub,
  );

  // Giá trị giao dịch "+ 12.450.000 đ", "– 3.280.000 đ"
  static TextStyle itemAmount = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: AppColors.textMain,
  );
}
