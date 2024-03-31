const {Order_address, Orders, Order_product} = require("../models/association");
const sequelize  = require('../db')
const ApiError = require("../error/ApiError");

class OrdersController {
    async create(req, res, next) {
        const t = await sequelize.transaction();
        try {
            const { order, address, products } = req.body; // Предполагаем, что в теле запроса есть данные заказа, адреса и продуктов

            // Создаем адрес заказа
            const order_address = await Order_address.create(address, { transaction: t });

            // Создаем заказ с id адреса
            const createdOrder = await Orders.create({...order, id_order_address: order_address.id_order_address}, { transaction: t });

            // Создаем продукты заказа
            for (const product of products) {
                await Order_product.create({...product, id_order: createdOrder.id_order}, { transaction: t });
            }

            await t.commit();
            return res.json({ order: createdOrder, address: order_address, products: products });
        } catch (e) {
            await t.rollback();
            next(ApiError.badRequest(e.message));
        }
    }
    // async create(req, res, next) {
    //     const t = await sequelize.transaction();
    //     try {
    //
    //         const {number_order, price_order, date_order, id_order_address} = req.body
    //         const order = await Orders.create({number_order, price_order, date_order, id_order_address})
    //         return res.json({order})
    //     } catch (e) {
    //         next(ApiError.badRequest(e.message))
    //     }
    // }

    async getAll(req, res) {
        const orders = await Orders.findAll({
            include: [
                { model: Order_address, as: 'order_address' }, // Замените 'order_address' на имя связи, если оно отличается
                { model: Order_product, as: 'order_product' }  // Замените 'order_products' на имя связи, если оно отличается
            ]
        });
        return res.json(orders);
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const order = await Orders.findByPk(id, {
                include: [
                    { model: Order_address, as: 'order_address' }, // Замените 'order_address' на имя связи, если оно отличается
                    { model: Order_product, as: 'order_product' }  // Замените 'order_products' на имя связи, если оно отличается
                ]
            });

            if (!order) {
                return next(ApiError.badRequest(`Order with id ${id} not found`));
            }

            return res.json(order);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        const { id } = req.params; // ID заказа для обновления
        const { order, address, products } = req.body; // Обновленные данные для заказа, адреса и продуктов

        const t = await sequelize.transaction();
        try {
            // Находим заказ по PK и обновляем его
            const foundOrder = await Orders.findByPk(id, { transaction: t });
            if (!foundOrder) throw new Error(`Order with ID ${id} not found`);

            await foundOrder.update(order, { transaction: t });

            // Находим адрес заказа и обновляем его
            if (address && address.id_order_address) {
                const foundAddress = await Order_address.findByPk(address.id_order_address, { transaction: t });
                if (!foundAddress) throw new Error(`Order address with ID ${address.id_order_address} not found`);

                await foundAddress.update(address, { transaction: t });
            }

            // Находим и обновляем продукты заказа, если предоставлены
            if (products && Array.isArray(products)) {
                for (const product of products) {
                    const foundProduct = await Order_product.findByPk(product.id_order_product, { transaction: t });
                    if (!foundProduct) throw new Error(`Order product with ID ${product.id_order_product} not found`);

                    await foundProduct.update(product, { transaction: t });
                }
            }

            await t.commit();
            return res.json({ message: `Order with ID ${id} updated successfully` });
        } catch (e) {
            await t.rollback();
            next(ApiError.badRequest(e.message));
        }
    }

    async delete(req, res, next) {
        const { id } = req.params; // ID заказа для удаления

        const t = await sequelize.transaction();
        try {
            // Находим и удаляем все продукты заказа
            const orderProducts = await Order_product.findAll({ where: { id_order: id }, transaction: t });
            for (const product of orderProducts) {
                await product.destroy({ transaction: t });
            }

            // Находим и удаляем заказ
            const order = await Orders.findByPk(id, { transaction: t });
            if (!order) throw new Error(`Order with ID ${id} not found`);

            await order.destroy({ transaction: t });

            await t.commit();
            return res.json({ message: `Order with ID ${id} deleted successfully` });
        } catch (e) {
            await t.rollback();
            next(ApiError.badRequest(e.message));
        }
    }

}

module.exports = new OrdersController()