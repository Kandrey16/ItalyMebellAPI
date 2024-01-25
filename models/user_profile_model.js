const sequelize = require('../db')
const { DataTypes, DATE} = require('sequelize')

const User_profile = sequelize.define('user_profile', {
    email_user: {
        type: DataTypes.STRING,
        primaryKey: true,
        allowNull: false,
        unique: true,
        validate: {
            isEmail: true,
        }},

    password_user: {
        type: DataTypes.TEXT,
        allowNull: false,
        validate: {
            len: {
                args: [5, 255], // Указываете минимальное и максимальное значение
                msg: 'Пароль должен быть не менее 5 символов',
            },
            // isAlphanumeric: {
            //     args: true,
            //     msg: 'Пароль должен содержать только цифры и буквы',
            // },
        }
    },
    role_user: {
        type: DataTypes.STRING,
        allowNull: false,
        defaultValue: 'USER',
    },
    first_name_user: {
        type: DataTypes.STRING,
        allowNull: true,
        defaultValue: null,
    },
    second_name_user: {
        type: DataTypes.STRING,
        allowNull: true,
        defaultValue: null,
    },
    phone_number_client: {
        type: DataTypes.STRING,
        allowNull: true,
        defaultValue: null,
        unique: true,
    },
    image_user_profile: {
        type: DataTypes.TEXT,
        allowNull: true,
        defaultValue: null,
    },
})


module.exports = User_profile;
