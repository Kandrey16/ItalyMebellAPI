const {Order_address, Orders, Order_product, Cart, Cart_product, Payment_method, Product, Order_delivery, Order_status} = require("../models/association");
const sequelize  = require('../db')
const ApiError = require("../error/ApiError");
const {sendOrderDetailsEmail } = require('../utils/mailer')
const logger = require("../utils/logger");
const excel = require('exceljs')
const fs = require('fs')

class OrdersController {
    async create(req, res, next) {
        const t = await sequelize.transaction();
        try {
            const { order, address, products, payment_method, order_delivery, order_status } = req.body; // Предполагаем, что в теле запроса есть данные заказа, адреса и продуктов
            // Создаем адрес заказа
            const order_address = await Order_address.create(address, { transaction: t });
            // Создаем заказ с id адреса
            const createdOrder = await Orders.create({...order, id_order_address: order_address.id_order_address, id_payment_method: payment_method.id_payment_method, id_order_delivery: order_delivery.id_order_delivery, id_order_status: order_status.id_order_status}, { transaction: t });

            if (!address.email_user) {
                throw new Error(`email_user is missing from the address object`);
            }

            // Создаем продукты заказа
            for (const product of products) {
                // Здесь добавлен поиск соответствующего id_product на основе id_cart_product
                const cartProduct = await Cart_product.findOne({
                    where: { id_cart_product: product.id_cart_product }
                });

                if (!cartProduct) {
                    throw new Error(`Cart product with id ${product.id_cart_product} not found`);
                }

                await Order_product.create({
                    count_order_product: product.count_order_product,
                    id_order: createdOrder.id_order,
                    id_product: cartProduct.id_product
                }, { transaction: t });

                const productToUpdate = await Product.findByPk(cartProduct.id_product);

                if (productToUpdate) {
                    productToUpdate.count_product -= product.count_order_product
                    // Проверка на отрицательное значение
                    if (productToUpdate.count_product < 0) {
                        throw new Error(`Not enough product in stock for ${productToUpdate.name_product}`);
                    }
                    // Сохраняем обновленные данные продукта
                    await productToUpdate.save({transaction: t});
                } else {
                    throw new Error(`Product with id ${cartProduct.id_product} not found`);
                }
            }

            // Очистка корзины после создания заказа
            const userCart = await Cart.findOne({
                where: { email_user: address.email_user }
            });

            if (userCart) {
                await Cart_product.destroy({
                    where: {id_cart: userCart.id_cart},
                    transaction: t
                });
            }

            await t.commit();

            const orderDetails = {
                order: createdOrder,
                address: order_address,
                products: products.map(p => ({
                    name_product: p.name_product, // предполагаем, что имя продукта приходит в теле запроса
                    count_order_product: p.count_order_product
                })),
                payment_method,
                order_delivery,
                order_status,
            };

            await sendOrderDetailsEmail(orderDetails.address.email_user, orderDetails);

            return res.json({ order: createdOrder, address: order_address, products: products, payment_method: payment_method, order_delivery: order_delivery, order_status: order_status });
        } catch (e) {
            await t.rollback();
            next(ApiError.badRequest(e.message));
        }
    }

    async getAll(req, res) {
        const { email_user } = req.query;

        try {
            const orders = await Orders.findAll({
                include: [{
                    model: Order_address,
                    as: 'order_address',
                    where: email_user ? { email_user: email_user } : undefined, // Фильтрация по Order_address.email_user
                }, {
                    model: Order_product,
                    as: 'order_product'
                }]
            });
            return res.json(orders);
        } catch (error) {
            console.error('Ошибка при получении заказов:', error);
            return res.status(500).json({ message: 'Ошибка на сервере при получении списка заказов.' });
        }
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const order = await Orders.findByPk(id, {
                include: [
                    { model: Order_address, as: 'order_address' },
                    { model: Order_product, as: 'order_product' },
                    // { model: Payment_method, as: 'payment_method' },
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
    async getOrderData(id) {
        const order = await Orders.findByPk(id, {
            include: [
                {
                    model: Order_address,
                    as: 'order_address'
                },
                {
                    model: Order_product,
                    as: 'order_product'
                },
                {
                    model: Payment_method,
                    as: 'payment_method'
                },
                {
                    model: Order_status,
                    as: 'order_status'
                },
                {
                    model: Order_delivery,
                    as: 'order_delivery'
                }
            ]
        });

        if (!order) {
            throw new Error(`Order with id ${id} not found`);
        }
        return order;
    }
    async update(req, res, next) {
        const { id } = req.params; // ID заказа для обновления
        const { order, address, products, id_payment_method, id_order_delivery, id_order_status } = req.body; // Расширьте данные для обновления

        const t = await sequelize.transaction();
        try {
            // Находим заказ по PK и обновляем его
            const foundOrder = await Orders.findByPk(id, { transaction: t });
            if (!foundOrder) throw new Error(`Order with ID ${id} not found`);

            await foundOrder.update({
                ...order,
                id_payment_method: id_payment_method,
                id_order_delivery: id_order_delivery,
                id_order_status: id_order_status
            }, { transaction: t });

            // Получаем обновленный заказ
            const updatedOrder = await Orders.findByPk(id, { transaction: t });
            if (!updatedOrder) throw new Error('Error fetching updated order');

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
                    logger.debug("Updated product data:", product); // Добавлено: логирование обновленных данных продукта
                }
            }

            await t.commit();
            // Передача данных обновленного заказа в ответ
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