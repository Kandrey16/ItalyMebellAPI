const express = require('express');
const Router = require('express')
const ordersController = require("../controllers/ordersController");
const productController = require('../controllers/productController')
const router = new Router()
const {exportOrderToExcel} = require('../utils/excel')
const excel = require('exceljs'); // Подключаем пакет для работы с Excel
const fs = require('fs');
const {log} = require("winston");

router.use(express.json());

router.post('/', ordersController.create)
router.get('/', ordersController.getAll)
router.get('/:id', ordersController.getOne)
router.put('/:id', ordersController.update)
router.delete('/:id', ordersController.delete)
router.get('/:id/export', async (req, res) => {
    try {
        const workbook = await exportOrderToExcel(req.params.id);
        // Create a buffer to store the Excel file
        const buffer = await workbook.xlsx.writeBuffer();
        // Set headers to indicate file download
        res.setHeader(
            "Content-Type",
            "application/vnd.openxmlformats-officedocument.spreadsheetml.sheet"
        );
        res.setHeader(
            "Content-Disposition",
            "attachment;filename=order.xlsx"
        );
        // Send the buffer as the response
        res.send(buffer);
    } catch (e) {
        console.error(e);
        res.status(500).send(e.message);
    }
});

module.exports = router;