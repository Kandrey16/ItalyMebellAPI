const Router = require('express');
const router = new Router();
const attributeGroupController = require('../controllers/attribute_groupController');
const check = require("../middleware/checkRoleMiddleware");


router.post('/', check('ADMIN'), attributeGroupController.create);
router.get('/', attributeGroupController.getAll);
router.get('/:id', attributeGroupController.getOne);
router.put('/:id', check('ADMIN'), attributeGroupController.update);
router.delete('/:id', check('ADMIN'), attributeGroupController.delete);

module.exports = router;
