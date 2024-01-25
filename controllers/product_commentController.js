const {Product_comment} = require("../models");
const ApiError = require("../error/ApiError");

class Product_commentController {
    async create(req, res, next) {
        try {
            const {mark_comment, description_comment, id_product, email_user} = req.body
            const product_comment = await Product_comment.create({mark_comment, description_comment, id_product, email_user})
            return res.json({product_comment})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const product_comments = await Product_comment.findAll()
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
            return res.json({ message: 'Product Comment deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

}

module.exports = new Product_commentController()