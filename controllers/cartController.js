const {  Cart, Cart_product, Product} = require('../models/association')
const ApiError = require('../error/ApiError')

class CartController {

    async createCart(req, res, next) {
        try {
            const { email_user } = req.body
            const cart = await Cart.findOne({ where: { email_user } })
            if (cart) {
                return res.status(400).json({ message: 'Cart already exists for this user' })
            }
            await Cart.create({ email_user })
            return res.json({ message: 'Cart created successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
    async addToCart(req, res, next) {
        try {
            const { id_product, email_user } = req.body
            const cart = await Cart.findOne({ where: { email_user } })
            if (!cart) {
                return res.status(400).json({ message: 'Cart does not exist for this user' })
            }
            let cartProduct = await Cart_product.findOne({ where: { id_cart: cart.id_cart, id_product } })
            if (cartProduct) {
                cartProduct.count_cart_product += 1
                await cartProduct.save()
            } else {
                cartProduct = await Cart_product.create({ id_cart: cart.id_cart, id_product, count_cart_product: 1 })
            }
            return res.json({cartProduct})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async updateCartItem(req, res, next) {
        try {
            const { id } = req.params;
            const { count_cart_product } = req.body; // Предполагается, что вы хотите обновить только количество товаров в корзине
            const cartProduct = await Cart_product.findByPk(id);

            if (!cartProduct) {
                return next(ApiError.badRequest({ message: `Cart Product with id ${id} not found` }));
            }

            await cartProduct.update({ count_cart_product }); // Обновляем только количество товаров в корзине
            return res.json(cartProduct);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async removeFromCart(req, res, next) {
        try {
            const {id} = req.params
            const cart_product = await Cart_product.findByPk(id)

            if(!cart_product) {
                return next(ApiError.badRequest({message: `Cart Product with id ${id} not found`}))
            }

            await cart_product.destroy()
            return res.json({ message: 'Product removed from cart successfully'})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
    
    async getCart(req, res, next) {
        try {
            const { email_user } = req.params
            const cart = await Cart.findOne({
                where: { email_user },
                include: {
                    model: Cart_product,
                    include: [Product]
                },
            })
            return res.json({cart})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
}

module.exports = new CartController()
