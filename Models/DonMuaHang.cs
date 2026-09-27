using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class DonMuaHang
    {
        [Key]
        public int MaDonMuaHang { get; set; }

        [Required]
        [MaxLength(50)]
        public string MaSoPO { get; set; } = string.Empty;

        public int MaNhaCungCap { get; set; }

        public int NguoiTao { get; set; }

        public int? NguoiDuyet { get; set; }

        [Required]
        [MaxLength(50)]
        public string TrangThai { get; set; } = "CHO_DUYET"; // CHO_DUYET, DA_DUYET, DA_NHAP_KHO, DA_HUY

        public decimal TongTien { get; set; } = 0;

        [ForeignKey("MaNhaCungCap")]
        public virtual NhaCungCap? NhaCungCap { get; set; }

        [ForeignKey("NguoiTao")]
        public virtual NguoiDung? NguoiTaoUser { get; set; }

        [ForeignKey("NguoiDuyet")]
        public virtual NguoiDung? NguoiDuyetUser { get; set; }

        public virtual ICollection<CTDonMuaHang> CTDonMuaHangs { get; set; } = new List<CTDonMuaHang>();
    }
}
