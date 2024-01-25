'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.changeColumn('user_profiles', 'password_user', {
      type: Sequelize.TEXT,
      allowNull: false,
      validate: {
        len: {
          args: [5, 255],
          msg: 'Пароль должен быть не менее 5 символов',
        },
      },
    });
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.changeColumn('user_profiles', 'password_user', {
      type: Sequelize.TEXT,
      allowNull: false,
      validate: {
        len: {
          args: [5, 255],
          msg: 'Пароль должен быть не менее 5 символов',
        },
        isAlphanumeric: {
          args: true,
          msg: 'Пароль должен содержать только цифры и буквы',
        },
      },
    });
  }
};
