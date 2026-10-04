import 'dart:io';
import 'package:flutter/foundation.dart';

class ApiConstants {
  static const int port = 5033;

  // Cấu hình URL kết nối tới Backend ASP.NET Core:
  // - Máy ảo Android Emulator: dùng 10.0.2.2 (ánh xạ tới localhost của máy tính)
  // - Web (Chrome) hoặc Windows: dùng localhost
  // - Điện thoại thật kết nối Wifi/USB: thay bằng IP mạng LAN máy tính (vd: http://192.168.1.5:5033/api)
  static String get baseUrl {
    if (kIsWeb) return 'http://localhost:$port/api';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:$port/api';
    } catch (_) {
      // Fallback
    }
    return 'http://localhost:$port/api';
  }

  // Endpoints
  static String get login => '$baseUrl/Auth/login';
  static String get me => '$baseUrl/Auth/me';
  static String get tonKho => '$baseUrl/HangHoa/tonkho';
  static String get hangHoa => '$baseUrl/HangHoa';
  static String get xuatKhoFefo => '$baseUrl/GiaoDichKho/xuat-fefo';
  static String get nhapKhoPo => '$baseUrl/GiaoDichKho/nhap-po';
  static String get donMuaHang => '$baseUrl/DonMuaHang';
  static String get kiemKe => '$baseUrl/KiemKe';
  static String get auditLog => '$baseUrl/AuditLog';
}
