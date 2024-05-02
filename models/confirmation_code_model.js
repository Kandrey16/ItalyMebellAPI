const sequelize = require("../db");
const {DataTypes} = require("sequelize");

const ConfirmationCode = sequelize.define('confirmation_codes', {
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
}, {
    timestamps: true, // Включаем timestamps для Sequelize
    updatedAt: false // Отключаем createdAt, так как оно определено вручную
});

module.exports = ConfirmationCode;