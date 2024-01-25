const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const Image_comment = sequelize.define('image_comment', {
    id_image_comment: {
        type: DataTypes.INTEGER,
        primaryKey: true,
        allowNull: false,
        autoIncrement: true,
    },

    url_image_comment: {
        type: DataTypes.TEXT,
        allowNull: true,
        defaultValue: null,
    },
})

module.exports = Image_comment;
