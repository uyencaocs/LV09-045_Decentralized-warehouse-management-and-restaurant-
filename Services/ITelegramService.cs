using System.Threading.Tasks;

namespace RestaurantInventory.API.Services
{
    public interface ITelegramService
    {
        Task SendLowStockAlertAsync(string tenHangHoa, string maSKU, decimal tonHienTai, decimal tonToiThieu, string tenKho);
        Task SendMessageAsync(string message);
    }
}
