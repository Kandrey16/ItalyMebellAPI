const {Image_comment} = require("../models");
const ApiError = require("../error/ApiError");

class Image_commentController {
    async create(req, res, next) {
        try {
            const {url_image_comment, id_product_comment} = req.body
            const image_comment = await Image_comment.create({url_image_comment, id_product_comment})
            return res.json({image_comment})
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const image_comments = await Image_comment.findAll()
        return res.json(image_comments)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const image_comment = await Image_comment.findByPk(id);

            if (!image_comment) {
                return next(ApiError.badRequest(`Image comment with id ${id} not found`));
            }

            return res.json(image_comment);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {id} = req.params
            const {url_image_comment, id_product_comment} = req.body
            const image_comment = await Image_comment.findByPk(id)

            if(!image_comment) {
                return next(ApiError.badRequest({message: `Image Comment with id ${id} not found`}))
            }

            await image_comment.update({url_image_comment, id_product_comment})
            return res.json(image_comment)
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async delete(req, res, next) {
        try {
            const {id} = req.params
            const image_comment = await Image_comment.findByPk(id)

            if(!image_comment) {
                return next(ApiError.badRequest({message: `Image comment with id ${id} not found`}))
            }

            await image_comment.destroy()
            return res.json({ message: 'Image Comment deleted successfully' })
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

}

module.exports = new Image_commentController()