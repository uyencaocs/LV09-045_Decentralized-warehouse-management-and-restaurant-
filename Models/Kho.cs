using System.ComponentModel.DataAnnotations;

namespace RestaurantInventory.API.Models
{
    public class Kho
    {
        [Key]
        public int MaKho { get; set; }

        [Required]
        [MaxLength(100)]
        public string TenKho { get; set; } = string.Empty;

        [MaxLength(200)]
        public string? ViTriKho { get; set; }
    }
}
