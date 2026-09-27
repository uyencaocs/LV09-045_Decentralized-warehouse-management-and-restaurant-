using System;
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
    public class DonMuaHangController : ControllerBase
    {
        private readonly IInventoryService _inventoryService;

        public DonMuaHangController(IInventoryService inventoryService)
        {
            _inventoryService = inventoryService;
        }

        /// <summary>
        /// Lấy danh sách Đơn mua hàng (PO)
        /// </summary>
        [HttpGet]
        public async Task<IActionResult> GetAll()
        {
            var res = await _inventoryService.GetAllDonMuaHangAsync();
            return Ok(res);
        }

        /// <summary>
        /// Tạo Đơn mua hàng (PO) mới
        /// </summary>
        [HttpPost]
        [Authorize(Roles = "Admin,Quản lý,Bếp trưởng,Kế toán")]
        public async Task<IActionResult> Create([FromBody] CreateDonMuaHangDto dto)
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

            var res = await _inventoryService.CreateDonMuaHangAsync(userId, dto);
            if (!res.Success)
            {
                return BadRequest(res);
            }

            return Ok(res);
        }

        /// <summary>
        /// Phê duyệt Đơn mua hàng (PO)
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

            var res = await _inventoryService.ApproveDonMuaHangAsync(managerId, id);
            if (!res.Success)
            {
                return BadRequest(res);
            }

            return Ok(res);
        }
    }
}
