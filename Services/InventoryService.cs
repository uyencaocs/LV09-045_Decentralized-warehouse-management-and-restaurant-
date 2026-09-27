using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using RestaurantInventory.API.Data;
using RestaurantInventory.API.DTOs;
using RestaurantInventory.API.Models;

namespace RestaurantInventory.API.Services
{
    public class InventoryService : IInventoryService
    {
        private readonly AppDbContext _context;
        private readonly ITelegramService _telegramService;
        private readonly IAuditLogService _auditLogService;

        public InventoryService(AppDbContext context, ITelegramService telegramService, IAuditLogService auditLogService)
        {
            _context = context;
            _telegramService = telegramService;
            _auditLogService = auditLogService;
        }

        #region Đơn mua hàng (PO)

        public async Task<ApiResponse<DonMuaHangResponseDto>> CreateDonMuaHangAsync(int userId, CreateDonMuaHangDto dto)
        {
            var supplier = await _context.NhaCungCaps.FindAsync(dto.MaNhaCungCap);
            if (supplier == null)
            {
                return ApiResponse<DonMuaHangResponseDto>.Fail("Nhà cung cấp không tồn tại");
            }

            var poCode = $"PO-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString().Substring(0, 4).ToUpper()}";
            var donMuaHang = new DonMuaHang
            {
                MaSoPO = poCode,
                MaNhaCungCap = dto.MaNhaCungCap,
                NguoiTao = userId,
                TrangThai = "CHO_DUYET",
                TongTien = 0
            };

            decimal totalAmount = 0;
            foreach (var item in dto.ChiTiets)
            {
                var hangHoa = await _context.HangHoas.FindAsync(item.MaHangHoa);
                if (hangHoa == null)
                {
                    return ApiResponse<DonMuaHangResponseDto>.Fail($"Hàng hóa với ID {item.MaHangHoa} không tồn tại");
                }

                var lineTotal = item.SoLuongDat * item.DonGiaNhap;
                totalAmount += lineTotal;

                donMuaHang.CTDonMuaHangs.Add(new CTDonMuaHang
                {
                    MaHangHoa = item.MaHangHoa,
                    SoLuongDat = item.SoLuongDat,
                    DonGiaNhap = item.DonGiaNhap,
                    ThanhTien = lineTotal
                });
            }

            donMuaHang.TongTien = totalAmount;

            await _context.DonMuaHangs.AddAsync(donMuaHang);
            await _context.SaveChangesAsync();

            await _auditLogService.LogAsync(userId, $"Tạo đơn mua hàng {poCode}", "DonMuaHang");

            return await GetDonMuaHangByIdAsync(donMuaHang.MaDonMuaHang);
        }

        public async Task<ApiResponse<DonMuaHangResponseDto>> ApproveDonMuaHangAsync(int managerId, int poId)
        {
            var po = await _context.DonMuaHangs.FindAsync(poId);
            if (po == null)
            {
                return ApiResponse<DonMuaHangResponseDto>.Fail("Đơn mua hàng không tồn tại");
            }

            if (po.TrangThai != "CHO_DUYET")
            {
                return ApiResponse<DonMuaHangResponseDto>.Fail($"Đơn mua hàng đang ở trạng thái '{po.TrangThai}', không thể duyệt");
            }

            po.TrangThai = "DA_DUYET";
            po.NguoiDuyet = managerId;

            await _context.SaveChangesAsync();
            await _auditLogService.LogAsync(managerId, $"Phê duyệt đơn mua hàng {po.MaSoPO}", "DonMuaHang");

            return await GetDonMuaHangByIdAsync(poId);
        }

        public async Task<ApiResponse<List<DonMuaHangResponseDto>>> GetAllDonMuaHangAsync()
        {
            var pos = await _context.DonMuaHangs
                .Include(p => p.NhaCungCap)
                .Include(p => p.NguoiTaoUser)
                .Include(p => p.NguoiDuyetUser)
                .Include(p => p.CTDonMuaHangs)
                    .ThenInclude(ct => ct.HangHoa)
                .OrderByDescending(p => p.MaDonMuaHang)
                .ToListAsync();

            var result = pos.Select(p => MapToDonMuaHangResponse(p)).ToList();
            return ApiResponse<List<DonMuaHangResponseDto>>.Ok(result);
        }

        private async Task<ApiResponse<DonMuaHangResponseDto>> GetDonMuaHangByIdAsync(int id)
        {
            var po = await _context.DonMuaHangs
                .Include(p => p.NhaCungCap)
                .Include(p => p.NguoiTaoUser)
                .Include(p => p.NguoiDuyetUser)
                .Include(p => p.CTDonMuaHangs)
                    .ThenInclude(ct => ct.HangHoa)
                .FirstOrDefaultAsync(p => p.MaDonMuaHang == id);

            if (po == null)
                return ApiResponse<DonMuaHangResponseDto>.Fail("Không tìm thấy đơn mua hàng");

            return ApiResponse<DonMuaHangResponseDto>.Ok(MapToDonMuaHangResponse(po));
        }

        private static DonMuaHangResponseDto MapToDonMuaHangResponse(DonMuaHang p)
        {
            return new DonMuaHangResponseDto
            {
                MaDonMuaHang = p.MaDonMuaHang,
                MaSoPO = p.MaSoPO,
                MaNhaCungCap = p.MaNhaCungCap,
                TenNhaCungCap = p.NhaCungCap?.TenNhaCungCap ?? string.Empty,
                NguoiTao = p.NguoiTaoUser?.HoTen ?? string.Empty,
                NguoiDuyet = p.NguoiDuyetUser?.HoTen,
                TrangThai = p.TrangThai,
                TongTien = p.TongTien,
                ChiTiets = p.CTDonMuaHangs.Select(ct => new CTDonMuaHangResponseDto
                {
                    MaChiTietPO = ct.MaChiTietPO,
                    MaHangHoa = ct.MaHangHoa,
                    TenHangHoa = ct.HangHoa?.TenHangHoa ?? string.Empty,
                    DonViTinh = ct.HangHoa?.DonViTinh ?? string.Empty,
                    SoLuongDat = ct.SoLuongDat,
                    DonGiaNhap = ct.DonGiaNhap,
                    ThanhTien = ct.ThanhTien
                }).ToList()
            };
        }

        #endregion

        #region Nhập Kho Theo PO & Đối Soát

        public async Task<ApiResponse<DonMuaHangResponseDto>> NhapKhoTheoPOAsync(int userId, NhapKhoPODto dto)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var po = await _context.DonMuaHangs
                    .Include(p => p.CTDonMuaHangs)
                    .FirstOrDefaultAsync(p => p.MaDonMuaHang == dto.MaDonMuaHang);

                if (po == null)
                {
                    return ApiResponse<DonMuaHangResponseDto>.Fail("Đơn mua hàng không tồn tại");
                }

                var kho = await _context.Khos.FindAsync(dto.MaKho);
                if (kho == null)
                {
                    return ApiResponse<DonMuaHangResponseDto>.Fail("Kho nhập không tồn tại");
                }

                // Create Inventory Transaction (GiaoDichKho)
                var phieuNhapCode = $"NK-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString().Substring(0, 4).ToUpper()}";
                var giaoDich = new GiaoDichKho
                {
                    MaSoPhieu = phieuNhapCode,
                    LoaiGiaoDich = "NHAP_KHO",
                    MaKho = dto.MaKho,
                    MaDonMuaHang = dto.MaDonMuaHang,
                    NguoiTao = userId,
                    TrangThai = "HOAN_THANH",
                    TongGiaTri = 0
                };

                decimal tongGiaTriGiaoDich = 0;

                foreach (var item in dto.LoHangs)
                {
                    if (item.HanSuDung <= DateTime.UtcNow.Date)
                    {
                        await transaction.RollbackAsync();
                        return ApiResponse<DonMuaHangResponseDto>.Fail($"Hạn sử dụng của lô {item.SoLo} không hợp lệ (đã hoặc gần hết hạn)");
                    }

                    // Create LoHang
                    var loHang = new LoHang
                    {
                        MaHangHoa = item.MaHangHoa,
                        MaKho = dto.MaKho,
                        SoLo = item.SoLo,
                        NgaySanXuat = item.NgaySanXuat,
                        HanSuDung = item.HanSuDung,
                        SoLuongTon = item.SoLuongNhan
                    };

                    await _context.LoHangs.AddAsync(loHang);
                    await _context.SaveChangesAsync(); // get MaLo ID

                    // Add CTGiaoDichKho
                    var lineTotal = item.SoLuongNhan * item.DonGia;
                    tongGiaTriGiaoDich += lineTotal;

                    giaoDich.CTGiaoDichKhos.Add(new CTGiaoDichKho
                    {
                        MaHangHoa = item.MaHangHoa,
                        MaLo = loHang.MaLo,
                        SoLuong = item.SoLuongNhan,
                        DonGia = item.DonGia,
                        ThanhTien = lineTotal
                    });

                    // Update TonKhoTucThoi
                    var tonKho = await _context.TonKhoTucThois.FirstOrDefaultAsync(t => t.MaHangHoa == item.MaHangHoa && t.MaKho == dto.MaKho);
                    if (tonKho == null)
                    {
                        tonKho = new TonKhoTucThoi
                        {
                            MaHangHoa = item.MaHangHoa,
                            MaKho = dto.MaKho,
                            SoLuongTon = item.SoLuongNhan,
                            NgayCapNhat = DateTime.UtcNow
                        };
                        await _context.TonKhoTucThois.AddAsync(tonKho);
                    }
                    else
                    {
                        tonKho.SoLuongTon += item.SoLuongNhan;
                        tonKho.NgayCapNhat = DateTime.UtcNow;
                    }
                }

                giaoDich.TongGiaTri = tongGiaTriGiaoDich;
                await _context.GiaoDichKhos.AddAsync(giaoDich);

                // Update PO status
                po.TrangThai = "DA_NHAP_KHO";

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                await _auditLogService.LogAsync(userId, $"Nhập kho theo PO {po.MaSoPO} vào {kho.TenKho}", "GiaoDichKho");

                return await GetDonMuaHangByIdAsync(dto.MaDonMuaHang);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return ApiResponse<DonMuaHangResponseDto>.Fail($"Lỗi khi thực hiện nhập kho: {ex.Message}");
            }
        }

        #endregion

        #region Thuật toán Xuất kho FEFO & Lock CSDL

        public async Task<ApiResponse<XuatKhoResultDto>> XuatKhoFEFOAsync(int userId, XuatKhoFefoDto dto)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var kho = await _context.Khos.FindAsync(dto.MaKho);
                if (kho == null)
                {
                    return ApiResponse<XuatKhoResultDto>.Fail("Kho xuất không tồn tại");
                }

                var phieuXuatCode = $"XK-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString().Substring(0, 4).ToUpper()}";
                var giaoDich = new GiaoDichKho
                {
                    MaSoPhieu = phieuXuatCode,
                    LoaiGiaoDich = "XUAT_KHO",
                    MaKho = dto.MaKho,
                    NguoiTao = userId,
                    TrangThai = "HOAN_THANH",
                    TongGiaTri = 0
                };

                var result = new XuatKhoResultDto
                {
                    MaSoPhieu = phieuXuatCode,
                    MaKho = dto.MaKho
                };

                foreach (var requestItem in dto.ChiTiets)
                {
                    var hangHoa = await _context.HangHoas.FindAsync(requestItem.MaHangHoa);
                    if (hangHoa == null)
                    {
                        await transaction.RollbackAsync();
                        return ApiResponse<XuatKhoResultDto>.Fail($"Không tìm thấy mặt hàng với ID {requestItem.MaHangHoa}");
                    }

                    // Check total available stock in TonKhoTucThoi
                    var tonKho = await _context.TonKhoTucThois
                        .FirstOrDefaultAsync(t => t.MaHangHoa == requestItem.MaHangHoa && t.MaKho == dto.MaKho);

                    var tongTonHienTai = tonKho?.SoLuongTon ?? 0;

                    if (tongTonHienTai < requestItem.SoLuongXuat)
                    {
                        await transaction.RollbackAsync();
                        return ApiResponse<XuatKhoResultDto>.Fail(
                            $"[XUẤT ÂM KHO BỊ CHẶN] Mặt hàng '{hangHoa.TenHangHoa}' (SKU: {hangHoa.MaSKU}) không đủ tồn kho! Yêu cầu: {requestItem.SoLuongXuat} {hangHoa.DonViTinh}, Tồn hiện tại: {tongTonHienTai} {hangHoa.DonViTinh}");
                    }

                    // Query batches sorted by Expiration Date (HanSuDung ASC) - FEFO algorithm
                    // Fetch available non-expired batches
                    var availableBatches = await _context.LoHangs
                        .Where(l => l.MaHangHoa == requestItem.MaHangHoa && l.MaKho == dto.MaKho && l.SoLuongTon > 0 && l.HanSuDung > DateTime.UtcNow)
                        .OrderBy(l => l.HanSuDung)
                        .ToListAsync();

                    decimal remainingToDeduct = requestItem.SoLuongXuat;
                    var itemResult = new XuatKhoItemResultDto
                    {
                        MaHangHoa = requestItem.MaHangHoa,
                        TenHangHoa = hangHoa.TenHangHoa,
                        TongSoLuongYeuCau = requestItem.SoLuongXuat
                    };

                    foreach (var batch in availableBatches)
                    {
                        if (remainingToDeduct <= 0) break;

                        decimal deductAmount = Math.Min(batch.SoLuongTon, remainingToDeduct);
                        batch.SoLuongTon -= deductAmount;
                        remainingToDeduct -= deductAmount;

                        itemResult.ChiTietLoDaTru.Add(new LoHangDeductedDto
                        {
                            MaLo = batch.MaLo,
                            SoLo = batch.SoLo,
                            HanSuDung = batch.HanSuDung,
                            SoLuongTru = deductAmount,
                            SoLuongConLaiInLo = batch.SoLuongTon
                        });

                        giaoDich.CTGiaoDichKhos.Add(new CTGiaoDichKho
                        {
                            MaHangHoa = requestItem.MaHangHoa,
                            MaLo = batch.MaLo,
                            SoLuong = deductAmount,
                            DonGia = 0,
                            ThanhTien = 0
                        });
                    }

                    if (remainingToDeduct > 0)
                    {
                        await transaction.RollbackAsync();
                        return ApiResponse<XuatKhoResultDto>.Fail(
                            $"[XUẤT ÂM KHO BỊ CHẶN] Mặt hàng '{hangHoa.TenHangHoa}' không đủ số lượng trong các lô chưa hết hạn!");
                    }

                    itemResult.TongSoLuongDapUng = requestItem.SoLuongXuat;
                    result.ChiTietXuats.Add(itemResult);

                    // Update TonKhoTucThoi
                    if (tonKho != null)
                    {
                        tonKho.SoLuongTon -= requestItem.SoLuongXuat;
                        tonKho.NgayCapNhat = DateTime.UtcNow;

                        // Check minimum stock threshold & trigger Telegram alert if below or equal to TonToiThieu
                        if (tonKho.SoLuongTon <= hangHoa.TonToiThieu)
                        {
                            _ = Task.Run(() => _telegramService.SendLowStockAlertAsync(
                                hangHoa.TenHangHoa, hangHoa.MaSKU, tonKho.SoLuongTon, hangHoa.TonToiThieu, kho.TenKho));
                        }
                    }
                }

                await _context.GiaoDichKhos.AddAsync(giaoDich);
                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                await _auditLogService.LogAsync(userId, $"Xuất kho FEFO phiếu {phieuXuatCode} từ {kho.TenKho}", "GiaoDichKho");

                return ApiResponse<XuatKhoResultDto>.Ok(result, "Xuất kho FEFO thành công");
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return ApiResponse<XuatKhoResultDto>.Fail($"Lỗi xuất kho FEFO: {ex.Message}");
            }
        }

        #endregion

        #region Kiểm kê & Cân bằng kho

        public async Task<ApiResponse<KiemKeResponseDto>> TaoKiemKeKhoAsync(int userId, CreateKiemKeDto dto)
        {
            var kho = await _context.Khos.FindAsync(dto.MaKho);
            if (kho == null)
            {
                return ApiResponse<KiemKeResponseDto>.Fail("Kho kiểm kê không tồn tại");
            }

            var kiemKe = new KiemKeKho
            {
                MaKho = dto.MaKho,
                MaNguoiKiem = userId,
                TrangThai = "CHO_DUYET"
            };

            foreach (var detail in dto.ChiTiets)
            {
                var hangHoa = await _context.HangHoas.FindAsync(detail.MaHangHoa);
                if (hangHoa == null)
                {
                    return ApiResponse<KiemKeResponseDto>.Fail($"Mặt hàng ID {detail.MaHangHoa} không tồn tại");
                }

                decimal currentBookStock = 0;
                if (detail.MaLo.HasValue)
                {
                    var lo = await _context.LoHangs.FindAsync(detail.MaLo.Value);
                    currentBookStock = lo?.SoLuongTon ?? 0;
                }
                else
                {
                    var tonKho = await _context.TonKhoTucThois
                        .FirstOrDefaultAsync(t => t.MaHangHoa == detail.MaHangHoa && t.MaKho == dto.MaKho);
                    currentBookStock = tonKho?.SoLuongTon ?? 0;
                }

                decimal chenhLech = detail.SoLuongThucTe - currentBookStock;

                kiemKe.CTKiemKes.Add(new CTKiemKe
                {
                    MaHangHoa = detail.MaHangHoa,
                    MaLo = detail.MaLo,
                    SoLuongHeThong = currentBookStock,
                    SoLuongThucTe = detail.SoLuongThucTe,
                    ChenhLech = chenhLech
                });
            }

            await _context.KiemKeKhos.AddAsync(kiemKe);
            await _context.SaveChangesAsync();

            await _auditLogService.LogAsync(userId, $"Tạo phiếu kiểm kê kho {kho.TenKho}", "KiemKeKho");

            return await GetKiemKeByIdAsync(kiemKe.MaKiemKe);
        }

        public async Task<ApiResponse<KiemKeResponseDto>> PheDuyetKiemKeAsync(int managerId, int kiemKeId)
        {
            using var transaction = await _context.Database.BeginTransactionAsync();
            try
            {
                var kiemKe = await _context.KiemKeKhos
                    .Include(k => k.Kho)
                    .Include(k => k.CTKiemKes)
                        .ThenInclude(ct => ct.HangHoa)
                    .FirstOrDefaultAsync(k => k.MaKiemKe == kiemKeId);

                if (kiemKe == null)
                {
                    return ApiResponse<KiemKeResponseDto>.Fail("Không tìm thấy phiếu kiểm kê");
                }

                if (kiemKe.TrangThai != "CHO_DUYET")
                {
                    return ApiResponse<KiemKeResponseDto>.Fail($"Phiếu kiểm kê đang ở trạng thái '{kiemKe.TrangThai}', không thể duyệt");
                }

                // Auto-generate Adjustment Inventory Transaction (DIEU_CHINH)
                var phieuDieuChinhCode = $"DC-{DateTime.UtcNow:yyyyMMdd}-{Guid.NewGuid().ToString().Substring(0, 4).ToUpper()}";
                var giaoDichDC = new GiaoDichKho
                {
                    MaSoPhieu = phieuDieuChinhCode,
                    LoaiGiaoDich = "DIEU_CHINH",
                    MaKho = kiemKe.MaKho,
                    NguoiTao = managerId,
                    TrangThai = "HOAN_THANH",
                    TongGiaTri = 0
                };

                foreach (var detail in kiemKe.CTKiemKes)
                {
                    if (detail.ChenhLech == 0) continue;

                    // Update TonKhoTucThoi
                    var tonKho = await _context.TonKhoTucThois
                        .FirstOrDefaultAsync(t => t.MaHangHoa == detail.MaHangHoa && t.MaKho == kiemKe.MaKho);

                    if (tonKho == null)
                    {
                        tonKho = new TonKhoTucThoi
                        {
                            MaHangHoa = detail.MaHangHoa,
                            MaKho = kiemKe.MaKho,
                            SoLuongTon = detail.SoLuongThucTe,
                            NgayCapNhat = DateTime.UtcNow
                        };
                        await _context.TonKhoTucThois.AddAsync(tonKho);
                    }
                    else
                    {
                        tonKho.SoLuongTon = detail.SoLuongThucTe;
                        tonKho.NgayCapNhat = DateTime.UtcNow;
                    }

                    // Update Batch if specified
                    if (detail.MaLo.HasValue)
                    {
                        var lo = await _context.LoHangs.FindAsync(detail.MaLo.Value);
                        if (lo != null)
                        {
                            lo.SoLuongTon = detail.SoLuongThucTe;
                        }
                    }

                    giaoDichDC.CTGiaoDichKhos.Add(new CTGiaoDichKho
                    {
                        MaHangHoa = detail.MaHangHoa,
                        MaLo = detail.MaLo,
                        SoLuong = detail.ChenhLech,
                        DonGia = 0,
                        ThanhTien = 0
                    });
                }

                await _context.GiaoDichKhos.AddAsync(giaoDichDC);
                kiemKe.TrangThai = "DA_DUYET";

                await _context.SaveChangesAsync();
                await transaction.CommitAsync();

                await _auditLogService.LogAsync(managerId, $"Quản lý duyệt phiếu kiểm kê #{kiemKeId} - Tự động cân bằng kho {kiemKe.Kho?.TenKho}", "KiemKeKho");

                return await GetKiemKeByIdAsync(kiemKeId);
            }
            catch (Exception ex)
            {
                await transaction.RollbackAsync();
                return ApiResponse<KiemKeResponseDto>.Fail($"Lỗi phê duyệt kiểm kê: {ex.Message}");
            }
        }

        public async Task<ApiResponse<List<KiemKeResponseDto>>> GetAllKiemKeAsync()
        {
            var list = await _context.KiemKeKhos
                .Include(k => k.Kho)
                .Include(k => k.NguoiKiemUser)
                .Include(k => k.CTKiemKes)
                    .ThenInclude(ct => ct.HangHoa)
                .Include(k => k.CTKiemKes)
                    .ThenInclude(ct => ct.LoHang)
                .OrderByDescending(k => k.MaKiemKe)
                .ToListAsync();

            var res = list.Select(k => MapToKiemKeResponse(k)).ToList();
            return ApiResponse<List<KiemKeResponseDto>>.Ok(res);
        }

        private async Task<ApiResponse<KiemKeResponseDto>> GetKiemKeByIdAsync(int id)
        {
            var k = await _context.KiemKeKhos
                .Include(x => x.Kho)
                .Include(x => x.NguoiKiemUser)
                .Include(x => x.CTKiemKes)
                    .ThenInclude(ct => ct.HangHoa)
                .Include(x => x.CTKiemKes)
                    .ThenInclude(ct => ct.LoHang)
                .FirstOrDefaultAsync(x => x.MaKiemKe == id);

            if (k == null) return ApiResponse<KiemKeResponseDto>.Fail("Không tìm thấy phiếu kiểm kê");

            return ApiResponse<KiemKeResponseDto>.Ok(MapToKiemKeResponse(k));
        }

        private static KiemKeResponseDto MapToKiemKeResponse(KiemKeKho k)
        {
            return new KiemKeResponseDto
            {
                MaKiemKe = k.MaKiemKe,
                MaKho = k.MaKho,
                TenKho = k.Kho?.TenKho ?? string.Empty,
                NguoiKiem = k.NguoiKiemUser?.HoTen ?? string.Empty,
                TrangThai = k.TrangThai,
                ChiTiets = k.CTKiemKes.Select(ct => new CTKiemKeResponseDto
                {
                    MaCTKiemKe = ct.MaCTKiemKe,
                    MaHangHoa = ct.MaHangHoa,
                    TenHangHoa = ct.HangHoa?.TenHangHoa ?? string.Empty,
                    MaLo = ct.MaLo,
                    SoLo = ct.LoHang?.SoLo,
                    SoLuongHeThong = ct.SoLuongHeThong,
                    SoLuongThucTe = ct.SoLuongThucTe,
                    ChenhLech = ct.ChenhLech,
                    TyLeChenhLechPercent = ct.SoLuongHeThong == 0 ? 0 : Math.Round((ct.ChenhLech / ct.SoLuongHeThong) * 100, 2)
                }).ToList()
            };
        }

        #endregion

        #region Tổng Hợp Tồn Kho

        public async Task<ApiResponse<List<TonKhoSummaryDto>>> GetTonKhoSummaryAsync()
        {
            var items = await _context.HangHoas
                .Include(h => h.DanhMuc)
                .ToListAsync();

            var allTonKho = await _context.TonKhoTucThois
                .Include(t => t.Kho)
                .ToListAsync();

            var result = items.Select(h =>
            {
                var tonByKho = allTonKho.Where(t => t.MaHangHoa == h.MaHangHoa).ToList();
                decimal totalTon = tonByKho.Sum(t => t.SoLuongTon);

                return new TonKhoSummaryDto
                {
                    MaHangHoa = h.MaHangHoa,
                    MaSKU = h.MaSKU,
                    TenHangHoa = h.TenHangHoa,
                    TenDanhMuc = h.DanhMuc?.TenDanhMuc ?? string.Empty,
                    DonViTinh = h.DonViTinh,
                    TonToiThieu = h.TonToiThieu,
                    TongSoLuongTon = totalTon,
                    IsDuoiNguyencAnToan = totalTon <= h.TonToiThieu,
                    ChiTietTheoKho = tonByKho.Select(tk => new KhoTonItemDto
                    {
                        MaKho = tk.MaKho,
                        TenKho = tk.Kho?.TenKho ?? string.Empty,
                        SoLuongTon = tk.SoLuongTon
                    }).ToList()
                };
            }).ToList();

            return ApiResponse<List<TonKhoSummaryDto>>.Ok(result);
        }

        #endregion
    }
}
