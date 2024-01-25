const Router = require('express')
const router = new Router()
const user_profileController = require('../controllers/user_profileController')
const authMiddleware = require('../middleware/authMiddleware')

router.post('/registration', user_profileController.registration)
router.post('/login', user_profileController.login)
router.get('/auth', authMiddleware, user_profileController.check)
router.get("/", user_profileController.getAll)

module.exports = router