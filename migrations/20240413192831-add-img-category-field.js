'use strict';

/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.addColumn('categories', 'img_category', {
      type: Sequelize.STRING, // Или Sequelize.TEXT, смотря какой тип данных вы предпочитаете
      allowNull: true, // Поле может быть пустым
      after: 'name_category' // Опционально, указывает после какого поля добавлять новое поле в таблицу
    });
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.removeColumn('categories', 'img_category');
  }
};
