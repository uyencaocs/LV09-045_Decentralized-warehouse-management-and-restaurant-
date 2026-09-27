using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class CTKiemKe
    {
        [Key]
        public int MaCTKiemKe { get; set; }

        public int MaKiemKe { get; set; }

        public int MaHangHoa { get; set; }

        public int? MaLo { get; set; }

        public decimal SoLuongHeThong { get; set; }

        public decimal SoLuongThucTe { get; set; }

        public decimal ChenhLech { get; set; }

        [ForeignKey("MaKiemKe")]
        public virtual KiemKeKho? KiemKeKho { get; set; }

        [ForeignKey("MaHangHoa")]
        public virtual HangHoa? HangHoa { get; set; }

        [ForeignKey("MaLo")]
        public virtual LoHang? LoHang { get; set; }
    }
}
