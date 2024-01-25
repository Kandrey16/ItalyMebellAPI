//model.js
const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const Product = sequelize.define('product', {
    id_product: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    article_product: {
        type: DataTypes.STRING,
        allowNull: true,
        defaultValue: null,
        unique: true,
    },

    name_product: {
        type: DataTypes.STRING,
        allowNull: false,
    },

    price_product: {
        type: DataTypes.DECIMAL(10, 2),
        allowNull: false,
    },
    description_product: {
        type: DataTypes.TEXT,
        allowNull: false,
        defaultValue: null,
    },
    count_product: {
        type: DataTypes.INTEGER,
        allowNull: false,
    },
    is_enabled: {
        type: DataTypes.BOOLEAN,
        allowNull: false,
        defaultValue: false,
    },
})

module.exports = Product;
