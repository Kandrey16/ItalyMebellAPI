const Router = require('express')
const orderAddressController = require("../controllers/order_addressController");
const router = new Router()

router.post('/', orderAddressController.create)
router.get('/', orderAddressController.getAll)
router.get('/:id', orderAddressController.getOne)
router.put('/:id', orderAddressController.update)
router.delete('/:id', orderAddressController.delete)

module.exports = router