using System.ComponentModel.DataAnnotations;

namespace RestaurantInventory.API.Models
{
    public class NhaCungCap
    {
        [Key]
        public int MaNhaCungCap { get; set; }

        [Required]
        [MaxLength(200)]
        public string TenNhaCungCap { get; set; } = string.Empty;

        [Required]
        [MaxLength(20)]
        public string SoDienThoai { get; set; } = string.Empty;

        [Required]
        [MaxLength(50)]
        public string MaSoThue { get; set; } = string.Empty;

        [Required]
        [MaxLength(255)]
        public string DiaChi { get; set; } = string.Empty;
    }
}
