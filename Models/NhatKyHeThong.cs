using System;
using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class NhatKyHeThong
    {
        [Key]
        public int MaNhatKy { get; set; }

        public int MaNguoiDung { get; set; }

        [Required]
        [MaxLength(255)]
        public string HanhDong { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string BangTacDong { get; set; } = string.Empty;

        public DateTime ThoiGian { get; set; } = DateTime.UtcNow;

        [ForeignKey("MaNguoiDung")]
        public virtual NguoiDung? NguoiDung { get; set; }
    }
}
