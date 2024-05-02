const OrderHistory = require('../models/order_history_model');

exports.getAllOrderHistories = async (req, res) => {
    try {
        const orderHistories = await OrderHistory.findAll();
        res.json(orderHistories);
    } catch (error) {
        res.status(500).send(error.message);
    }
};