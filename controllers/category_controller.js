const {Category, Attribute_group} = require('../models/association')
const ApiError = require('../error/ApiError')
const uuid = require("uuid");
const path = require("path");
const {error} = require("winston");

class CategoryController {

    async create(req, res, next) {
        try {
            const {name_category} = req.body
            const {img_category} = req.files || {}

            let filename = uuid.v4() + '.jpg'
            await img_category.mv(path.resolve(__dirname, '..', 'static', 'category_photo', filename))

            const category = await Category.create({name_category, img_category: filename})
            return res.json({category})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const categories = await Category.findAll()
        return res.json(categories)
    }

    async getCategoryAttributes(req, res, next) {
        try {
            const category_id = req.params.id
            const categoryWithAttributes = await Category.findByPk(category_id, {
                include: Attribute_group
            });

            if (categoryWithAttributes) {
                return res.json(categoryWithAttributes)
            } else {
                res.status(404).send('Категория не найдена')
            }
        } catch (e) {
            res.status(500).send('Ошибка при получении атрибутов категории: ' + e.message);
        }
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const category = await Category.findByPk(id);

            if (!category) {
                return next(ApiError.badRequest(`Category with id ${id} not found`));
            }
            return res.json(category);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {id} = req.params
            const {name_category} = req.body
            const {img_category} = req.files || {}

            const category = await Category.findByPk(id)

            if(!category) {
                return next(ApiError.badRequest({message: `Category with id ${id} not found`}))
            }

            let filename = category.img_category;
            if(img_category) {
                filename = uuid.v4() + '.jpg'
                await img_category.mv(path.resolve(__dirname, '..', 'static', 'category_photo', filename))
            }

            await category.update({name_category, img_category: filename})
            return res.json(category)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
    async delete(req, res, next) {
        try {
            const {id} = req.params
            const category = await Category.findByPk(id)

            if(!category) {
                return next(ApiError.badRequest({message: `Category with id ${id} not found`}))
            }

            await category.destroy()
            return res.json({ message: 'Category deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
}

module.exports = new CategoryController()