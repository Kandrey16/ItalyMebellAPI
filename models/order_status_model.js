const sequelize = require("../db");
const { DataTypes } = require("sequelize");

const OrderStatus = sequelize.define('order_status', {
    id_order_status: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    name_order_status: {
        type: DataTypes.STRING,
        allowNull: false
    },
})

module.exports = OrderStatus;