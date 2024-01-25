const Router = require('express')
const router = new Router()
const attributeController = require('../controllers/attributeController')

router.post('/', attributeController.create)
router.get('/', attributeController.getAll)
router.get('/:id', attributeController.getOne)
router.put('/:id', attributeController.update)
router.delete('/:id', attributeController.delete)

module.exports = router