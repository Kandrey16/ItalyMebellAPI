const {Specification} = require("../models");
const ApiError = require("../error/ApiError");

class SpecificationController {
    async create(req, res, next) {
        try {
            const {value_specification, id_attribute, id_product} = req.body
            const specification = await Specification.create({value_specification, id_attribute, id_product})
            return res.json({specification})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const specifications = await Specification.findAll()
        return res.json(specifications)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const specification = await Specification.findByPk(id);

            if (!specification) {
                return next(ApiError.badRequest(`Specification with id ${id} not found`));
            }

            return res.json(specification);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {id} = req.params
            const {value_specification, id_attribute, id_product} = req.body
            const specification = await Specification.findByPk(id)

            if(!specification) {
                return next(ApiError.badRequest({message: `Specification with id ${id} not found`}))
            }

            await specification.update({value_specification, id_attribute, id_product})
            return res.json(specification)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async delete(req, res, next) {
        try {
            const {id} = req.params
            const specification = await Specification.findByPk(id)

            if(!specification) {
                return next(ApiError.badRequest({message: `Specification with id ${id} not found`}))
            }

            await specification.destroy()
            return res.json({ message: 'Specification deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

}

module.exports = new SpecificationController()