const Router = require('express')
const orderProductController = require("../controllers/order_productController");
const router = new Router()

router.post('/', orderProductController.create)
router.get('/', orderProductController.getAll)
router.get('/:id', orderProductController.getOne)
router.put('/:id', orderProductController.update)
router.delete('/:id', orderProductController.delete)

module.exports = router