const Router = require('express')
const router = new Router()
const cartController = require('../controllers/cartController')
const check = require("../middleware/checkRoleMiddleware");

router.post('/create', cartController.createCart)
router.post('/', cartController.addToCart)
router.put('/:id', cartController.updateCartItem)
router.delete('/:id', cartController.removeFromCart)
router.get('/:email_user', cartController.getCart)

module.exports = router