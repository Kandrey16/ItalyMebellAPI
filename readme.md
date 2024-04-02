{
    "order": {
        "number_order": 123,
        "price_order": 49.99,
        "date_order": "2023-04-04"
    },
    "address": {
        "address_order": "Улица Пример 123",
        "entrance_order": 1,
        "floor_order": 5,
        "home_code_order": "ABC123"
    },
    "products": [
        {
            "count_order_product": 2,
            "id_cart_product": 111
        }
    ]
}




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