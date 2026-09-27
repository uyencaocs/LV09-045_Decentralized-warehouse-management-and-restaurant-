using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class NguoiDung
    {
        [Key]
        public int MaNguoiDung { get; set; }

        [Required]
        [MaxLength(50)]
        public string TenDangNhap { get; set; } = string.Empty;

        [Required]
        [MaxLength(255)]
        public string MatKhau { get; set; } = string.Empty;

        [Required]
        [MaxLength(100)]
        public string HoTen { get; set; } = string.Empty;

        public int MaViTri { get; set; }

        public bool TrangThai { get; set; } = true;

        [ForeignKey("MaViTri")]
        public virtual ViTri? ViTri { get; set; }
    }
}
