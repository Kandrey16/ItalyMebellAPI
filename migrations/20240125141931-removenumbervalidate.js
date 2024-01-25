'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.changeColumn('user_profiles', 'phone_number_client', {
        type: Sequelize.TEXT,
        allowNull: true,
        defaultValue: null,
    });
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.changeColumn('user_profiles', 'phone_number_client', {
        type: Sequelize.TEXT,
        allowNull: true,
        defaultValue: null,
    });
  }
};
