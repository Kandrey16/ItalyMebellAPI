const Router = require('express')
const router = new Router()
const specificationController = require('../controllers/specificationController')
const check = require("../middleware/checkRoleMiddleware");

router.post('/', check('ADMIN'), specificationController.create)
router.get('/', specificationController.getAll)
router.get('/:id', specificationController.getOne)
router.put('/:id', check('ADMIN'), specificationController.update)
router.delete('/:id', check('ADMIN'), specificationController.delete)

module.exports = router