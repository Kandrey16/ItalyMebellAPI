const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const Order_address = sequelize.define('order_address', {
    id_order_address: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    address_order: {
        type: DataTypes.TEXT,
        allowNull: false,
    },

    entrance_order: {
        type: DataTypes.INTEGER,
        allowNull: true,
        defaultValue: null,
        validate: {
            min: 0
        }
    },

    floor_order: {
        type: DataTypes.INTEGER,
        allowNull: true,
        defaultValue: null,
        validate: {
            min: 0
        }
    },

    home_code_order: {
        type: DataTypes.STRING,
        allowNull: true,
        defaultValue: null,
    },
})

module.exports = Order_address;

