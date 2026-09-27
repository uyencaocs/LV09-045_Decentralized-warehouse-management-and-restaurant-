using System.Collections.Generic;
using System.Threading.Tasks;
using RestaurantInventory.API.DTOs;

namespace RestaurantInventory.API.Services
{
    public interface IInventoryService
    {
        // Don Mua Hang (PO)
        Task<ApiResponse<DonMuaHangResponseDto>> CreateDonMuaHangAsync(int userId, CreateDonMuaHangDto dto);
        Task<ApiResponse<DonMuaHangResponseDto>> ApproveDonMuaHangAsync(int managerId, int poId);
        Task<ApiResponse<List<DonMuaHangResponseDto>>> GetAllDonMuaHangAsync();

        // Nhap Kho PO
        Task<ApiResponse<DonMuaHangResponseDto>> NhapKhoTheoPOAsync(int userId, NhapKhoPODto dto);

        // Xuat Kho FEFO
        Task<ApiResponse<XuatKhoResultDto>> XuatKhoFEFOAsync(int userId, XuatKhoFefoDto dto);

        // Kiem Ke & Can Bang Kho
        Task<ApiResponse<KiemKeResponseDto>> TaoKiemKeKhoAsync(int userId, CreateKiemKeDto dto);
        Task<ApiResponse<KiemKeResponseDto>> PheDuyetKiemKeAsync(int managerId, int kiemKeId);
        Task<ApiResponse<List<KiemKeResponseDto>>> GetAllKiemKeAsync();

        // Hang Hoa & Ton Kho
        Task<ApiResponse<List<TonKhoSummaryDto>>> GetTonKhoSummaryAsync();
    }
}
