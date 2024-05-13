const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const Collection = sequelize.define('collection', {
    id_collection: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    name_collection: {
        type: DataTypes.STRING,
        allowNull: false,
    },
})

module.exports = Collection;
