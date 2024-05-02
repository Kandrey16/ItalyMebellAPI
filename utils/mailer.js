const nodemailer = require('nodemailer');
const logger = require('./logger')
// Настройки почтового клиента
const transporter = nodemailer.createTransport({
    host: "smtp.mail.ru",
    port: 465, // Защищенный порт SSL
    secure: true, // Используйте `true`, так как порт 465 предполагает защищенное (SSL) соединение
    auth: {
        user: process.env.MAILRU_EMAIL, // Ваша почта на Mail.ru
        pass: process.env.MAILRU_APP_PASSWORD // Пароль для внешнего приложения
    }
});

logger.debug('Проверьте, что параметры аутентификации указаны правильно'); // Отладка конфигурации

const sendOrderDetailsEmail = async (email, orderDetails) => {
    try {
        logger.debug(`Начинается отправка сообщения на адрес: ${email}`); // Отладка вызова функции
        let emailText = `Информация по вашему заказу:\n\n`;
        for (const product of orderDetails.products) {
            emailText += `Продукт: ${product.name_product}, Количество: ${product.count_order_product}\n 
            Общая сумма заказа: ${orderDetails.order.price_order}\n 
            Адрес доставки: ${orderDetails.address.address_order}`;
        }
        emailText += `\nОбщая сумма заказа: ${orderDetails.order.price_order}`;

        const mailOptions = {
            from: `"Магазин ItalyMebell" <${process.env.MAILRU_EMAIL}>`,
            to: email,
            subject: `Заказ №${orderDetails.order.number_order} подтвержден`,
            html: `
                <html>
                  <head>
                    <style>
                      .product-info {
                        color: #333333;
                        font-size: 16px;
                        font-family: Arial, sans-serif;
                      }
                      .product-info h1 {
                        color: #000;
                        margin-bottom: 20px;
                      }
                      .product-info p {
                        margin: 5px 0;
                      }
                      /* Можно добавить дополнительные стили */
                    </style>
                  </head>
                  <body>
                    <div class="product-info">
                      <h1>Информация о вашем заказе №${orderDetails.order.number_order}</h1>
                      ${orderDetails.products.map(product => `
                        <p>Продукт: ${product.name_product}, Количество: ${product.count_order_product}</p>
                      `).join('')}
                      <p>Общая сумма заказа: ${orderDetails.order.price_order} руб.</p>
                      <p>Адрес доставки: ${orderDetails.address.address_order}</p>
                      <!-- Здесь могут быть другие детали заказа -->
                    </div>
                  </body>
                </html>
              `
        };

        logger.debug(`Опции письма: ${JSON.stringify(mailOptions)}`); // Отладка опций отправки сообщения

        let info = await transporter.sendMail(mailOptions);
        logger.debug("Message sent: %s", info.messageId); // Отладка успешной отправки

        // Этот блок выполнится, если сообщение было отправлено без ошибок
        logger.debug(`Сообщение было успешно отправлено: ${info.response}`);
    } catch (error) {
        logger.error(`Ошибка при отправке email: ${error.message}`); // Отладка ошибок при отправке
        console.error(error);
    }
};

const sendConfirmationCodeEmail = async(email_user, code) => {
    try {
        logger.debug(`Начинается отправка кода подтверждения на адрес: ${email_user}`)

        const mailOptions = {
            from: `"Магазин ItalyMebell" <${process.env.MAILRU_EMAIL}>`,
            to: email_user,
            subject: `Ваш код подтверждения смены пароля`,
            html: `
                <p>Здравствуйте,</p>
                <p>Ваш код подтверждения для смены пароля: <b>${code}</b></p>
                <p>Если вы не запрашивали смену пароля, проигнорируйте это письмо.</p>
            `
        };

        let info = await transporter.sendMail(mailOptions)
        logger.debug("Message sent: %s", info.messageId); // Отладка успешной отправки

        logger.debug(`Код подтверждения был успешно отправлен: ${info.response}`);
    } catch (e) {
        logger.error(`Ошибка при отправке кода подтверждения: ${e.message}`);
    }
}

module.exports = {
    sendOrderDetailsEmail,
    sendConfirmationCodeEmail
};