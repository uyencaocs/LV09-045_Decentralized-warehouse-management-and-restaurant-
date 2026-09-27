using System;
using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using System.Threading.Tasks;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.IdentityModel.Tokens;
using RestaurantInventory.API.Data;
using RestaurantInventory.API.DTOs;
using RestaurantInventory.API.Models;

namespace RestaurantInventory.API.Services
{
    public class AuthService : IAuthService
    {
        private readonly AppDbContext _context;
        private readonly IConfiguration _configuration;
        private readonly IAuditLogService _auditLogService;

        public AuthService(AppDbContext context, IConfiguration configuration, IAuditLogService auditLogService)
        {
            _context = context;
            _configuration = configuration;
            _auditLogService = auditLogService;
        }

        public async Task<LoginResponseDto?> LoginAsync(LoginDto dto)
        {
            var user = await _context.NguoiDungs
                .Include(u => u.ViTri)
                .FirstOrDefaultAsync(u => u.TenDangNhap == dto.TenDangNhap && u.TrangThai);

            if (user == null)
            {
                return null;
            }

            // Verify BCrypt password
            bool isPasswordValid = false;
            try
            {
                isPasswordValid = BCrypt.Net.BCrypt.Verify(dto.MatKhau, user.MatKhau);
            }
            catch
            {
                // Fallback for plain text if legacy seed was used
                isPasswordValid = (dto.MatKhau == user.MatKhau);
            }

            if (!isPasswordValid)
            {
                return null;
            }

            var roleName = user.ViTri?.TenViTri ?? "User";

            var token = GenerateJwtToken(user, roleName);

            await _auditLogService.LogAsync(user.MaNguoiDung, "Đăng nhập hệ thống", "NguoiDung");

            return new LoginResponseDto
            {
                Token = token,
                MaNguoiDung = user.MaNguoiDung,
                TenDangNhap = user.TenDangNhap,
                HoTen = user.HoTen,
                ViTri = roleName
            };
        }

        private string GenerateJwtToken(NguoiDung user, string roleName)
        {
            var jwtKey = _configuration["Jwt:Key"] ?? "SuperSecretKeyForRestaurantInventoryAPI2026!#$";
            var issuer = _configuration["Jwt:Issuer"] ?? "RestaurantInventoryAPI";
            var audience = _configuration["Jwt:Audience"] ?? "RestaurantInventoryFlutterApp";

            var key = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(jwtKey));
            var credentials = new SigningCredentials(key, SecurityAlgorithms.HmacSha256);

            var claims = new[]
            {
                new Claim(ClaimTypes.NameIdentifier, user.MaNguoiDung.ToString()),
                new Claim(ClaimTypes.Name, user.TenDangNhap),
                new Claim(ClaimTypes.Role, roleName),
                new Claim("HoTen", user.HoTen)
            };

            var tokenDescriptor = new SecurityTokenDescriptor
            {
                Subject = new ClaimsIdentity(claims),
                Expires = DateTime.UtcNow.AddDays(7),
                Issuer = issuer,
                Audience = audience,
                SigningCredentials = credentials
            };

            var tokenHandler = new JwtSecurityTokenHandler();
            var token = tokenHandler.CreateToken(tokenDescriptor);
            return tokenHandler.WriteToken(token);
        }
    }
}
