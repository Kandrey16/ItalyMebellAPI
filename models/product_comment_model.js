const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const Product_comment = sequelize.define('product_comment', {
    id_product_comment: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    mark_comment: {
        type: DataTypes.INTEGER,
        allowNull: false,
        validate: {
            min: 1,
            max: 5,
        }
    },

    description_comment: {
        type: DataTypes.TEXT,
        allowNull: true,
        defaultValue: null
    },
})

module.exports = Product_comment;
