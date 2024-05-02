const Router = require('express')
const orderStatusController = require("../controllers/order_status_controller");
const router = new Router()
const check = require("../middleware/checkRoleMiddleware");

router.post('/', orderStatusController.create)
router.get('/', orderStatusController.getAll)
router.get('/:id', orderStatusController.getOne)
router.put('/:id', orderStatusController.update)
router.delete('/:id', orderStatusController.delete)

module.exports = router