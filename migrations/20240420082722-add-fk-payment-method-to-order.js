'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.addColumn('orders', 'id_payment_method', {
      type: Sequelize.INTEGER,
      references: {
        model: 'payment_method',
        key: 'id_payment_method'
      },
      onUpdate: 'CASCADE',
      onDelete: 'SET NULL'
    });
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.removeColumn('orders', 'id_payment_method');
  }
};
