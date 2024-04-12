const express = require('express');
const router = express.Router();
const { backupDatabase } = require('../backup');

router.post('/database/backup', (req, res) => {
    try {
        backupDatabase();
        res.status(200).json({
            message: 'Инициировано создание бэкапа базы данных.'
        });
    } catch (error) {
        console.error(error);
        res.status(500).json({
            message: 'Произошла ошибка при попытке создания бэкапа.',
            error: error.message
        });
    }
});

module.exports = router;