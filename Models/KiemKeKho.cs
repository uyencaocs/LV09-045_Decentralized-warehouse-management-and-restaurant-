using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class KiemKeKho
    {
        [Key]
        public int MaKiemKe { get; set; }

        public int MaKho { get; set; }

        public int MaNguoiKiem { get; set; }

        [Required]
        [MaxLength(50)]
        public string TrangThai { get; set; } = "CHO_DUYET"; // CHO_DUYET, DA_DUYET, TU_CHOI

        [ForeignKey("MaKho")]
        public virtual Kho? Kho { get; set; }

        [ForeignKey("MaNguoiKiem")]
        public virtual NguoiDung? NguoiKiemUser { get; set; }

        public virtual ICollection<CTKiemKe> CTKiemKes { get; set; } = new List<CTKiemKe>();
    }
}
