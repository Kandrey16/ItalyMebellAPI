const Router = require('express')
const router = new Router()
const collectionController = require('../controllers/collection_controller')
const check = require("../middleware/checkRoleMiddleware");


router.post('/', collectionController.create)
router.get('/',collectionController.getAll)
router.get('/:id', collectionController.getOne)
router.put('/:id', collectionController.update)
router.delete('/:id', collectionController.delete)

module.exports = router