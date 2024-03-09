const sequelize = require('../db')
const { DataTypes} = require('sequelize')

const Cart = sequelize.define('cart', {
    id_cart: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },
})

module.exports = Cart;