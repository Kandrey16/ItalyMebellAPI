// Подключение необходимых модулей
const cookieParser = require('cookie-parser'); // Модуль для работы с куками
const csrf = require('csurf'); // Модуль для генерации и проверки CSRF-токенов
const bodyParser = require('body-parser'); // Модуль для разбора данных из запросов
const express = require('express'); // Фреймворк для создания веб-приложений
const cors = require('cors'); // Модуль для обработки запросов CORS

// Создание экземпляра CSRF-защиты с использованием куков
const csrfProtection = csrf({ cookie: true });
// Создание middleware для разбора формы
const parseForm = bodyParser.urlencoded({ extended: false });
// Опции CORS, указывающие на источник запросов и разрешающие передачу кук
const corsOptions = {
    origin: "http://localhost:5173", // Разрешенный источник запросов
    credentials: true, // Разрешение передачи кук в запросах
};
// Создание экземпляра Express для middleware CSRF
const csrfMiddleware = express();
// Использование CORS middleware с определенными опциями
csrfMiddleware.use(cors(corsOptions));
// Использование cookie-parser middleware для разбора кук
csrfMiddleware.use(cookieParser());
// Регистрация маршрута для обработки GET запроса на получение CSRF-токена
csrfMiddleware.get('/form', csrfProtection, (req, res) => {
    // Отправка ответа с CSRF-токеном
    res.send({ csrfToken: req.csrfToken() });
});
// Регистрация маршрута для обработки POST запроса с CSRF-защитой
csrfMiddleware.post('/process', parseForm, csrfProtection, (req, res) => {
    // Отправка ответа о том, что данные обрабатываются
    res.send('data is being processed');
});

// Экспорт middleware CSRF
module.exports = csrfMiddleware;
