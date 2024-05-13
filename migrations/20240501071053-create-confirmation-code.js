'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.createTable('ConfirmationCodes', {
      email_user: {
        type: Sequelize.STRING,
        primaryKey: true,
        allowNull: false,
        validate: {
          isEmail: true
        }
      },
      code: {
        type: Sequelize.STRING(6), // Предполагается 6-значный код
        allowNull: false
      },
      createdAt: {
        type: Sequelize.DATE,
        defaultValue: Sequelize.fn('NOW'),
        allowNull: false
      }
    });
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.dropTable('ConfirmationCodes');
  }
};
