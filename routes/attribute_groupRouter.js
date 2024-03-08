const Router = require('express');
const router = new Router();
const attributeGroupController = require('../controllers/attribute_groupController');
const check = require("../middleware/checkRoleMiddleware");


router.post('/', attributeGroupController.create);
router.get('/', attributeGroupController.getAll);
router.get('/:id', attributeGroupController.getOne);
router.put('/:id', attributeGroupController.update);
router.delete('/:id', attributeGroupController.delete);

module.exports = router;
