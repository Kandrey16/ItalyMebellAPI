//controller.js
const {Product} = require('../models/index')
const ApiError = require('../error/ApiError')

class ProductController {
    async create(req, res, next) {
        try {
            const {article_product, name_product, price_product, description_product, count_product, is_enabled} = req.body

            const product = await Product.create({article_product, name_product, price_product, description_product, count_product, is_enabled})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const products = await Product.findAll()
        return res.json(products)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const product = await Product.findByPk(id);

            if (!product) {
                return next(ApiError.badRequest(`Product with id ${id} not found`));
            }

            return res.json(product);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }
    
    async update(req, res, next) {
        try {
            const {id} = req.params
            const {article_product, name_product, price_product, description_product, count_product, is_enabled} = req.body
            const product = await Product.findByPk(id)

            if(!product) {
                return next(ApiError.badRequest({message: `Product with id ${id} not found`}))
            }

            await product.update({article_product, name_product, price_product, description_product, count_product})
            return res.json(product)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async delete(req, res, next) {
        try {
            const {id} = req.params
            const product = await Product.findByPk(id)

            if(!product) {
                return next(ApiError.badRequest({message: `Product with id ${id} not found`}))
            }

            await product.destroy()
            return res.json({ message: 'Product deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
}

module.exports = new ProductController()