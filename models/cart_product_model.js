const sequelize = require('../db')
const { DataTypes} = require('sequelize')

const Cart_product = sequelize.define('cart_product', {
    id_cart_product: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },
})

module.exports = Cart_product;