using System;
using System.Threading.Tasks;
using RestaurantInventory.API.Data;
using RestaurantInventory.API.Models;

namespace RestaurantInventory.API.Services
{
    public class AuditLogService : IAuditLogService
    {
        private readonly AppDbContext _context;

        public AuditLogService(AppDbContext context)
        {
            _context = context;
        }

        public async Task LogAsync(int maNguoiDung, string hanhDong, string bangTacDong)
        {
            var auditLog = new NhatKyHeThong
            {
                MaNguoiDung = maNguoiDung,
                HanhDong = hanhDong,
                BangTacDong = bangTacDong,
                ThoiGian = DateTime.UtcNow
            };

            await _context.NhatKyHeThongs.AddAsync(auditLog);
            await _context.SaveChangesAsync();
        }
    }
}
