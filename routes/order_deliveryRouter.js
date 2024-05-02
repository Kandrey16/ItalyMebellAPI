const Router = require('express')
const orderDeliveryController = require("../controllers/order_deliveryController");
const router = new Router()
const check = require("../middleware/checkRoleMiddleware");

router.post('/', orderDeliveryController.create)
router.get('/', orderDeliveryController.getAll)
router.get('/:id', orderDeliveryController.getOne)
router.put('/:id', orderDeliveryController.update)
router.delete('/:id', orderDeliveryController.delete)

module.exports = router