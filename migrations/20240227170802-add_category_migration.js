'use strict';

const sequelize = require("../db");
const {DataTypes} = require("sequelize");
/** @type {import('sequelize-cli').Migration} */
module.exports = {
  async up (queryInterface, Sequelize) {
    await queryInterface.addColumn('products', 'url_main_image_product', {
      type: DataTypes.TEXT,
      allowNull: true,
      defaultValue: null,
    });
  },

  async down (queryInterface, Sequelize) {
    await queryInterface.removeColumn('products', 'url_main_image_product');
  }
};

