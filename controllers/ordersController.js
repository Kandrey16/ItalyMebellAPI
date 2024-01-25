const {Orders} = require("../models");
const ApiError = require("../error/ApiError");

class OrdersController {
    async create(req, res, next) {
        try {

            const {number_order, price_order, date_order, id_order_address} = req.body
            const order = await Orders.create({number_order, price_order, date_order, id_order_address})
            return res.json({order})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const orders = await Orders.findAll()
        return res.json(orders)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const orders = await Orders.findByPk(id);

            if (!orders) {
                return next(ApiError.badRequest(`Order with id ${id} not found`));
            }

            return res.json(orders);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {id} = req.params
            const {number_order, price_order, date_order, id_order_address} = req.body
            const order = await Orders.findByPk(id)

            if(!order) {
                return next(ApiError.badRequest({message: `Order with id ${id} not found`}))
            }

            await order.update({number_order, price_order, date_order, id_order_address})
            return res.json(order)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async delete(req, res, next) {
        try {
            const {id} = req.params
            const order = await Orders.findByPk(id)

            if(!order) {
                return next(ApiError.badRequest({message: `Order with id ${id} not found`}))
            }

            await order.destroy()
            return res.json({ message: 'Order deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

}

module.exports = new OrdersController()