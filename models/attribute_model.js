const sequelize = require('../db')
const { DataTypes} = require('sequelize')

const Attribute = sequelize.define('attribute', {
    id_attribute: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    name_attribute: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
    },
})

module.exports = Attribute;
