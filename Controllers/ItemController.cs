using Microsoft.AspNetCore.Mvc;

namespace RestaurantInventory.API.Controllers
{
    public class ItemController : Controller
    {
        public IActionResult Index()
        {
            return View();
        }
    }
}
