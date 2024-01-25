const Router = require('express')
const router = new Router()
const specificationController = require('../controllers/specificationController')

router.post('/', specificationController.create)
router.get('/', specificationController.getAll)
router.get('/:id', specificationController.getOne)
router.put('/:id', specificationController.update)
router.delete('/:id', specificationController.delete)

module.exports = router