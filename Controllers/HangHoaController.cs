using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using RestaurantInventory.API.Data;
using RestaurantInventory.API.DTOs;
using RestaurantInventory.API.Models;
using RestaurantInventory.API.Services;

namespace RestaurantInventory.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class HangHoaController : ControllerBase
    {
        private readonly AppDbContext _context;
        private readonly IInventoryService _inventoryService;

        public HangHoaController(AppDbContext context, IInventoryService inventoryService)
        {
            _context = context;
            _inventoryService = inventoryService;
        }

        /// <summary>
        /// Xem báo cáo tổng hợp tồn kho tức thời & cảnh báo mặt hàng dưới ngưỡng an toàn (TonToiThieu)
        /// </summary>
        [HttpGet("tonkho")]
        public async Task<IActionResult> GetTonKhoSummary()
        {
            var res = await _inventoryService.GetTonKhoSummaryAsync();
            return Ok(res);
        }

        /// <summary>
        /// Lấy danh sách Hàng hóa trong hệ thống
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var list = await _context.HangHoas
                .Include(h => h.DanhMuc)
                .ToListAsync();

            return Ok(ApiResponse<object>.Ok(list));
        }

        /// <summary>
        /// Thêm mặt hàng mới vào hệ thống
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin,Quản lý")]
        public async Task<IActionResult> Create([FromBody] CreateHangHoaDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<object>.Fail("Dữ liệu đầu vào không hợp lệ"));
            }

            var skuExists = await _context.HangHoas.AnyAsync(h => h.MaSKU == dto.MaSKU);
            if (skuExists)
            {
                return BadRequest(ApiResponse<object>.Fail($"Mã SKU '{dto.MaSKU}' đã tồn tại"));
            }

            var hangHoa = new HangHoa
            {
                MaSKU = dto.MaSKU,
                TenHangHoa = dto.TenHangHoa,
                MaDanhMuc = dto.MaDanhMuc,
                DonViTinh = dto.DonViTinh,
                TonToiThieu = dto.TonToiThieu
            };

            await _context.HangHoas.AddAsync(hangHoa);
            await _context.SaveChangesAsync();

            return Ok(ApiResponse<HangHoa>.Ok(hangHoa, "Tạo hàng hóa thành công"));
        }
    }
}
