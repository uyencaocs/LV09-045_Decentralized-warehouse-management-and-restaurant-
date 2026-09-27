using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class CTGiaoDichKho
    {
        [Key]
        public int MaChiTiet { get; set; }

        public int MaGiaoDich { get; set; }

        public int MaHangHoa { get; set; }

        public int? MaLo { get; set; }

        public decimal SoLuong { get; set; }

        public decimal DonGia { get; set; }

        public decimal ThanhTien { get; set; }

        [ForeignKey("MaGiaoDich")]
        public virtual GiaoDichKho? GiaoDichKho { get; set; }

        [ForeignKey("MaHangHoa")]
        public virtual HangHoa? HangHoa { get; set; }

        [ForeignKey("MaLo")]
        public virtual LoHang? LoHang { get; set; }
    }
}
