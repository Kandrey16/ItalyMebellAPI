const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const Product_image = sequelize.define('product_image', {
    id_product_image: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    url_image: {
        type: DataTypes.TEXT,
        allowNull: true,
        defaultValue: null,
    },
})

module.exports = Product_image;
