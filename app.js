//app.js
require('dotenv').config()
const express = require('express')
const sequelize = require('./db')
const models = require('./models/index.js')
const cors = require('cors')
const fileUpload = require('express-fileupload')
const path = require('path')
const router = require('./routes/index.js')
const swaggerUi = require('swagger-ui-express');
const swaggerDocs = require('./swagger_output.json');

// const csrfMiddleware = require('./middleware/csrfMiddleware'); // Подключаем middleware для CSRF-токена
const errorHandler = require('./middleware/ErrorHandlingMiddleware')
const metricsMiddleWare = require('./middleware/metricsMiddleware')
const morganMiddleware = require('./middleware/morgan.middleware')
const logger = require('./utils/logger')

const PORT = process.env.PORT || 5000
const app = express()

app.use(cors())
app.use(express.json())
app.use(express.static(path.resolve(__dirname, 'static')))
app.use(fileUpload({}))
app.use('/api', router)
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));

// app.use(csrfMiddleware); // Используем middleware для CSRF-токена
app.use(errorHandler)
app.use(metricsMiddleWare)
app.use(morganMiddleware)

const start = async () => {
    try {
        await sequelize.authenticate()
        await sequelize.sync()
        app.listen(PORT, () => {
            console.log(`Server started on PORT ${PORT}...`)
            logger.info(`Server started on PORT ${PORT}...`)
        })
    } catch (err) {
        console.log(err)
        logger.error(err)
    }
}

start()