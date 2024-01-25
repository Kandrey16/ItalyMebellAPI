const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const Order_product = sequelize.define('order_product', {
    id_order_product: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    count_order_product: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
})

module.exports = Order_product;
