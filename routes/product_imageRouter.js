const Router = require('express')
const productImageController = require("../controllers/product_imageController");
const router = new Router()

router.post('/', productImageController.create)
router.get('/', productImageController.getAll)
router.get('/:id', productImageController.getOne)
router.put('/:id', productImageController.update)
router.delete('/:id', productImageController.delete)

module.exports = router