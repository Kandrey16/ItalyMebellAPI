const {Category} = require('../models/index')
const ApiError = require('../error/ApiError')
const {Product} = require("../models");

class CategoryController {

    async create(req, res, next) {
        try {
            const {name_category} = req.body
            const category = await Category.create({name_category})
            return res.json({category})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const categories = await Category.findAll()
        return res.json(categories)
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
            const category = await Category.findByPk(id)

            if(!category) {
                return next(ApiError.badRequest({message: `Category with id ${id} not found`}))
            }
            await category.update({name_category})
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