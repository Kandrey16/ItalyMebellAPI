const Router = require('express')
const router = new Router()
const attributeController = require('../controllers/attributeController')
const check = require("../middleware/checkRoleMiddleware");


router.post('/', check('ADMIN'), attributeController.create)
router.get('/', attributeController.getAll)
router.get('/:id', attributeController.getOne)
router.put('/:id', check('ADMIN'), attributeController.update)
router.delete('/:id', check('ADMIN'), attributeController.delete)

module.exports = router