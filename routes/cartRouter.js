const Router = require('express')
const router = new Router()
const cartController = require('../controllers/cartController')
const checkRole = require("../middleware/checkRoleMiddleware");
const checkAuth = require('../middleware/authMiddleware')

router.post('/create', cartController.createCart)
router.post('/', checkAuth, cartController.addToCart)
router.put('/:id', checkAuth, cartController.updateCartItem)
router.delete('/:id', checkAuth, cartController.removeFromCart)
router.get('/:email_user', checkAuth, cartController.getCart)

module.exports = router