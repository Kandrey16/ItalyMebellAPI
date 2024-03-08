const {Attribute_group} = require('../models/index')
const ApiError = require('../error/ApiError')
const {Product} = require("../models");

class Attribute_groupController {
    async create(req, res, next) {
        try {
            const {name_attribute_group} = req.body

            const attribute_group = await Attribute_group.create({name_attribute_group})
            return res.json({attribute_group})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
    async getAll(req, res) {
        const attribute_groups = await Attribute_group.findAll()
        return res.json(attribute_groups)
    }
    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const attribute_group = await Attribute_group.findByPk(id);

            if (!attribute_group) {
                return next(ApiError.badRequest(`Attribute Group with id ${id} not found`));
            }

            return res.json(attribute_group);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }
    async update(req, res, next) {
        try {
            const {id} = req.params
            const {name_attribute_group} = req.body
            const attribute_group = await Attribute_group.findByPk(id)

            if(!attribute_group) {
                return next(ApiError.badRequest({message: `Attribute Group with id ${id} not found`}))
            }

            await attribute_group.update({name_attribute_group})
            return res.json(attribute_group)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
    async delete(req, res, next) {
        try {
            const {id} = req.params
            const attribute_group = await Attribute_group.findByPk(id)

            if(!attribute_group) {
                return next(ApiError.badRequest({message: `Attribute Group with id ${id} not found`}))
            }

            await attribute_group.destroy()
            return res.json({ message: 'Attribute Group deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
}

module.exports = new Attribute_groupController()