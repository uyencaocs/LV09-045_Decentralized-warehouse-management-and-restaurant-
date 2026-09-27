using System;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class TonKhoTucThoi
    {
        public int MaHangHoa { get; set; }

        public int MaKho { get; set; }

        public decimal SoLuongTon { get; set; } = 0;

        public DateTime NgayCapNhat { get; set; } = DateTime.UtcNow;

        [ForeignKey("MaHangHoa")]
        public virtual HangHoa? HangHoa { get; set; }

        [ForeignKey("MaKho")]
        public virtual Kho? Kho { get; set; }
    }
}
