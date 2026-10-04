class PurchaseOrderItem {
  final String maDon;
  final String tenNhaCungCap;
  final String ngayGiao;
  final int soMatHang;
  final String nguoiTao;
  final String tongTien;
  final String trangThai; // "Đã xác nhận", "Chờ duyệt", "Đang giao", "Hoàn thành", "Đã hủy"

  PurchaseOrderItem({
    required this.maDon,
    required this.tenNhaCungCap,
    required this.ngayGiao,
    required this.soMatHang,
    required this.nguoiTao,
    required this.tongTien,
    required this.trangThai,
  });
}
