using System.Threading.Tasks;

namespace RestaurantInventory.API.Services
{
    public interface IAuditLogService
    {
        Task LogAsync(int maNguoiDung, string hanhDong, string bangTacDong);
    }
}
