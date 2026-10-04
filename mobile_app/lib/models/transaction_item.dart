class TransactionItem {
  final String maPhieu;
  final String loaiGiaoDich; // Nhập kho, Xuất kho, Điều chuyển, Đơn mua hàng PO
  final String diaDiemHoacNcc;
  final String thoiGian;
  final int soLuongMatHang;
  final String tongGiaTri;
  final String trangThai; // Hoàn tất, Chờ duyệt, Đang xử lý

  TransactionItem({
    required this.maPhieu,
    required this.loaiGiaoDich,
    required this.diaDiemHoacNcc,
    required this.thoiGian,
    required this.soLuongMatHang,
    required this.tongGiaTri,
    required this.trangThai,
  });
}
