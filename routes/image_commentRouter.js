const Router = require('express')
const imageCommentController = require("../controllers/image_commentController");
const router = new Router()

router.post('/', imageCommentController.create)
router.get('/', imageCommentController.getAll)
router.get('/:id', imageCommentController.getOne)
router.put('/:id', imageCommentController.update)
router.delete('/:id', imageCommentController.delete)

module.exports = router