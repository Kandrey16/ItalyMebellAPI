const Router = require('express')
const router = new Router()

const attribute_groupRouter = require('./attribute_groupRouter')
const attributeRouter = require('./attributeRouter')
const image_commentRouter = require('./image_commentRouter')
const order_addressRouter = require('./order_addressRouter')
const order_productRouter = require('./order_productRouter')
const ordersRouter = require('./ordersRouter')
const product_commentRouter = require('./product_commentRouter')
const product_imageRouter = require('./product_imageRouter')
const productRouter = require('./productRouter')
const specificationRouter = require('./specificationRouter')
const user_profileRouter = require('./user_profileRouter')


router.use('/attribute', attributeRouter)
router.use('/attribute_group', attribute_groupRouter)
router.use('/image_comment', image_commentRouter)
router.use('/order_address', order_addressRouter)
router.use('/order_product', order_productRouter)
router.use('/orders', ordersRouter)
router.use('/product_comment', product_commentRouter)
router.use('/product_image', product_imageRouter)
router.use('/product', productRouter)
router.use('/specification', specificationRouter)
router.use('/user_profile', user_profileRouter)

module.exports = router