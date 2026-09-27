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
    public class GiaoDichKhoController : ControllerBase
    {
        private readonly IInventoryService _inventoryService;

        public GiaoDichKhoController(IInventoryService inventoryService)
        {
            _inventoryService = inventoryService;
        }

        /// <summary>
        /// Nhập kho theo đơn mua hàng PO (Đối soát số lượng thực nhận, cập nhật/tạo lô hàng)
        /// </summary>
        [HttpPost("nhap-po")]
        [Authorize(Roles = "Admin,Quản lý,Nhân viên kho")]
        public async Task<IActionResult> NhapKhoPO([FromBody] NhapKhoPODto dto)
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

            var res = await _inventoryService.NhapKhoTheoPOAsync(userId, dto);
            if (!res.Success)
            {
                return BadRequest(res);
            }

            return Ok(res);
        }

        /// <summary>
        /// Xuất kho theo thuật toán FEFO (Lô cận hạn dùng xuất trước, Pessimistic Lock & chống xuất âm)
        /// </summary>
        [HttpPost("xuat-fefo")]
        [Authorize(Roles = "Admin,Quản lý,Bếp trưởng,Nhân viên kho")]
        public async Task<IActionResult> XuatKhoFEFO([FromBody] XuatKhoFefoDto dto)
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

            var res = await _inventoryService.XuatKhoFEFOAsync(userId, dto);
            if (!res.Success)
            {
                return BadRequest(res);
            }

            return Ok(res);
        }
    }
}
