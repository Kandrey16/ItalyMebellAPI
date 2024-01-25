const {Order_address} = require("../models");
const ApiError = require("../error/ApiError");

class Order_addressController {
    async create(req, res, next) {
        try {
            const {address_order, entrance_order, floor_order, home_code_order, email_user} = req.body
            const order_address = await Order_address.create({address_order, entrance_order, floor_order, home_code_order, email_user})
            return res.json({order_address})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const order_addresses = await Order_address.findAll()
        return res.json(order_addresses)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const order_address = await Order_address.findByPk(id);

            if (!order_address) {
                return next(ApiError.badRequest(`Order Address with id ${id} not found`));
            }

            return res.json(order_address);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {id} = req.params
            const {address_order, entrance_order, floor_order, home_code_order, email_user} = req.body
            const order_address = await Order_address.findByPk(id)

            if(!order_address) {
                return next(ApiError.badRequest({message: `Order Address with id ${id} not found`}))
            }

            await order_address.update({address_order, entrance_order, floor_order, home_code_order, email_user})
            return res.json(order_address)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async delete(req, res, next) {
        try {
            const {id} = req.params
            const order_address = await Order_address.findByPk(id)

            if(!order_address) {
                return next(ApiError.badRequest({message: `Order Address with id ${id} not found`}))
            }

            await order_address.destroy()
            return res.json({ message: 'Order Address deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

}

module.exports = new Order_addressController()