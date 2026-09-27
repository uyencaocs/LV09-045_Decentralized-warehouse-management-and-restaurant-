using System;
using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace RestaurantInventory.API.DTOs
{
    public class XuatKhoDetailDto
    {
        [Range(1, int.MaxValue, ErrorMessage = "Mã hàng hóa không hợp lệ")]
        public int MaHangHoa { get; set; }

        [Range(0.01, 1000000, ErrorMessage = "Số lượng xuất phải lớn hơn 0")]
        public decimal SoLuongXuat { get; set; }
    }

    public class XuatKhoFefoDto
    {
        [Range(1, int.MaxValue, ErrorMessage = "Mã kho xuất không hợp lệ")]
        public int MaKho { get; set; }

        [Required(ErrorMessage = "Danh sách mặt hàng xuất không được để trống")]
        [MinLength(1, ErrorMessage = "Phải có ít nhất 1 mặt hàng cần xuất")]
        public List<XuatKhoDetailDto> ChiTiets { get; set; } = new List<XuatKhoDetailDto>();
    }

    public class LoHangDeductedDto
    {
        public int MaLo { get; set; }
        public string SoLo { get; set; } = string.Empty;
        public DateTime HanSuDung { get; set; }
        public decimal SoLuongTru { get; set; }
        public decimal SoLuongConLaiInLo { get; set; }
    }

    public class XuatKhoItemResultDto
    {
        public int MaHangHoa { get; set; }
        public string TenHangHoa { get; set; } = string.Empty;
        public decimal TongSoLuongYeuCau { get; set; }
        public decimal TongSoLuongDapUng { get; set; }
        public List<LoHangDeductedDto> ChiTietLoDaTru { get; set; } = new List<LoHangDeductedDto>();
    }

    public class XuatKhoResultDto
    {
        public string MaSoPhieu { get; set; } = string.Empty;
        public int MaKho { get; set; }
        public List<XuatKhoItemResultDto> ChiTietXuats { get; set; } = new List<XuatKhoItemResultDto>();
    }
}
