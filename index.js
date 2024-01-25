//index.js
require('dotenv').config()
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

app.use(express.json())
app.use(express.static(path.resolve(__dirname, 'static')))
app.use('/api', router)
app.use(fileUpload({}))
app.use(cors())
app.use(errorHandler)

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