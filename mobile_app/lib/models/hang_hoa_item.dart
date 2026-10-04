class HangHoaItem {
  final String sku;
  final String tenHangHoa;
  final String danhMuc;
  final String kho;
  final double tonHienTai;
  final double tonToiThieu;
  final String donViTinh;
  final String soLo;
  final String hanSuDung;
  final String trangThai;
  final bool isWarning;
  final bool isDanger;

  HangHoaItem({
    required this.sku,
    required this.tenHangHoa,
    required this.danhMuc,
    required this.kho,
    required this.tonHienTai,
    required this.tonToiThieu,
    required this.donViTinh,
    required this.soLo,
    required this.hanSuDung,
    required this.trangThai,
    required this.isWarning,
    required this.isDanger,
  });
}
