using System.Collections.Generic;
using System.ComponentModel.DataAnnotations;

namespace RestaurantInventory.API.Models
{
    public class ViTri
    {
        [Key]
        public int MaViTri { get; set; }

        [Required]
        [MaxLength(100)]
        public string TenViTri { get; set; } = string.Empty;

        public decimal HanMucPheDuyet { get; set; } = 0;

        public bool TrangThai { get; set; } = true;

        public virtual ICollection<NguoiDung> NguoiDungs { get; set; } = new List<NguoiDung>();
    }
}
