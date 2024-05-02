const sequelize = require("../db");
const { DataTypes } = require("sequelize");

const PaymentMethod = sequelize.define('payment_method', {
    id_payment_method: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        autoIncrement: true,
        allowNull: false
    },
    name_payment_method: {
        type: DataTypes.STRING,
        allowNull: false
    },
})

module.exports = PaymentMethod;