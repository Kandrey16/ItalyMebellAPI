//index.js
require('dotenv').config()
// const swaggerJsdoc = require('swagger-jsdoc');
// const swaggerUi = require('swagger-ui-express');
//
// const options = {
//     definition: {
//         openapi: '3.0.0',
//         info: {
//             title: 'Express API с Swagger',
//             version: '1.0.0',
//         },
//     },
//     // Укажите путь до файлов API
//     apis: ['./routes/*.js'],
// };
// // Инициализируйте документацию
// const specs = swaggerJsdoc(options);

const express = require('express')
const sequelize = require('./db')
const models = require('./models/index.js')
const fileUpload = require('express-fileupload')
const router = require('./routes/index.js')
const cors = require('cors')
const errorHandler = require('./middleware/ErrorHandlingMiddleware')
const path = require('path')

const PORT = process.env.PORT || 5000
const app = express()

app.use(cors())
// app.use('/api-docs', swaggerUi.serve, swaggerUi.setup(specs));
app.use(express.json())
app.use(fileUpload({}))
app.use('/api', router)
app.use(errorHandler)
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