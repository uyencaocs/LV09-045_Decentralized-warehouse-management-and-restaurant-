using Microsoft.EntityFrameworkCore;
using RestaurantInventory.API.Models;

namespace RestaurantInventory.API.Data
{
    public class AppDbContext : DbContext
    {
        public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
        {
        }

        public DbSet<ViTri> ViTris { get; set; } = null!;
        public DbSet<NguoiDung> NguoiDungs { get; set; } = null!;
        public DbSet<Kho> Khos { get; set; } = null!;
        public DbSet<DanhMucHangHoa> DanhMucHangHoas { get; set; } = null!;
        public DbSet<HangHoa> HangHoas { get; set; } = null!;
        public DbSet<NhaCungCap> NhaCungCaps { get; set; } = null!;
        public DbSet<NhatKyHeThong> NhatKyHeThongs { get; set; } = null!;
        public DbSet<DonMuaHang> DonMuaHangs { get; set; } = null!;
        public DbSet<CTDonMuaHang> CTDonMuaHangs { get; set; } = null!;
        public DbSet<GiaoDichKho> GiaoDichKhos { get; set; } = null!;
        public DbSet<CTGiaoDichKho> CTGiaoDichKhos { get; set; } = null!;
        public DbSet<LoHang> LoHangs { get; set; } = null!;
        public DbSet<TonKhoTucThoi> TonKhoTucThois { get; set; } = null!;
        public DbSet<KiemKeKho> KiemKeKhos { get; set; } = null!;
        public DbSet<CTKiemKe> CTKiemKes { get; set; } = null!;
        public DbSet<YeuCauDuyet> YeuCauDuyets { get; set; } = null!;

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            // Composite Key for TonKhoTucThoi
            modelBuilder.Entity<TonKhoTucThoi>()
                .HasKey(t => new { t.MaHangHoa, t.MaKho });

            // Unique Indexes
            modelBuilder.Entity<NguoiDung>()
                .HasIndex(u => u.TenDangNhap)
                .IsUnique();

            modelBuilder.Entity<HangHoa>()
                .HasIndex(h => h.MaSKU)
                .IsUnique();

            modelBuilder.Entity<DonMuaHang>()
                .HasIndex(d => d.MaSoPO)
                .IsUnique();

            modelBuilder.Entity<GiaoDichKho>()
                .HasIndex(g => g.MaSoPhieu)
                .IsUnique();

            // Index for FEFO batch query performance
            modelBuilder.Entity<LoHang>()
                .HasIndex(l => new { l.MaHangHoa, l.MaKho, l.HanSuDung, l.SoLuongTon });

            // Table names configuration
            modelBuilder.Entity<ViTri>().ToTable("vitri");
            modelBuilder.Entity<NguoiDung>().ToTable("nguoidung");
            modelBuilder.Entity<Kho>().ToTable("kho");
            modelBuilder.Entity<DanhMucHangHoa>().ToTable("danhmuchanghoa");
            modelBuilder.Entity<HangHoa>().ToTable("hanghoa");
            modelBuilder.Entity<NhaCungCap>().ToTable("nhacungcap");
            modelBuilder.Entity<NhatKyHeThong>().ToTable("nhatkyhethong");
            modelBuilder.Entity<DonMuaHang>().ToTable("donmuahang");
            modelBuilder.Entity<CTDonMuaHang>().ToTable("ctdonmuahang");
            modelBuilder.Entity<GiaoDichKho>().ToTable("giaodichkho");
            modelBuilder.Entity<CTGiaoDichKho>().ToTable("ctgiaodichkho");
            modelBuilder.Entity<LoHang>().ToTable("lohang");
            modelBuilder.Entity<TonKhoTucThoi>().ToTable("tonkhotucthoi");
            modelBuilder.Entity<KiemKeKho>().ToTable("kiemkekho");
            modelBuilder.Entity<CTKiemKe>().ToTable("ctkiemke");
            modelBuilder.Entity<YeuCauDuyet>().ToTable("yeucauduyet");
        }
    }
}
