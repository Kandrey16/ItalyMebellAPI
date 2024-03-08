'use strict';

const {DataTypes} = require("sequelize");
module.exports = {
  up: async (queryInterface, Sequelize) => {
    await queryInterface.addColumn('products', 'id_category', {
      type: DataTypes.TEXT,
      allowNull: true,
    });
  },

  down: async (queryInterface, Sequelize) => {
    await queryInterface.removeColumn('products', 'id_category');
  }
};
