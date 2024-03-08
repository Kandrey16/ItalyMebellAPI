const Router = require('express')
const productCommentController = require("../controllers/product_commentController");
const router = new Router()
const check = require("../middleware/checkRoleMiddleware");

router.post('/', check('ADMIN'), productCommentController.create)
router.get('/', productCommentController.getAll)
router.get('/:id', productCommentController.getOne)
router.put('/:id', check('ADMIN'), productCommentController.update)
router.delete('/:id', check('ADMIN'), productCommentController.delete)

module.exports = router