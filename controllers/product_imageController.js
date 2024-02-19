import { v4 } from 'uuid';
import { resolve } from 'path';
import { Product_image, Product } from "../models";
import { badRequest } from "../error/ApiError";

class Product_imageController {
    async create(req, res, next) {
        try {
            const {id_product} = req.body
            const {url_image} = req.files || {}

            // if (!url_image) {
            //     throw ApiError.badRequest("Image file is missing");
            // }

            let filename = v4() + '.jpg'
            await url_image.mv(resolve(__dirname, '..', 'static', filename))

            const product_image = await Product_image.create({url_image: filename, id_product})
            return res.json(product_image)
        } catch (e) {
            next(badRequest(e.message))
        }
    }

    async getAll(req, res) {
        const product_images = await Product_image.findAll()
        return res.json(product_images)
    }

    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const product_image = await Product_image.findByPk(id);

            if (!product_image) {
                return next(badRequest(`Product Image with id ${id} not found`));
            }

            return res.json(product_image);
        } catch (e) {
            next(badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {id} = req.params
            const {url_image, id_product} = req.body
            const product_image = await Product_image.findByPk(id)

            if(!product_image) {
                return next(badRequest({message: `Product Image with id ${id} not found`}))
            }

            await product_image.update({url_image, id_product})
            return res.json(product_image)
        } catch (e) {
            next(badRequest(e.message))
        }
    }

    async delete(req, res, next) {
        try {
            const {id} = req.params
            const product_image = await Product_image.findByPk(id)

            if(!product_image) {
                return next(badRequest({message: `Product Image with id ${id} not found`}))
            }

            await product_image.destroy()
            return res.json({ message: 'Product Image deleted successfully' })
        } catch (e) {
            next(badRequest(e.message))
        }
    }
}

export default new Product_imageController()