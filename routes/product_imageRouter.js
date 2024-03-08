const Router = require('express')
const productImageController = require("../controllers/product_imageController");
const check = require("../middleware/checkRoleMiddleware");
const router = new Router()

router.post('/', check('ADMIN'), productImageController.create)
router.get('/', productImageController.getAll)
router.get('/:id', productImageController.getOne)
router.put('/:id', check('ADMIN'), productImageController.update)
router.delete('/:id', check('ADMIN'), productImageController.delete)

module.exports = router