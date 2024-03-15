const sequelize = require('../db')
const { DataTypes} = require('sequelize')

const Cart_product = sequelize.define('cart_product', {
    id_cart_product: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },
    count_cart_product: {
        type: DataTypes.INTEGER,
        allowNull: false,
        defaultValue: 0,
    }
})

module.exports = Cart_product;