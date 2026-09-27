using System;
using System.Net.Http;
using System.Text;
using System.Text.Json;
using System.Threading.Tasks;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.Logging;

namespace RestaurantInventory.API.Services
{
    public class TelegramService : ITelegramService
    {
        private readonly HttpClient _httpClient;
        private readonly IConfiguration _configuration;
        private readonly ILogger<TelegramService> _logger;

        public TelegramService(HttpClient httpClient, IConfiguration configuration, ILogger<TelegramService> logger)
        {
            _httpClient = httpClient;
            _configuration = configuration;
            _logger = logger;
        }

        public async Task SendLowStockAlertAsync(string tenHangHoa, string maSKU, decimal tonHienTai, decimal tonToiThieu, string tenKho)
        {
            var message = $"🚨 **CẢNH BÁO TỒN KHO AN TOÀN** 🚨\n\n" +
                          $"📦 **Mặt hàng:** {tenHangHoa} (SKU: `{maSKU}`)\n" +
                          $"🏢 **Kho:** {tenKho}\n" +
                          $"📉 **Tồn hiện tại:** {tonHienTai}\n" +
                          $"⚠️ **Ngưỡng tồn tối thiểu:** {tonToiThieu}\n\n" +
                          $"📌 *Vui lòng xem xét lập Đơn đặt hàng (PO) nhập bổ sung kịp thời!*";

            await SendMessageAsync(message);
        }

        public async Task SendMessageAsync(string message)
        {
            var botToken = _configuration["TelegramBot:BotToken"];
            var chatId = _configuration["TelegramBot:ChatId"];

            if (string.IsNullOrWhiteSpace(botToken) || string.IsNullOrWhiteSpace(chatId) || botToken.Contains("YOUR_TELEGRAM_BOT_TOKEN"))
            {
                _logger.LogWarning("Telegram Bot API config is missing or placeholder. Message fallback logged:\n{Message}", message);
                return;
            }

            try
            {
                var url = $"https://api.telegram.org/bot{botToken}/sendMessage";
                var payload = new
                {
                    chat_id = chatId,
                    text = message,
                    parse_mode = "Markdown"
                };

                var content = new StringContent(JsonSerializer.Serialize(payload), Encoding.UTF8, "application/json");
                var response = await _httpClient.PostAsync(url, content);

                if (!response.IsSuccessStatusCode)
                {
                    var responseText = await response.Content.ReadAsStringAsync();
                    _logger.LogError("Gửi tin nhắn Telegram thất bại: StatusCode={StatusCode}, Error={Error}", response.StatusCode, responseText);
                }
            }
            catch (Exception ex)
            {
                _logger.LogError(ex, "Lỗi khi kết nối Telegram Bot API");
            }
        }
    }
}
