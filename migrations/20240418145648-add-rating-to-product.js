'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn('products', 'rating', {
      type: Sequelize.DECIMAL(10, 2),
      allowNull: true, // Разрешаем NULL, если рейтинг еще не был выставлен
      after: 'count_product' // Определяем порядок следования поля в таблице
    });
  },

  async down(queryInterface, Sequelize) {
    await queryInterface.removeColumn('products', 'rating');
  }
};
