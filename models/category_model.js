const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const Category = sequelize.define('category', {
    id_category: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    name_category: {
        type: DataTypes.STRING,
        allowNull: false,
    },
})

module.exports = Category;
