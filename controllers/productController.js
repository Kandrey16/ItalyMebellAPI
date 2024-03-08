//controller.js
const {Product} = require('../models/index')
const ApiError = require('../error/ApiError')
const uuid = require("uuid");
const path = require("path");

class ProductController {
    async create(req, res, next) {
        try {
            const {article_product, name_product, price_product, description_product, count_product, is_enabled, id_category} = req.body
            const {url_main_image_product} = req.files || {}

            let filename = uuid.v4() + '.jpg'
            await url_main_image_product.mv(path.resolve(__dirname, '..', 'static', filename))

            const product = await Product.create({article_product, name_product, price_product, url_main_image_product: filename, description_product, count_product, is_enabled, id_category})
            return res.json({product})
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
            const {article_product, name_product, price_product, description_product, count_product, is_enabled, id_category} = req.body
            const {url_main_image_product} = req.files || {}

            const product = await Product.findByPk(id)

            if(!product) {
                return next(ApiError.badRequest({message: `Product with id ${id} not found`}))
            }

            let filename = product.url_main_image_product; // добавлено
            if (url_main_image_product) { // добавлено
                filename = uuid.v4() + '.jpg' // добавлено
                await url_main_image_product.mv(path.resolve(__dirname, '..', 'static', filename)) // добавлено
            } // добавлено

            await product.update({article_product, name_product, price_product, url_main_image_product: filename, description_product, count_product, is_enabled, id_category})
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

