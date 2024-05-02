const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const ConfigurationCode = sequelize.define('configuration_codes', {
    email_user: {
        type: DataTypes.STRING,
        primaryKey: true,
        allowNull: false,
        validate: {
            isEmail: true
        }
    },
    code: {
        type: DataTypes.STRING(6), // Предполагается 6-значный код
        allowNull: false
    },
    createdAt: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
    }
})

module.exports = Collection;