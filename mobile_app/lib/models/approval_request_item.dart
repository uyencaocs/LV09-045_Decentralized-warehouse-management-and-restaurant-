enum ApprovalType {
  donMua,        // PO - Đơn mua hàng
  nhapKho,       // NK - Phiếu nhập kho
  dieuChuyen,    // DC - Điều chuyển kho
  kiemKe,        // ADJ - Điều chỉnh kiểm kê
}

class ApprovalRequestItem {
  final String maPhieu;
  final String tieuDe;
  final String chiTiet;
  final String giaTri;
  final bool isNegative;
  final String mucDo; // "Khẩn", "Bình thường"
  final ApprovalType loaiPhieu;
  String trangThai; // "Chờ duyệt", "Đã duyệt", "Đã từ chối"

  ApprovalRequestItem({
    required this.maPhieu,
    required this.tieuDe,
    required this.chiTiet,
    required this.giaTri,
    this.isNegative = false,
    required this.mucDo,
    required this.loaiPhieu,
    this.trangThai = 'Chờ duyệt',
  });
}
