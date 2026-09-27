using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using RestaurantInventory.API.DTOs;
using RestaurantInventory.API.Services;

namespace RestaurantInventory.API.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    [Authorize]
    public class KiemKeController : ControllerBase
    {
        private readonly IInventoryService _inventoryService;

        public KiemKeController(IInventoryService inventoryService)
        {
            _inventoryService = inventoryService;
        }

        /// <summary>
        /// Lấy danh sách Phiếu kiểm kê kho
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var res = await _inventoryService.GetAllKiemKeAsync();
            return Ok(res);
        }

        /// <summary>
        /// Tạo phiếu Kiểm kê kho (So khớp số tồn thực tế và tồn sổ sách)
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin,Quản lý,Nhân viên kho")]
        public async Task<IActionResult> Create([FromBody] CreateKiemKeDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<object>.Fail("Dữ liệu đầu vào không hợp lệ"));
            }

            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int userId))
            {
                return Unauthorized(ApiResponse<object>.Fail("Xác thực người dùng thất bại"));
            }

            var res = await _inventoryService.TaoKiemKeKhoAsync(userId, dto);
            if (!res.Success)
            {
                return BadRequest(res);
            }

            return Ok(res);
        }

        /// <summary>
        /// Quản lý duyệt Phiếu kiểm kê (Tự động sinh bút toán điều chỉnh tồn kho DIEU_CHINH)
        /// </summary>
        [HttpPut("{id}/pheduyet")]
        [Authorize(Roles = "Admin,Quản lý")]
        public async Task<IActionResult> Approve(int id)
        {
            var userIdStr = User.FindFirstValue(ClaimTypes.NameIdentifier);
            if (!int.TryParse(userIdStr, out int managerId))
            {
                return Unauthorized(ApiResponse<object>.Fail("Xác thực người dùng thất bại"));
            }

            var res = await _inventoryService.PheDuyetKiemKeAsync(managerId, id);
            if (!res.Success)
            {
                return BadRequest(res);
            }

            return Ok(res);
        }
    }
}
