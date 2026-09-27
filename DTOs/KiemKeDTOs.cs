using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace RestaurantInventory.API.DTOs
{
    public class CreateCTKiemKeDto
    {
        [Range(1, int.MaxValue, ErrorMessage = "Mã hàng hóa không hợp lệ")]
        public int MaHangHoa { get; set; }

        public int? MaLo { get; set; }

        [Range(0, 1000000, ErrorMessage = "Số lượng thực tế không được âm")]
        public decimal SoLuongThucTe { get; set; }
    }

    public class CreateKiemKeDto
    {
        [Range(1, int.MaxValue, ErrorMessage = "Mã kho kiểm kê không hợp lệ")]
        public int MaKho { get; set; }

        [Required(ErrorMessage = "Danh sách chi tiết kiểm kê không được để trống")]
        [MinLength(1, ErrorMessage = "Phải có ít nhất 1 mặt hàng được kiểm kê")]
        public List<CreateCTKiemKeDto> ChiTiets { get; set; } = new List<CreateCTKiemKeDto>();
    }

    public class CTKiemKeResponseDto
    {
        public int MaCTKiemKe { get; set; }
        public int MaHangHoa { get; set; }
        public string TenHangHoa { get; set; } = string.Empty;
        public int? MaLo { get; set; }
        public string? SoLo { get; set; }
        public decimal SoLuongHeThong { get; set; }
        public decimal SoLuongThucTe { get; set; }
        public decimal ChenhLech { get; set; }
        public decimal TyLeChenhLechPercent { get; set; }
    }

    public class KiemKeResponseDto
    {
        public int MaKiemKe { get; set; }
        public int MaKho { get; set; }
        public string TenKho { get; set; } = string.Empty;
        public string NguoiKiem { get; set; } = string.Empty;
        public string TrangThai { get; set; } = string.Empty; // CHO_DUYET, DA_DUYET, TU_CHOI
        public List<CTKiemKeResponseDto> ChiTiets { get; set; } = new List<CTKiemKeResponseDto>();
    }
}
