using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class HangHoa
    {
        [Key]
        public int MaHangHoa { get; set; }

        [Required]
        [MaxLength(50)]
        public string MaSKU { get; set; } = string.Empty;

        [Required]
        [MaxLength(200)]
        public string TenHangHoa { get; set; } = string.Empty;

        public int MaDanhMuc { get; set; }

        [Required]
        [MaxLength(50)]
        public string DonViTinh { get; set; } = string.Empty;

        public decimal TonToiThieu { get; set; } = 0;

        [ForeignKey("MaDanhMuc")]
        public virtual DanhMucHangHoa? DanhMuc { get; set; }
    }
}
