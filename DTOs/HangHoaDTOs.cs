using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace RestaurantInventory.API.DTOs
{
    public class CreateHangHoaDto
    {
        [Required(ErrorMessage = "Mã SKU không được để trống")]
        public string MaSKU { get; set; } = string.Empty;

        [Required(ErrorMessage = "Tên hàng hóa không được để trống")]
        public string TenHangHoa { get; set; } = string.Empty;

        [Range(1, int.MaxValue, ErrorMessage = "Danh mục không hợp lệ")]
        public int MaDanhMuc { get; set; }

        [Required(ErrorMessage = "Đơn vị tính không được để trống")]
        public string DonViTinh { get; set; } = string.Empty;

        [Range(0, 100000, ErrorMessage = "Tồn tối thiểu không được âm")]
        public decimal TonToiThieu { get; set; }
    }

    public class TonKhoSummaryDto
    {
        public int MaHangHoa { get; set; }
        public string MaSKU { get; set; } = string.Empty;
        public string TenHangHoa { get; set; } = string.Empty;
        public string TenDanhMuc { get; set; } = string.Empty;
        public string DonViTinh { get; set; } = string.Empty;
        public decimal TonToiThieu { get; set; }
        public decimal TongSoLuongTon { get; set; }
        public bool IsDuoiNguyencAnToan { get; set; }
        public List<KhoTonItemDto> ChiTietTheoKho { get; set; } = new List<KhoTonItemDto>();
    }

    public class KhoTonItemDto
    {
        public int MaKho { get; set; }
        public string TenKho { get; set; } = string.Empty;
        public decimal SoLuongTon { get; set; }
    }
}
