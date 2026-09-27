using Microsoft.AspNetCore.Mvc;

namespace RestaurantInventory.API.Controllers
{
    public class SuppliersController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
