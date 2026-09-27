using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace RestaurantInventory.API.Models
{
    public class YeuCauDuyet
    {
        [Key]
        public int MaYeuCau { get; set; }

        public int MaGiaoDich { get; set; }

        public int NguoiYeuCau { get; set; }

        public int? NguoiDuyet { get; set; }

        public decimal GiaTriYeuCau { get; set; }

        [Required]
        [MaxLength(50)]
        public string TrangThai { get; set; } = "CHO_DUYET"; // CHO_DUYET, DA_DUYET, TU_CHOI

        [ForeignKey("MaGiaoDich")]
        public virtual GiaoDichKho? GiaoDichKho { get; set; }

        [ForeignKey("NguoiYeuCau")]
        public virtual NguoiDung? NguoiYeuCauUser { get; set; }

        [ForeignKey("NguoiDuyet")]
        public virtual NguoiDung? NguoiDuyetUser { get; set; }
    }
}
