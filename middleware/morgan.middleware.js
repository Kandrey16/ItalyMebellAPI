const morgan = require("morgan");
const logger = require("../utils/logger");

const stream = {
    write: (message) => logger.http(message),// Запись сообщения в лог HTTP
}

const skip = () => {
    const env = process.env.NODE_ENV || "development";
    return env !== "development"; // Пропустить, если окружение не является "development"
};

// Определение формата строки сообщения
const morganMiddleware = morgan(
    ":remote-addr :method :url :status :res[content-length] - :response-time ms",
    { stream, skip }
);

module.exports = morganMiddleware;