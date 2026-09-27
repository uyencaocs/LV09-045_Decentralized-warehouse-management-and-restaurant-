using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantInventory.API.Data;
using RestaurantInventory.API.DTOs;

namespace RestaurantInventory.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize(Roles = "Admin,Quản lý")]
    public class AuditLogController : ControllerBase
    {
        private readonly AppDbContext _context;

        public AuditLogController(AppDbContext context)
        {
            _context = context;
        }

        /// <summary>
        /// Xem nhật ký ghi vết thao tác hệ thống (Audit Logs)
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAuditLogs([FromQuery] int pageIndex = 1, [FromQuery] int pageSize = 50)
        {
            var total = await _context.NhatKyHeThongs.CountAsync();
            var items = await _context.NhatKyHeThongs
                .Include(n => n.NguoiDung)
                .OrderByDescending(n => n.ThoiGian)
                .Skip((pageIndex - 1) * pageSize)
                .Take(pageSize)
                .Select(n => new
                {
                    n.MaNhatKy,
                    n.MaNguoiDung,
                    TenNguoiDung = n.NguoiDung != null ? n.NguoiDung.HoTen : string.Empty,
                    n.HanhDong,
                    n.BangTacDong,
                    n.ThoiGian
                })
                .ToListAsync();

            return Ok(ApiResponse<object>.Ok(new
            {
                TotalCount = total,
                PageIndex = pageIndex,
                PageSize = pageSize,
                Items = items
            }, "Lấy nhật ký hệ thống thành công"));
        }
    }
}
