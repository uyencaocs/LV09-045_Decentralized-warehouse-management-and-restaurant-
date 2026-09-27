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
    public class AuthController : ControllerBase
    {
        private readonly IAuthService _authService;

        public AuthController(IAuthService authService)
        {
            _authService = authService;
        }

        /// <summary>
        /// Đăng nhập hệ thống và nhận JWT Token
        /// </summary>
        [HttpPost("login")]
        [AllowAnonymous]
        public async Task<IActionResult> Login([FromBody] LoginDto dto)
        {
            if (!ModelState.IsValid)
            {
                return BadRequest(ApiResponse<object>.Fail("Dữ liệu đầu vào không hợp lệ"));
            }

            var result = await _authService.LoginAsync(dto);
            if (result == null)
            {
                return Unauthorized(ApiResponse<object>.Fail("Tên đăng nhập hoặc mật khẩu không chính xác"));
            }

            return Ok(ApiResponse<LoginResponseDto>.Ok(result, "Đăng nhập thành công"));
        }

        /// <summary>
        /// Lấy thông tin tài khoản hiện tại từ JWT Token
        /// </summary>
        [HttpGet("me")]
        [Authorize]
        public IActionResult GetCurrentUser()
        {
            var userId = User.FindFirstValue(ClaimTypes.NameIdentifier);
            var username = User.FindFirstValue(ClaimTypes.Name);
            var role = User.FindFirstValue(ClaimTypes.Role);
            var fullName = User.FindFirstValue("HoTen");

            return Ok(ApiResponse<object>.Ok(new
            {
                MaNguoiDung = userId,
                TenDangNhap = username,
                HoTen = fullName,
                ViTri = role
            }, "Lấy thông tin tài khoản thành công"));
        }
    }
}
