const Router = require('express')
const paymentMethodController = require("../controllers/payment_methodController");
const router = new Router()
const check = require("../middleware/checkRoleMiddleware");

router.post('/', paymentMethodController.create)
router.get('/', paymentMethodController.getAll)
router.get('/:id', paymentMethodController.getOne)
router.put('/:id', paymentMethodController.update)
router.delete('/:id', paymentMethodController.delete)

module.exports = router