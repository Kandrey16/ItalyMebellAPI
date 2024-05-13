// updateRating.js
const {Product, Product_comment} = require("../models/association");

async function updateRating(id_product) {
    const product = await Product.findOne({where: {id_product}})
    const comments = await Product_comment.findAll({where: {id_product}})
    let sum = 0;
    comments.forEach(comment => {
        sum += comment.mark_comment;
    });
    product.rating = sum / comments.length;
    await product.save();
}

module.exports = updateRating;
