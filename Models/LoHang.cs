using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class LoHang
    {
        [Key]
        public int MaLo { get; set; }

        public int MaHangHoa { get; set; }

        public int MaKho { get; set; }

        [Required]
        [MaxLength(50)]
        public string SoLo { get; set; } = string.Empty;

        public DateTime? NgaySanXuat { get; set; }

        public DateTime HanSuDung { get; set; }

        public decimal SoLuongTon { get; set; } = 0;

        [ForeignKey("MaHangHoa")]
        public virtual HangHoa? HangHoa { get; set; }

        [ForeignKey("MaKho")]
        public virtual Kho? Kho { get; set; }
    }
}
