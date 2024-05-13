//router.js
const Router = require('express')
const router = new Router()
const productController = require('../controllers/productController')
const check = require("../middleware/checkRoleMiddleware");

router.post('/', productController.create)
router.get('/search', productController.search)
router.get('/', productController.getAll)
router.get('/:id', productController.getOne)
router.put('/:id', productController.update)
router.delete('/:id', productController.delete)

module.exports = router