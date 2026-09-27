using System.ComponentModel.DataAnnotations;

namespace RestaurantInventory.API.Models
{
    public class DanhMucHangHoa
    {
        [Key]
        public int MaDanhMuc { get; set; }

        [Required]
        [MaxLength(100)]
        public string TenDanhMuc { get; set; } = string.Empty;
    }
}
