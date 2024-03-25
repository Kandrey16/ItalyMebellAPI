require('dotenv').config()
const winston = require('winston')
const PostgresTransport = require('winston-postgres-transport');

let connString = `postgres://${process.env.DB_USER}:${process.env.DB_PASSWORD}@${process.env.DB_HOST}:${process.env.DB_PORT}/${process.env.DB_NAME}`;

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
    // Определить формат сообщения, показывающего метку времени, уровень и сообщение
    winston.format.printf(
        (info) => `${info.timestamp} ${info.level}: ${info.message}`,
    ),
)

const postgresTransport = new PostgresTransport({
    level: 'info',
    name: 'Postgres',
    postgresOptions: {
        // Is called with (connection, query, params)
        debug: console.log,
    },
    postgresUrl: connString,
    tableName: 'winston_logs',
});

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
    postgresTransport,
]

// Создание логгера
const logger = winston.createLogger({
    level: level(),
    levels,
    format,
    transports,
})

module.exports = logger