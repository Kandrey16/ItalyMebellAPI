//controller.js
const {Product, Category, Attribute, Attribute_group, Specification} = require('../models/association')
const {Op} = require("sequelize");
const ApiError = require('../error/ApiError')
const uuid = require("uuid");
const path = require("path");
const logger = require('../utils/logger')

class ProductController {

    async create(req, res, next) {
        try {
            let {article_product, name_product, price_product, description_product, count_product, is_enabled, id_category, specifications} = req.body
            const {url_main_image_product} = req.files || {}

            if (!url_main_image_product) {
                return next(ApiError.badRequest("Main image file is missing"));
            }

            let filename = uuid.v4() + '.jpg'
            await url_main_image_product.mv(path.resolve(__dirname, '..', 'static', filename))

            const product = await Product.create({article_product, name_product, price_product,
                url_main_image_product: filename, description_product, count_product, is_enabled, id_category})

            if (specifications) {
                specifications = JSON.parse(specifications);
                for (const spec of specifications) {
                    const {value_specification, id_attribute} = spec;
                    await Specification.create({
                        value_specification: spec.value_specification,
                        id_product: product.id_product,
                        id_attribute,
                    })
                }

            }
            return res.json(product)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async search(req, res, next) {
        try {
            const {keyword} = req.query;

            if (!keyword) {
                return next(ApiError.badRequest('Keyword is missing'))
            }

            // Поиск по таблице Product
            const products = await Product.findAll({
                attributes: { exclude: ['id_product'] }, // исключаем атрибут id_product
                where: {
                    [Op.or]: [
                        { name_product: { [Op.like]: `%${String(keyword)}%` } },
                        { article_product: { [Op.like]: `%${String(keyword)}%` } },
                        { description_product: { [Op.like]: `%${String(keyword)}%` } },
                    ]
                },

            });
            return res.json(products);
        } catch (e) {
            logger.error(e);
            next(ApiError.badRequest(e.message));
        }
    }
// include: [
    //     // Добавляем связи с другими таблицами
    //     {
    //         model: Category,
    //         attributes: { exclude: ['id_category'] }, // исключаем атрибут id_category
    //         where: {
    //             name_category: { [Op.like]: `%${keyword}%` }
    //         }
    //     },
    //     {
    //         model: Specification,
    //         attributes: { exclude: ['id_specification'] }, // исключаем атрибут id_specification
    //         include: [
    //             {
    //                 model: Attribute,
    //                 attributes: { exclude: ['id_attribute'] }, // исключаем атрибут id_attribute
    //                 as: 'attribute', // Указываем алиас
    //                 include: {
    //                     model: Attribute_group,
    //                     attributes: { exclude: ['id_attribute_group'] }, // исключаем атрибут id_attribute_group
    //                     where: {
    //                         name_attribute_group: { [Op.like]: `%${keyword}%` }
    //                     }
    //                 }
    //             }
    //         ],
    //         as: 'specifications' // Указываем алиас
    //     }
    // ]
    async getAll(req, res) {
        let {id_category, limit, page} = req.query

        page  = page || 1
        limit = limit || 9
        let offset = page * limit - limit

        let products
        if(!id_category) {
            products = await Product.findAndCountAll({limit, offset})
        } else {
            products = await Product.findAndCountAll({where:{id_category}, limit, offset})
        }
        return res.json(products)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const product = await Product.findOne(
                {
                    where: {id_product: id},
                    include: [{model: Specification, as: 'specifications'}]
                },
            );

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

            let filename = product.url_main_image_product; 
            if (url_main_image_product) { 
                filename = uuid.v4() + '.jpg' 
                await url_main_image_product.mv(path.resolve(__dirname, '..', 'static', filename)) 
            } 

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

