const sequelize = require("../db");
const {DataTypes, DATE} = require("sequelize");

const Orders = sequelize.define('orders', {
    id_order: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    number_order: {
        type: DataTypes.INTEGER,
        allowNull: false,
        unique: true,
    },

    price_order: {
        type: DataTypes.DECIMAL(18,2),
        allowNull: false,
    },

    date_order: {
        type: DataTypes.DATE(),
        allowNull: true,
        defaultValue: sequelize.literal('CURRENT_TIMESTAMP'),
    },
})

module.exports = Orders;
