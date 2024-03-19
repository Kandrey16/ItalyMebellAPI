require('dotenv').config()
const winston = require('winston')
const PostgreSQL = require('winston-postgresql').PostgreSQL;

// Уровни логирования
const levels = {
    error: 0,
    warn: 1,
    info: 2,
    http: 3,
    debug: 4,
}

const level = () => {
    const env = process.env.NODE_ENV || 'development'
    const isDevelopment = env === 'development'
    return isDevelopment ? 'debug' : 'warn' // Вернуть уровень логирования в зависимости от окружения
}

// Цвета для уровней логирования
const colors = {
    error: 'red',
    warn: 'yellow',
    info: 'green',
    http: 'magenta',
    debug: 'white',
}

winston.addColors(colors)

const format = winston.format.combine(
    // Добавить метку времени сообщения с предпочтительным форматом
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss:ms' }),
    // Сообщить Winston, что логи должны быть цветными
    winston.format.colorize({ all: true }),
    // Определить формат сообщения, показывающего метку времени, уровень и сообщение
    winston.format.printf(
        (info) => `${info.timestamp} ${info.level}: ${info.message}`,
    ),
)

const transports = [
    // Отправка сообщений в консоль
    new winston.transports.Console(),
    // Отправка сообщений в файл error.log
    new winston.transports.File({
        filename: 'logs/error.log',
        level: 'error',
    }),
    // Отправка сообщений в файл warning.log
    new winston.transports.File({
        filename: 'logs/warning.log',
        level: 'warn',
    }),
    // Отправка сообщений в файл debug.log
    new winston.transports.File({
        filename: 'logs/debug.log',
        level: 'debug',
    }),
    // Отправка сообщений в файл all.log
    new winston.transports.File({ filename: 'logs/all.log' }),
]

let connString =
    `postgres://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}`;

let postgresTransport = new PostgreSQL({
    ssl: false,
    timestamp: true,
    connString: connString,
    tableName: 'logs'
});

// Обработка ошибок при создании подключения
postgresTransport.on('error', function(err) {
    console.error('Ошибка при подключении к базе данных:', err);
});

// winston.add(postgresTransport);

// Пример использования логирования
winston.info('Это тестовое сообщение для лога в PostgreSQL');

// Создание логгера
const logger = winston.createLogger({
    level: level(),
    levels,
    format,
    transports,
    postgresTransport,
})

// try {
//     throw new Error('This is a simulated error');
// } catch (error) {
//     logger.error(error.toString());
// }


module.exports = logger