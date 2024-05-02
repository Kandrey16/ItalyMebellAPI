const { Payment_method } = require('../models/association')
const ApiError = require('../error/ApiError')

class PaymentMethodController {
    async create(req, res, next) {
        try {
            const { name_payment_method } = req.body;
            const paymentMethod = await Payment_method.create({ name_payment_method });
            return res.json(paymentMethod);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async getAll(req, res) {
        try {
            const paymentMethods = await Payment_method.findAll();
            return res.json(paymentMethods);
        } catch (e) {
            res.status(500).send(e.message);
        }
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const paymentMethod = await Payment_method.findByPk(id);

            if (!paymentMethod) {
                return next(ApiError.badRequest(`Payment Method with id ${id} not found`));
            }

            return res.json(paymentMethod);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const { id } = req.params;
            const { name_payment_method } = req.body;
            const paymentMethod = await Payment_method.findByPk(id);

            if (!paymentMethod) {
                return next(ApiError.badRequest(`Payment Method with id ${id} not found`));
            }

            await paymentMethod.update({ name_payment_method });
            return res.json(paymentMethod);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async delete(req, res, next) {
        try {
            const { id } = req.params;
            const paymentMethod = await Payment_method.findByPk(id);

            if (!paymentMethod) {
                return next(ApiError.badRequest(`Payment Method with id ${id} not found`));
            }

            await paymentMethod.destroy();
            return res.json({ message: 'Payment Method deleted successfully' });
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }
}

module.exports = new PaymentMethodController();