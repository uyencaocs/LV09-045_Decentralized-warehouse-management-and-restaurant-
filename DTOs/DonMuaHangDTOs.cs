using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace RestaurantInventory.API.DTOs
{
    public class CreateCTDonMuaHangDto
    {
        [Range(1, int.MaxValue, ErrorMessage = "Mã hàng hóa không hợp lệ")]
        public int MaHangHoa { get; set; }

        [Range(0.01, 1000000, ErrorMessage = "Số lượng đặt phải lớn hơn 0")]
        public decimal SoLuongDat { get; set; }

        [Range(0, 1000000000, ErrorMessage = "Đơn giá nhập không hợp lệ")]
        public decimal DonGiaNhap { get; set; }
    }

    public class CreateDonMuaHangDto
    {
        [Range(1, int.MaxValue, ErrorMessage = "Mã nhà cung cấp không hợp lệ")]
        public int MaNhaCungCap { get; set; }

        [Required(ErrorMessage = "Chi tiết đơn hàng không được để trống")]
        [MinLength(1, ErrorMessage = "Phải có ít nhất 1 mặt hàng trong đơn mua hàng")]
        public List<CreateCTDonMuaHangDto> ChiTiets { get; set; } = new List<CreateCTDonMuaHangDto>();
    }

    public class DonMuaHangResponseDto
    {
        public int MaDonMuaHang { get; set; }
        public string MaSoPO { get; set; } = string.Empty;
        public int MaNhaCungCap { get; set; }
        public string TenNhaCungCap { get; set; } = string.Empty;
        public string NguoiTao { get; set; } = string.Empty;
        public string? NguoiDuyet { get; set; }
        public string TrangThai { get; set; } = string.Empty;
        public decimal TongTien { get; set; }
        public List<CTDonMuaHangResponseDto> ChiTiets { get; set; } = new List<CTDonMuaHangResponseDto>();
    }

    public class CTDonMuaHangResponseDto
    {
        public int MaChiTietPO { get; set; }
        public int MaHangHoa { get; set; }
        public string TenHangHoa { get; set; } = string.Empty;
        public string DonViTinh { get; set; } = string.Empty;
        public decimal SoLuongDat { get; set; }
        public decimal DonGiaNhap { get; set; }
        public decimal ThanhTien { get; set; }
    }

    public class NhapKhoPOLoHangItemDto
    {
        [Range(1, int.MaxValue, ErrorMessage = "Mã hàng hóa không hợp lệ")]
        public int MaHangHoa { get; set; }

        [Required(ErrorMessage = "Số lô không được để trống")]
        public string SoLo { get; set; } = string.Empty;

        public DateTime? NgaySanXuat { get; set; }

        [Required(ErrorMessage = "Hạn sử dụng không được để trống")]
        public DateTime HanSuDung { get; set; }

        [Range(0.01, 1000000, ErrorMessage = "Số lượng thực nhận phải lớn hơn 0")]
        public decimal SoLuongNhan { get; set; }

        [Range(0, 1000000000, ErrorMessage = "Đơn giá không hợp lệ")]
        public decimal DonGia { get; set; }
    }

    public class NhapKhoPODto
    {
        [Range(1, int.MaxValue, ErrorMessage = "Mã đơn mua hàng (PO) không hợp lệ")]
        public int MaDonMuaHang { get; set; }

        [Range(1, int.MaxValue, ErrorMessage = "Mã kho nhập không hợp lệ")]
        public int MaKho { get; set; }

        [Required(ErrorMessage = "Danh sách lô hàng thực nhận không được để trống")]
        [MinLength(1, ErrorMessage = "Phải có ít nhất 1 lô hàng thực nhận")]
        public List<NhapKhoPOLoHangItemDto> LoHangs { get; set; } = new List<NhapKhoPOLoHangItemDto>();
    }
}
