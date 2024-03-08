const Router = require('express')
const productCommentController = require("../controllers/product_commentController");
const router = new Router()
const check = require("../middleware/checkRoleMiddleware");

router.post('/', productCommentController.create)
router.get('/', productCommentController.getAll)
router.get('/:id', productCommentController.getOne)
router.put('/:id', productCommentController.update)
router.delete('/:id', productCommentController.delete)

module.exports = router