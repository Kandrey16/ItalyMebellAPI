const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const Attribute_group = sequelize.define('attribute_group', {
    id_attribute_group: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    name_attribute_group: {
        type: DataTypes.STRING,
        allowNull: false,
        unique: true,
    },
})

module.exports = Attribute_group;
