const excel = require('exceljs');
const ordersController = require("../controllers/ordersController");
const productController = require('../controllers/productController');

async function exportOrderToExcel(orderId) {
    try {
        const workbook = new excel.Workbook(); // Create a new Excel workbook
        const worksheet = workbook.addWorksheet('Информация о заказе'); // Add a new worksheet
        worksheet.columns = [
            { header: 'ID заказа', key: 'orderId', width: 10 },
            { header: 'Номер', key: 'orderNumber', width: 15 },
            { header: 'Цена', key: 'price', width: 10 },
            { header: 'Дата', key: 'orderDate', width: 20 },
            { header: 'Оплата', key: 'paymentMethod', width: 20 },
            { header: 'Статус', key: 'orderStatus', width: 20 },
            { header: 'Способ доставки', key: 'deliveryMethod', width: 20 },
            { header: 'Почта', key: 'email', width: 20 },
            { header: 'Адрес', key: 'address', width: 20 },
            { header: 'ID товара', key: 'productId', width: 10 }, // New columns for product data
            { header: 'Название', key: 'productName', width: 15 },
            { header: 'Артикул', key: 'productArticle', width: 10 },
            { header: 'Цена товара', key: 'productPrice', width: 20 }
        ];

        let orderData = await ordersController.getOrderData(orderId);

        if (orderData) {
            const {
                id_order,
                number_order,
                price_order,
                date_order,
                order_address,
                payment_method,
                order_status,
                order_delivery,
                order_product
            } = orderData.dataValues;

            worksheet.addRow({
                orderId: id_order,
                orderNumber: number_order,
                price: price_order,
                orderDate: date_order,
                paymentMethod: payment_method.dataValues.name_payment_method,
                orderStatus: order_status.dataValues.name_order_status,
                deliveryMethod: order_delivery.dataValues.name_order_delivery,
                email: order_address.dataValues.email_user,
                address: order_address.dataValues.address_order
            });

            // Fetch and populate product data for each product in the order
            for (const productData of order_product) {
                const productId = productData.dataValues.id_product;
                const product = await productController.getProductData(productId);

                worksheet.addRow({
                    productId: productId,
                    productName: product.dataValues.name_product,
                    productArticle: product.dataValues.article_product,
                    productPrice: product.dataValues.price_product
                });
            }
        } else {
            throw new Error('No order found with the provided ID');
        }

        // Return the workbook instance
        return workbook;
    } catch (e) {
        throw e; // Re-throw the error to handle it in the calling code
    }
}

module.exports = { exportOrderToExcel };
