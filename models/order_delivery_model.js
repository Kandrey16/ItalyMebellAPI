const sequelize = require("../db");
const { DataTypes } = require("sequelize");

const OrderDelivery = sequelize.define('order_delivery', {
    id_order_delivery: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    name_order_delivery: {
        type: DataTypes.STRING,
        allowNull: false
    },
    price_order_delivery: {
        type: DataTypes.DECIMAL(18,2),
        allowNull: false
    },
})

module.exports = OrderDelivery;