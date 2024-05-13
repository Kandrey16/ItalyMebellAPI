'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.createTable('CategoryAttributeGroup',
        {
          CategoryId: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            references: {
              model: 'categories', // название твоей таблицы категорий
              key: 'id_category'
            }
          },
          AttributeGroupId: {
            type: Sequelize.INTEGER,
            primaryKey: true,
            references: {
              model: 'attribute_groups', // название твоей таблицы атрибутных групп
              key: 'id_attribute_group'
            }
          }
        }
    );
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.dropTable('CategoryAttributeGroup');
  }
};
