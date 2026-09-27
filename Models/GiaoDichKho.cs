using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class GiaoDichKho
    {
        [Key]
        public int MaGiaoDich { get; set; }

        [Required]
        [MaxLength(50)]
        public string MaSoPhieu { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string LoaiGiaoDich { get; set; } = string.Empty; // NHAP_KHO, XUAT_KHO, CHUYEN_KHO, DIEU_CHINH

        public int MaKho { get; set; }

        public int? MaKhoDich { get; set; }

        public int? MaDonMuaHang { get; set; }

        public int NguoiTao { get; set; }

        [Required]
        [MaxLength(50)]
        public string TrangThai { get; set; } = "HOAN_THANH";

        public decimal TongGiaTri { get; set; } = 0;

        [ForeignKey("MaKho")]
        public virtual Kho? Kho { get; set; }

        [ForeignKey("MaKhoDich")]
        public virtual Kho? KhoDich { get; set; }

        [ForeignKey("MaDonMuaHang")]
        public virtual DonMuaHang? DonMuaHang { get; set; }

        [ForeignKey("NguoiTao")]
        public virtual NguoiDung? NguoiTaoUser { get; set; }

        public virtual ICollection<CTGiaoDichKho> CTGiaoDichKhos { get; set; } = new List<CTGiaoDichKho>();
    }
}
