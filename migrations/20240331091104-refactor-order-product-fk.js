'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up(queryInterface, Sequelize) {
    await queryInterface.addColumn(
        'order_products', // имя таблицы
        'id_cart_product', // имя нового столбца (внешний ключ)
        {
          type: Sequelize.INTEGER,
          references: {
            model: 'cart_products', // имя таблицы, на которую ссылается ключ
            key: 'id_cart_product', // ключ в ссылочной таблице
          },
          onUpdate: 'CASCADE',
          onDelete: 'SET NULL',
          allowNull: true
        }
    );
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.removeColumn('order_products', 'id_cart_product');
  }
};
