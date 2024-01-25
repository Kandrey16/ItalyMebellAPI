const {Order_product} = require("../models");
const ApiError = require("../error/ApiError");

class Order_productController {
    async create(req, res, next) {
        try {

            const {count_order_product, id_order, id_product} = req.body
            const order_product = await Order_product.create({count_order_product, id_order, id_product})
            return res.json({order_product})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const order_products = await Order_product.findAll()
        return res.json(order_products)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const order_product = await Order_product.findByPk(id);

            if (!order_product) {
                return next(ApiError.badRequest(`Order product with id ${id} not found`));
            }

            return res.json(order_product);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {id} = req.params
            const {count_order_product, id_order, id_product} = req.body
            const order_product = await Order_product.findByPk(id)

            if(!order_product) {
                return next(ApiError.badRequest({message: `Order product with id ${id} not found`}))
            }

            await order_product.update({count_order_product, id_order, id_product})
            return res.json(order_product)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async delete(req, res, next) {
        try {
            const {id} = req.params
            const order_product = await Order_product.findByPk(id)

            if(!order_product) {
                return next(ApiError.badRequest({message: `Order product with id ${id} not found`}))
            }

            await order_product.destroy()
            return res.json({ message: 'Order product deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

}

module.exports = new Order_productController()