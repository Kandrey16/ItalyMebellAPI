const Router = require('express')
const ordersController = require("../controllers/ordersController");
const router = new Router()

router.post('/', ordersController.create)
router.get('/', ordersController.getAll)
router.get('/:id', ordersController.getOne)
router.put('/:id', ordersController.update)
router.delete('/:id', ordersController.delete)

module.exports = router