const {Collection} = require('../models/association')
const ApiError = require('../error/ApiError')

class CollectionController {

    async create(req, res, next) {
        try {
            const {name_collection} = req.body

            const collection = await Collection.create({name_collection})
            return res.json({collection})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const collections = await Collection.findAll()
        return res.json(collections)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const collection = await Collection.findByPk(id);

            if (!collection) {
                return next(ApiError.badRequest(`Collection with id ${id} not found`));
            }
            return res.json(collection);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {id} = req.params
            const {name_collection} = req.body
            const collection = await Collection.findByPk(id)

            if(!collection) {
                return next(ApiError.badRequest({message: `Collection with id ${id} not found`}))
            }

            await collection.update({name_collection})
            return res.json(collection)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
    async delete(req, res, next) {
        try {
            const {id} = req.params
            const collection = await Collection.findByPk(id)

            if(!collection) {
                return next(ApiError.badRequest({message: `Collection with id ${id} not found`}))
            }

            await collection.destroy()
            return res.json({ message: 'Collection deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
}

module.exports = new CollectionController()