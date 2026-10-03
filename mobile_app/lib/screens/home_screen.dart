import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../core/api_constants.dart';
import '../models/api_response.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoadingStock = false;
  List<dynamic> _stockItems = [];
  String? _stockError;

  @override
  void initState() {
    super.initState();
    _fetchStockSummary();
  }

  Future<void> _fetchStockSummary() async {
    final token = context.read<AuthProvider>().token;
    if (token == null) return;

    setState(() {
      _isLoadingStock = true;
      _stockError = null;
    });

    try {
      final res = await http.get(
        Uri.parse(ApiConstants.tonKho),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final apiRes = ApiResponse.fromJson(data, null);
        if (apiRes.success && apiRes.data is List) {
          setState(() {
            _stockItems = apiRes.data;
            _isLoadingStock = false;
          });
          return;
        }
      }
      setState(() {
        _stockError = 'Không thể tải dữ liệu tồn kho';
        _isLoadingStock = false;
      });
    } catch (e) {
      setState(() {
        _stockError = 'Lỗi kết nối: $e';
        _isLoadingStock = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('Tổng quan Kho Nhà Hàng'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới dữ liệu',
            onPressed: _fetchStockSummary,
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Đăng xuất',
            onPressed: () async {
              await auth.logout();
              if (context.mounted) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchStockSummary,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // User Info Card
              Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                        child: const Icon(Icons.person, color: Color(0xFF1E3A8A), size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              auth.hoTen.isNotEmpty ? auth.hoTen : 'Người dùng',
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: Colors.blue.shade200),
                              ),
                              child: Text(
                                'Vai trò: ${auth.viTri}',
                                style: TextStyle(fontSize: 12, color: Colors.blue.shade800, fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Chức năng thao tác nhanh
              const Text('Chức năng chính', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 12),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.4,
                children: [
                  _buildQuickAction(
                    icon: Icons.call_missed_outgoing,
                    title: 'Xuất kho FEFO',
                    color: Colors.orange,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng Xuất kho FEFO')),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.inventory_2,
                    title: 'Nhập theo PO',
                    color: Colors.teal,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng Nhập kho theo PO')),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.shopping_cart,
                    title: 'Đơn mua hàng',
                    color: Colors.indigo,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng Đơn mua hàng (PO)')),
                      );
                    },
                  ),
                  _buildQuickAction(
                    icon: Icons.fact_check,
                    title: 'Kiểm kê kho',
                    color: Colors.purple,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Tính năng Kiểm kê kho')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Bảng Tồn kho tức thời & Cảnh báo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Tồn kho tức thời', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  TextButton.icon(
                    icon: const Icon(Icons.refresh, size: 16),
                    label: const Text('Tải lại'),
                    onPressed: _fetchStockSummary,
                  )
                ],
              ),
              const SizedBox(height: 8),

              if (_isLoadingStock)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: CircularProgressIndicator(),
                  ),
                )
              else if (_stockError != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_stockError!, style: const TextStyle(color: Colors.red))),
                      ],
                    ),
                  ),
                )
              else if (_stockItems.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Chưa có dữ liệu tồn kho'),
                  ),
                )
              else
                ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _stockItems.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final item = _stockItems[index];
                    final isLowStock = item['IsDuoiNguyencAnToan'] ?? false;
                    final totalTon = item['TongSoLuongTon'] ?? 0;
                    final tonToiThieu = item['TonToiThieu'] ?? 0;
                    final donViTinh = item['DonViTinh'] ?? '';

                    return Card(
                      elevation: 1,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: isLowStock ? Colors.red.shade50 : Colors.green.shade50,
                          child: Icon(
                            isLowStock ? Icons.warning_amber_rounded : Icons.check_circle_outline,
                            color: isLowStock ? Colors.red : Colors.green,
                          ),
                        ),
                        title: Text(
                          item['TenHangHoa'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          'SKU: ${item['MaSKU']} | Tối thiểu: $tonToiThieu $donViTinh',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$totalTon $donViTinh',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.bold,
                                color: isLowStock ? Colors.red : Colors.black87,
                              ),
                            ),
                            if (isLowStock)
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: Colors.red.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: const Text(
                                  'Cảnh báo hết',
                                  style: TextStyle(fontSize: 10, color: Colors.red, fontWeight: FontWeight.bold),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: color.withValues(alpha: 0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
