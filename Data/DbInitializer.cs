using System;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using RestaurantInventory.API.Models;

namespace RestaurantInventory.API.Data
{
    public static class DbInitializer
    {
        public static async Task InitializeAsync(AppDbContext context)
        {
            // Ensure database created
            await context.Database.EnsureCreatedAsync();

            // Seed ViTri
            if (!await context.ViTris.AnyAsync())
            {
                var viTris = new[]
                {
                    new ViTri { MaViTri = 1, TenViTri = "Admin", HanMucPheDuyet = 999999999, TrangThai = true },
                    new ViTri { MaViTri = 2, TenViTri = "Quản lý", HanMucPheDuyet = 50000000, TrangThai = true },
                    new ViTri { MaViTri = 3, TenViTri = "Bếp trưởng", HanMucPheDuyet = 10000000, TrangThai = true },
                    new ViTri { MaViTri = 4, TenViTri = "Nhân viên kho", HanMucPheDuyet = 0, TrangThai = true },
                    new ViTri { MaViTri = 5, TenViTri = "Kế toán", HanMucPheDuyet = 20000000, TrangThai = true }
                };
                await context.ViTris.AddRangeAsync(viTris);
                await context.SaveChangesAsync();
            }

            // Seed NguoiDung with BCrypt hashed passwords
            if (!await context.NguoiDungs.AnyAsync())
            {
                var defaultPasswordHash = BCrypt.Net.BCrypt.HashPassword("123456");

                var users = new[]
                {
                    new NguoiDung { TenDangNhap = "admin_duy", MatKhau = defaultPasswordHash, HoTen = "Cao Thị Thu Uyên", MaViTri = 1, TrangThai = true },
                    new NguoiDung { TenDangNhap = "quanly_lan", MatKhau = defaultPasswordHash, HoTen = "Phan Ngọc Quỳnh Hương", MaViTri = 2, TrangThai = true },
                    new NguoiDung { TenDangNhap = "beptruong_hung", MatKhau = defaultPasswordHash, HoTen = "Nguyễn Thành Trung", MaViTri = 3, TrangThai = true },
                    new NguoiDung { TenDangNhap = "nvkho_tuan", MatKhau = defaultPasswordHash, HoTen = "Nguyễn Trường Duy", MaViTri = 4, TrangThai = true },
                    new NguoiDung { TenDangNhap = "ketoan_an", MatKhau = defaultPasswordHash, HoTen = "Lê Hoàng An", MaViTri = 5, TrangThai = true }
                };
                await context.NguoiDungs.AddRangeAsync(users);
                await context.SaveChangesAsync();
            }

            // Seed Kho
            if (!await context.Khos.AnyAsync())
            {
                var khos = new[]
                {
                    new Kho { TenKho = "Kho mát", ViTriKho = "Khu vực Tầng 1 - Cánh Trái" },
                    new Kho { TenKho = "Kho đông", ViTriKho = "Khu vực Tầng 1 - Cánh Phải" },
                    new Kho { TenKho = "Kho đồ khô", ViTriKho = "Khu vực Tầng 2" }
                };
                await context.Khos.AddRangeAsync(khos);
                await context.SaveChangesAsync();
            }

            // Seed DanhMucHangHoa
            if (!await context.DanhMucHangHoas.AnyAsync())
            {
                var danhMucs = new[]
                {
                    new DanhMucHangHoa { TenDanhMuc = "Rau củ" },
                    new DanhMucHangHoa { TenDanhMuc = "Thịt cá" },
                    new DanhMucHangHoa { TenDanhMuc = "Đồ khô/Gia vị" }
                };
                await context.DanhMucHangHoas.AddRangeAsync(danhMucs);
                await context.SaveChangesAsync();
            }

            // Seed NhaCungCap
            if (!await context.NhaCungCaps.AnyAsync())
            {
                var nccs = new[]
                {
                    new NhaCungCap { TenNhaCungCap = "Công ty Thực phẩm Sạch Vina", SoDienThoai = "0901234567", MaSoThue = "0312345678", DiaChi = "123 Nguyễn Văn Linh, Quận 7, TP.HCM" },
                    new NhaCungCap { TenNhaCungCap = "Hợp tác xã Nông nghiệp Xanh", SoDienThoai = "0912345678", MaSoThue = "0323456789", DiaChi = "45 Quốc lộ 1A, Bình Chánh, TP.HCM" },
                    new NhaCungCap { TenNhaCungCap = "Đại lý Hải sản Biển Đông", SoDienThoai = "0923456789", MaSoThue = "0334567890", DiaChi = "78 Tôn Thất Thuyết, Quận 4, TP.HCM" }
                };
                await context.NhaCungCaps.AddRangeAsync(nccs);
                await context.SaveChangesAsync();
            }

            // Seed HangHoa
            if (!await context.HangHoas.AnyAsync())
            {
                var danhMucRauCu = await context.DanhMucHangHoas.FirstOrDefaultAsync(d => d.TenDanhMuc == "Rau củ");
                var danhMucThitCa = await context.DanhMucHangHoas.FirstOrDefaultAsync(d => d.TenDanhMuc == "Thịt cá");
                var danhMucDoKho = await context.DanhMucHangHoas.FirstOrDefaultAsync(d => d.TenDanhMuc == "Đồ khô/Gia vị");

                var items = new[]
                {
                    new HangHoa { MaSKU = "RC_CAROT_01", TenHangHoa = "Cà rốt Đà Lạt", MaDanhMuc = danhMucRauCu?.MaDanhMuc ?? 1, DonViTinh = "Kg", TonToiThieu = 10 },
                    new HangHoa { MaSKU = "RC_CAITHAO_01", TenHangHoa = "Cải thảo", MaDanhMuc = danhMucRauCu?.MaDanhMuc ?? 1, DonViTinh = "Kg", TonToiThieu = 15 },
                    new HangHoa { MaSKU = "TC_BOBITTET_01", TenHangHoa = "Thịt bò bít tết nhập khẩu", MaDanhMuc = danhMucThitCa?.MaDanhMuc ?? 2, DonViTinh = "Kg", TonToiThieu = 10 },
                    new HangHoa { MaSKU = "TC_CAHOI_01", TenHangHoa = "Cá hồi Na Uy phi lê", MaDanhMuc = danhMucThitCa?.MaDanhMuc ?? 2, DonViTinh = "Kg", TonToiThieu = 5 },
                    new HangHoa { MaSKU = "DK_GAOTE_01", TenHangHoa = "Gạo tẻ ST25", MaDanhMuc = danhMucDoKho?.MaDanhMuc ?? 3, DonViTinh = "Bao 10Kg", TonToiThieu = 5 },
                    new HangHoa { MaSKU = "DK_DAUAN_01", TenHangHoa = "Dầu ăn đậu nành", MaDanhMuc = danhMucDoKho?.MaDanhMuc ?? 3, DonViTinh = "Can 5L", TonToiThieu = 5 }
                };
                await context.HangHoas.AddRangeAsync(items);
                await context.SaveChangesAsync();
            }
        }
    }
}
