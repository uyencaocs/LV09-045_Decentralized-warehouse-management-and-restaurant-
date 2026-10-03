import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/api_constants.dart';
import '../models/api_response.dart';

class ApiService {
  static Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  static Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. TỒN KHO & HÀNG HÓA
  static Future<ApiResponse<dynamic>> getTonKhoSummary() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(ApiConstants.tonKho), headers: headers)
          .timeout(const Duration(seconds: 4));
      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Lỗi kết nối Backend: $e');
    }
  }

  static Future<ApiResponse<dynamic>> getHangHoaList() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(ApiConstants.hangHoa), headers: headers)
          .timeout(const Duration(seconds: 4));
      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Lỗi kết nối Backend: $e');
    }
  }

  // 2. GIAO DỊCH KHO (FEFO & NHẬP PO)
  static Future<ApiResponse<dynamic>> xuatKhoFEFO({
    required int maHangHoa,
    required int maKhoXuat,
    required double soLuongXuat,
    String? ghiChu,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'MaHangHoa': maHangHoa,
        'MaKhoXuat': maKhoXuat,
        'SoLuongXuat': soLuongXuat,
        'GhiChu': ghiChu ?? 'Xuất kho phục vụ Bếp chính (FEFO)',
      });

      final res = await http.post(
        Uri.parse(ApiConstants.xuatKhoFefo),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 5));

      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Không thể kết nối Backend: $e');
    }
  }

  static Future<ApiResponse<dynamic>> nhapKhoPO({
    required int maDonMua,
    required int maKho,
    required List<Map<String, dynamic>> chiTiet,
    String? ghiChu,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'MaDonMua': maDonMua,
        'MaKho': maKho,
        'GhiChu': ghiChu ?? 'Nhập kho đối soát theo PO',
        'ChiTiet': chiTiet,
      });

      final res = await http.post(
        Uri.parse(ApiConstants.nhapKhoPo),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 5));

      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Không thể kết nối Backend: $e');
    }
  }

  // 3. ĐƠN MUA HÀNG (PO)
  static Future<ApiResponse<dynamic>> getAllDonMuaHang() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(ApiConstants.donMuaHang), headers: headers)
          .timeout(const Duration(seconds: 4));
      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Lỗi kết nối Backend: $e');
    }
  }

  static Future<ApiResponse<dynamic>> createDonMuaHang({
    required int maNhaCungCap,
    required DateTime ngayGiaoDuKien,
    required List<Map<String, dynamic>> chiTiet,
    String? ghiChu,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'MaNhaCungCap': maNhaCungCap,
        'NgayGiaoDuKien': ngayGiaoDuKien.toIso8601String(),
        'GhiChu': ghiChu,
        'ChiTiet': chiTiet,
      });

      final res = await http.post(
        Uri.parse(ApiConstants.donMuaHang),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 5));

      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Không thể kết nối Backend: $e');
    }
  }

  static Future<ApiResponse<dynamic>> approveDonMuaHang(int poId) async {
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse('${ApiConstants.donMuaHang}/$poId/pheduyet'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Không thể kết nối Backend: $e');
    }
  }

  // 4. KIỂM KÊ KHO
  static Future<ApiResponse<dynamic>> getAllKiemKe() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse(ApiConstants.kiemKe), headers: headers)
          .timeout(const Duration(seconds: 4));
      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Lỗi kết nối Backend: $e');
    }
  }

  static Future<ApiResponse<dynamic>> createKiemKe({
    required int maKho,
    required List<Map<String, dynamic>> chiTiet,
    String? ghiChu,
  }) async {
    try {
      final headers = await _getHeaders();
      final body = jsonEncode({
        'MaKho': maKho,
        'GhiChu': ghiChu ?? 'Kiểm kê định kỳ nhà hàng',
        'ChiTiet': chiTiet,
      });

      final res = await http.post(
        Uri.parse(ApiConstants.kiemKe),
        headers: headers,
        body: body,
      ).timeout(const Duration(seconds: 5));

      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Không thể kết nối Backend: $e');
    }
  }

  static Future<ApiResponse<dynamic>> approveKiemKe(int kiemKeId) async {
    try {
      final headers = await _getHeaders();
      final res = await http.put(
        Uri.parse('${ApiConstants.kiemKe}/$kiemKeId/pheduyet'),
        headers: headers,
      ).timeout(const Duration(seconds: 5));

      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Không thể kết nối Backend: $e');
    }
  }

  // 5. NHẬT KÝ KIỂM TOÁN (AUDIT LOGS)
  static Future<ApiResponse<dynamic>> getAuditLogs({int pageIndex = 1, int pageSize = 50}) async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(
        Uri.parse('${ApiConstants.auditLog}?pageIndex=$pageIndex&pageSize=$pageSize'),
        headers: headers,
      ).timeout(const Duration(seconds: 4));

      final dynamic data = jsonDecode(res.body);
      return ApiResponse.fromJson(data, null);
    } catch (e) {
      return ApiResponse(success: false, message: 'Lỗi kết nối Backend: $e');
    }
  }
}
