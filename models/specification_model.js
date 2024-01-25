const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const Specification = sequelize.define('specification', {
    id_specification: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    value_specification: {
        type: DataTypes.STRING,
        allowNull: false,
    },
})

module.exports = Specification;
