using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class CTDonMuaHang
    {
        [Key]
        public int MaChiTietPO { get; set; }

        public int MaDonMuaHang { get; set; }

        public int MaHangHoa { get; set; }

        public decimal SoLuongDat { get; set; }

        public decimal DonGiaNhap { get; set; }

        public decimal ThanhTien { get; set; }

        [ForeignKey("MaDonMuaHang")]
        public virtual DonMuaHang? DonMuaHang { get; set; }

        [ForeignKey("MaHangHoa")]
        public virtual HangHoa? HangHoa { get; set; }
    }
}
