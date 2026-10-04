import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import 'dashboard_screen.dart';

class NfcUserCard {
  final String cardId;
  final String username;
  final String fullName;
  final String role;
  final String department;
  final Color cardColor;

  NfcUserCard({
    required this.cardId,
    required this.username,
    required this.fullName,
    required this.role,
    required this.department,
    required this.cardColor,
  });
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // Trạng thái bước xác thực: 1 = Quẹt thẻ NFC, 2 = Quét vân tay
  int _currentStep = 1;

  // Thẻ NFC đã nhận diện
  NfcUserCard? _detectedCard;

  // Trạng thái animation
  bool _isReadingNfc = false;
  bool _isScanningFingerprint = false;
  bool _fingerprintSuccess = false;

  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  // Danh sách thẻ nhân viên chuẩn hóa từ Database Model
  final List<NfcUserCard> _sampleCards = [
    NfcUserCard(
      cardId: 'NFC-KHO-11234',
      username: 'nvkho_tuan',
      fullName: 'Nguyễn Trường Duy',
      role: 'Nhân viên kho',
      department: 'Bộ phận Kho & Vận hành',
      cardColor: const Color(0xFF0D9488),
    ),
    NfcUserCard(
      cardId: 'NFC-BTR-88912',
      username: 'beptruong_hung',
      fullName: 'Nguyễn Thành Trung',
      role: 'Bếp trưởng',
      department: 'Bộ phận Bếp chính',
      cardColor: const Color(0xFFEA580C),
    ),
    NfcUserCard(
      cardId: 'NFC-QL-77890',
      username: 'quanly_lan',
      fullName: 'Phan Ngọc Quỳnh Hương',
      role: 'Quản lý',
      department: 'Ban Quản lý Nhà hàng',
      cardColor: const Color(0xFF4F46E5),
    ),
    NfcUserCard(
      cardId: 'NFC-ADM-99999',
      username: 'admin_duy',
      fullName: 'Cao Thị Thu Uyên',
      role: 'Admin',
      department: 'Hệ thống Quản trị Chuỗi',
      cardColor: AppColors.primary,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.94, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  // 1. Xử lý chạm thẻ NFC
  Future<void> _handleTapNfcCard(NfcUserCard card) async {
    setState(() {
      _isReadingNfc = true;
      _detectedCard = card;
    });

    // Mô phỏng thời gian đọc sóng vô tuyến NFC chip ISO/IEC 14443
    await Future.delayed(const Duration(milliseconds: 1000));

    if (!mounted) return;

    setState(() {
      _isReadingNfc = false;
      _currentStep = 2; // Tự động chuyển sang bước 2: Quét vân tay
    });
  }

  // 2. Xử lý quét vân tay xác thực chủ thẻ
  Future<void> _handleFingerprintAuth() async {
    if (_detectedCard == null) return;

    setState(() => _isScanningFingerprint = true);

    // Mô phỏng quét cảm biến vân tay sinh trắc học
    await Future.delayed(const Duration(milliseconds: 1200));

    if (!mounted) return;

    setState(() {
      _isScanningFingerprint = false;
      _fingerprintSuccess = true;
    });

    // Gọi đăng nhập hệ thống với tài khoản của thẻ đã xác minh
    final auth = context.read<AuthProvider>();
    await auth.login(_detectedCard!.username, '123456');

    await Future.delayed(const Duration(milliseconds: 400));
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Xác thực 2 bước thành công! Xin chào ${_detectedCard!.fullName} (${_detectedCard!.role}).'),
        backgroundColor: AppColors.success,
      ),
    );

    // Điều hướng vào màn hình Tổng quan
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const DashboardScreen()),
    );
  }

  // Quay lại quẹt thẻ khác
  void _resetToStep1() {
    setState(() {
      _currentStep = 1;
      _detectedCard = null;
      _fingerprintSuccess = false;
      _isScanningFingerprint = false;
      _isReadingNfc = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo thương hiệu Bếp Kho chuẩn Figma
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 14,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(Icons.restaurant_rounded, color: Colors.white, size: 34),
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text('Bếp Kho', style: AppTextStyles.brandName.copyWith(fontSize: 22)),
                  const SizedBox(height: 4),
                  Text(
                    'Xác thực đăng nhập không cần mật khẩu',
                    style: AppTextStyles.brandSub.copyWith(fontSize: 13),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),

                  // Thanh chỉ báo 2 bước (Stepper)
                  _buildStepIndicator(),
                  const SizedBox(height: 20),

                  // Khối nội dung chính tùy theo bước
                  Card(
                    elevation: 1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: const BorderSide(color: AppColors.border),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: _currentStep == 1 ? _buildStep1NfcView() : _buildStep2FingerprintView(),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Tiêu chuẩn bảo mật footer
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.security_rounded, size: 14, color: AppColors.textMuted),
                      const SizedBox(width: 6),
                      Text(
                        'Chuẩn xác thực 2 yếu tố: Thẻ thông minh NFC + Sinh trắc học',
                        style: AppTextStyles.cardHeaderSub.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Thanh tiến trình 2 bước
  Widget _buildStepIndicator() {
    return Row(
      children: [
        // Bước 1
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: _currentStep >= 1 ? AppColors.primary : const Color(0xFFCBD5E1),
                    child: const Text('1', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Chạm thẻ NFC',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _currentStep == 1 ? FontWeight.bold : FontWeight.w500,
                      color: _currentStep >= 1 ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: _currentStep >= 1 ? AppColors.primary : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Bước 2
        Expanded(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: _currentStep == 2 ? AppColors.primary : const Color(0xFFCBD5E1),
                    child: const Text('2', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Quét vân tay',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: _currentStep == 2 ? FontWeight.bold : FontWeight.w500,
                      color: _currentStep == 2 ? AppColors.primary : AppColors.textMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              Container(
                height: 3,
                decoration: BoxDecoration(
                  color: _currentStep == 2 ? AppColors.primary : const Color(0xFFE2E8F0),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ==================== BƯỚC 1: QUẸT THẺ NFC ====================
  Widget _buildStep1NfcView() {
    return Column(
      children: [
        Text('BƯỚC 1: CHẠM THẺ NHÂN VIÊN', style: AppTextStyles.cardHeaderTitle),
        const SizedBox(height: 4),
        Text('Áp thẻ thông minh vào mặt sau điện thoại để nhận diện', style: AppTextStyles.cardHeaderSub),
        const SizedBox(height: 24),

        // Hoạt ảnh quét sóng NFC
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isReadingNfc ? _pulseAnimation.value : 1.0,
              child: Container(
                width: 110,
                height: 74,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  gradient: const LinearGradient(
                    colors: [Color(0xFF136A7A), Color(0xFF1F8A9E)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Stack(
                  children: [
                    Positioned(
                      top: 10,
                      left: 12,
                      child: Icon(Icons.contactless_rounded, color: Colors.white70, size: 26),
                    ),
                    Positioned(
                      bottom: 10,
                      right: 12,
                      child: Text(
                        'STAFF PASS',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 16),

        Text(
          _isReadingNfc ? 'Đang đọc thẻ chip NFC...' : 'Đang chờ chạm thẻ nhân viên...',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _isReadingNfc ? AppColors.primary : AppColors.textSub,
          ),
        ),
        const SizedBox(height: 20),

        const Divider(height: 24, color: AppColors.divider),
        const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Chọn thẻ nhân viên để chạm vào máy:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textBody),
          ),
        ),
        const SizedBox(height: 10),

        // Danh sách thẻ nhân viên mẫu
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _sampleCards.length,
          separatorBuilder: (_, _) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final card = _sampleCards[index];
            return _buildNfcCardTile(card);
          },
        ),
      ],
    );
  }

  Widget _buildNfcCardTile(NfcUserCard card) {
    return InkWell(
      onTap: _isReadingNfc ? null : () => _handleTapNfcCard(card),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: card.cardColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: card.cardColor.withValues(alpha: 0.25)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: card.cardColor.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.nfc_rounded, color: card.cardColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${card.fullName} (${card.role})',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: card.cardColor),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${card.cardId} · ${card.department}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSub),
                  ),
                ],
              ),
            ),
            const Icon(Icons.touch_app_rounded, size: 18, color: AppColors.textMuted),
          ],
        ),
      ),
    );
  }

  // ==================== BƯỚC 2: QUÉT VÂN TAY ====================
  Widget _buildStep2FingerprintView() {
    final card = _detectedCard!;

    return Column(
      children: [
        // Thẻ thông tin nhân viên đã nhận diện từ thẻ NFC
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.successBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
          ),
          child: Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: card.cardColor,
                child: Text(
                  card.fullName.split(' ').map((e) => e.isNotEmpty ? e[0] : '').take(2).join(''),
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(card.fullName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                        const SizedBox(width: 6),
                        const Icon(Icons.check_circle, color: AppColors.success, size: 16),
                      ],
                    ),
                    Text(
                      '${card.role} · Thẻ: ${card.cardId}',
                      style: const TextStyle(fontSize: 12, color: AppColors.textSub),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),

        Text('BƯỚC 2: XÁC THỰC VÂN TAY', style: AppTextStyles.cardHeaderTitle),
        const SizedBox(height: 4),
        Text('Chạm ngón tay đã đăng ký vào cảm biến để xác nhận chủ thẻ', style: AppTextStyles.cardHeaderSub),
        const SizedBox(height: 28),

        // Hoạt ảnh quét vân tay Radar Pulse
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            final isScanning = _isScanningFingerprint;
            final isSuccess = _fingerprintSuccess;

            Color iconColor = AppColors.primary;
            Color bgColor = AppColors.primaryLight;

            if (isSuccess) {
              iconColor = AppColors.success;
              bgColor = AppColors.successBg;
            } else if (isScanning) {
              iconColor = AppColors.secondaryTeal;
              bgColor = const Color(0xFFCCFBF1);
            }

            return Transform.scale(
              scale: isScanning ? _pulseAnimation.value : 1.0,
              child: GestureDetector(
                onTap: isScanning ? null : _handleFingerprintAuth,
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: bgColor,
                    border: Border.all(color: iconColor, width: 2.5),
                    boxShadow: [
                      BoxShadow(
                        color: iconColor.withValues(alpha: 0.2),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Icon(
                      isSuccess ? Icons.check_rounded : Icons.fingerprint_rounded,
                      size: 58,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 18),

        Text(
          _fingerprintSuccess
              ? 'Xác thực vân tay thành công!'
              : (_isScanningFingerprint ? 'Đang đối soát vân tay với thẻ...' : 'Sẵn sàng quét vân tay'),
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: _fingerprintSuccess
                ? AppColors.success
                : (_isScanningFingerprint ? AppColors.secondaryTeal : AppColors.textSub),
          ),
        ),
        const SizedBox(height: 24),

        // Nút chạm vân tay
        SizedBox(
          width: double.infinity,
          height: 48,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: _fingerprintSuccess ? AppColors.success : AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 0,
            ),
            icon: const Icon(Icons.touch_app_rounded, size: 20),
            label: Text(
              _fingerprintSuccess ? 'ĐÃ XÁC THỰC' : 'CHẠM ĐỂ QUÉT VÂN TAY',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            onPressed: _isScanningFingerprint || _fingerprintSuccess ? null : _handleFingerprintAuth,
          ),
        ),
        const SizedBox(height: 12),

        // Nút đổi thẻ khác
        TextButton.icon(
          style: TextButton.styleFrom(
            foregroundColor: AppColors.textSub,
          ),
          icon: const Icon(Icons.arrow_back_rounded, size: 16),
          label: const Text('Chạm thẻ nhân viên khác', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          onPressed: _isScanningFingerprint ? null : _resetToStep1,
        ),
      ],
    );
  }
}
