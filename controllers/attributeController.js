const {Attribute} = require('../models/index')
const ApiError = require('../error/ApiError')

class AttributeController {
    async create(req, res, next) {
        try {
            const {name_attribute, id_attribute_group} = req.body
            const attribute = await Attribute.create({name_attribute, id_attribute_group})
            return res.json({attribute})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const attributes = await Attribute.findAll()
        return res.json(attributes)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const attribute = await Attribute.findByPk(id);

            if (!attribute) {
                return next(ApiError.badRequest(`Attribute with id ${id} not found`));
            }

            return res.json(attribute);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {id} = req.params
            const {name_attribute, id_attribute_group} = req.body
            const attribute = await Attribute.findByPk(id)

            if(!attribute) {
                return next(ApiError.badRequest({message: `Attribute with id ${id} not found`}))
            }

            await attribute.update({name_attribute, id_attribute_group})
            return res.json(attribute)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async delete(req, res, next) {
        try {
            const {id} = req.params
            const attribute = await Attribute.findByPk(id)

            if(!attribute) {
                return next(ApiError.badRequest({message: `Attribute with id ${id} not found`}))
            }

            await attribute.destroy()
            return res.json({ message: 'Attribute deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
}

module.exports = new AttributeController()