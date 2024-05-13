const {Product_comment, Product} = require("../models/association");
const ApiError = require("../error/ApiError");
const updateRating = require('../utils/updateRating')
class Product_commentController {
    async create(req, res, next) {
        try {
            const {mark_comment, description_comment, id_product, email_user} = req.body
            const product_comment = await Product_comment.create({mark_comment, description_comment, id_product, email_user})
            await updateRating(id_product)

            return res.json({product_comment})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const {email_user} = req.query;

        let product_comments
        if (email_user) {
            product_comments = await Product_comment.findAll({where:{email_user}})
        } else {
            product_comments = await Product_comment.findAll()
        }
        return res.json(product_comments)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const product_comment = await Product_comment.findByPk(id);

            if (!product_comment) {
                return next(ApiError.badRequest(`Product Comment with id ${id} not found`));
            }

            return res.json(product_comment);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {id} = req.params
            const {mark_comment, description_comment, id_product, email_user} = req.body
            const product_comment = await Product_comment.findByPk(id)

            if(!product_comment) {
                return next(ApiError.badRequest({message: `Product Comment with id ${id} not found`}))
            }

            await product_comment.update({mark_comment, description_comment, id_product, email_user})
            await updateRating(id_product)

            return res.json(product_comment)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async delete(req, res, next) {
        try {
            const {id} = req.params
            const product_comment = await Product_comment.findByPk(id)

            if(!product_comment) {
                return next(ApiError.badRequest({message: `Product Comment with id ${id} not found`}))
            }

            await product_comment.destroy()
            await updateRating(id)

            return res.json({ message: 'Product Comment deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

}

module.exports = new Product_commentController()