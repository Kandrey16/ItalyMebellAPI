const { Order_delivery } = require('../models/association')
const ApiError = require('../error/ApiError')

class OrderDeliveryController {
    async create(req, res, next) {
        try {
            const { name_order_delivery, price_order_delivery } = req.body;
            const orderDelivery = await Order_delivery.create({ name_order_delivery, price_order_delivery });
            return res.json(orderDelivery);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async getAll(req, res) {
        try {
            const orderDeliveries = await Order_delivery.findAll();
            return res.json(orderDeliveries);
        } catch (e) {
            res.status(500).send(e.message);
        }
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const orderDelivery = await Order_delivery.findByPk(id);

            if (!orderDelivery) {
                return next(ApiError.badRequest(`Order delivery with id ${id} not found`));
            }

            return res.json(orderDelivery);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const { id } = req.params;
            const { name_order_delivery, price_order_delivery } = req.body;
            const orderDelivery = await Order_delivery.findByPk(id);

            if (!orderDelivery) {
                return next(ApiError.badRequest(`Order delivery with id ${id} not found`));
            }

            await orderDelivery.update({ name_order_delivery, price_order_delivery });
            return res.json(orderDelivery);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async delete(req, res, next) {
        try {
            const { id } = req.params;
            const orderDelivery = await Order_delivery.findByPk(id);

            if (!orderDelivery) {
                return next(ApiError.badRequest(`Order delivery with id ${id} not found`));
            }

            await orderDelivery.destroy();
            return res.json({ message: 'Order delivery deleted successfully' });
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }
}

module.exports = new OrderDeliveryController();