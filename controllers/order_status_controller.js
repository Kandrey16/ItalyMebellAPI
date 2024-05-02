const { Order_status } = require('../models/association')
const ApiError = require('../error/ApiError')

class OrderStatusController {
    async create(req, res, next) {
        try {
            const { name_order_status } = req.body;
            const orderStatus = await Order_status.create({ name_order_status });
            return res.json(orderStatus);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async getAll(req, res) {
        try {
            const orderStatuses = await Order_status.findAll();
            return res.json(orderStatuses);
        } catch (e) {
            res.status(500).send(e.message);
        }
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const orderStatus = await Order_status.findByPk(id);

            if (!orderStatus) {
                return next(ApiError.badRequest(`Order status with id ${id} not found`));
            }

            return res.json(orderStatus);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const { id } = req.params;
            const { name_order_status } = req.body;
            const orderStatus = await Order_status.findByPk(id);

            if (!orderStatus) {
                return next(ApiError.badRequest(`Order status with id ${id} not found`));
            }

            await orderStatus.update({ name_order_status });
            return res.json(orderStatus);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async delete(req, res, next) {
        try {
            const { id } = req.params;
            const orderStatus = await Order_status.findByPk(id);

            if (!orderStatus) {
                return next(ApiError.badRequest(`Order status with id ${id} not found`));
            }

            await orderStatus.destroy();
            return res.json({ message: 'Order status deleted successfully' });
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }
}

module.exports = new OrderStatusController();