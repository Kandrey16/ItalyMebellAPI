//app.js
require('dotenv').config()
const express = require('express')

const swaggerUi = require('swagger-ui-express');

// const csrfMiddleware = require('./middleware/csrfMiddleware'); // Подключаем middleware для CSRF-токена

const sequelize = require('./db')
const models = require('./models/index.js')
const fileUpload = require('express-fileupload')
const router = require('./routes/index.js')
const cors = require('cors')
const errorHandler = require('./middleware/ErrorHandlingMiddleware')
const metricsMiddleWare = require('./middleware/metricsMiddleware')
const path = require('path')

const PORT = process.env.PORT || 5000
const app = express()

const swaggerDocs = require('./swagger_output.json');

app.use(cors())
app.use(express.json())
app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(swaggerDocs));
app.use(fileUpload({}))

// app.use(csrfMiddleware); // Используем middleware для CSRF-токена

app.use('/api', router)
app.use(errorHandler)
app.use(metricsMiddleWare)
app.use(express.static(path.resolve(__dirname, 'static')))


const start = async () => {
    try {
        await sequelize.authenticate()
        await sequelize.sync()
        app.listen(PORT, () => console.log(`Server started on PORT ${PORT}...`))

    } catch (err) {
        console.log(err)
    }
}

start()