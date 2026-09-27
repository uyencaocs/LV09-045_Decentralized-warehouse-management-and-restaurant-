using System.Threading.Tasks;
using RestaurantInventory.API.DTOs;

namespace RestaurantInventory.API.Services
{
    public interface IAuthService
    {
        Task<LoginResponseDto?> LoginAsync(LoginDto dto);
    }
}
