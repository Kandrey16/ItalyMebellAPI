//controller.js
const {Product, Product_image, Attribute, Attribute_group, Specification} = require('../models/association')
const {Op, Sequelize, QueryTypes} = require("sequelize");
const ApiError = require('../error/ApiError')
const sequelize = require('../db')
const uuid = require("uuid");
const path = require("path");
const logger = require('../utils/logger')

class ProductController {

    async create(req, res, next) {
        const t = await sequelize.transaction();
        try {
            logger.debug('2024-05-04 17:30:40:3040 debug: Запрос на создание продукта получен');
            let {article_product, name_product, price_product, description_product, count_product, is_enabled, id_category, specifications} = req.body;
            const {url_main_image_product, additional_images} = req.files || {};

            // Проверка наличия основных данных о продукте
            if (!article_product) logger.error('2024-05-04 17:30:40:3040 error: Отсутствует артикул продукта');
            if (!name_product) logger.error('2024-05-04 17:30:40:3040 error: Отсутствует название продукта');
            if (price_product == null) logger.error('2024-05-04 17:30:40:3040 error: Отсутствует цена продукта');
            if (!description_product) logger.error('2024-05-04 17:30:40:3040 error: Отсутствует описание продукта');
            if (count_product == null) logger.error('2024-05-04 17:30:40:3040 error: Отсутствует количество продукта');
            if (!id_category) logger.error('2024-05-04 17:30:40:3040 error: Отсутствует идентификатор категории');

            if (!article_product || !name_product || price_product == null || !description_product || count_product == null || !id_category) {
                return next(ApiError.badRequest('Не все обязательные поля заполнены'));
            }

            if (!url_main_image_product) {
                return next(ApiError.badRequest("Main image file is missing"));
            }

            let filename = uuid.v4() + '.jpg'
            logger.debug(`Сохранение основного изображения: ${filename}`);
            await url_main_image_product.mv(path.resolve(__dirname, '..', 'static', filename))

            const product = await Product.create({
                article_product,
                name_product,
                price_product,
                url_main_image_product: filename,
                description_product,
                count_product,
                is_enabled,
                id_category
            }, { transaction: t })

            logger.debug('Продукт успешно создан:', product);

            if (specifications) {
                specifications = JSON.parse(specifications);
                for (const spec of specifications) {
                    const { value_specification, id_attribute } = spec;
                    await Specification.create({
                        value_specification,
                        id_product: product.id_product,
                        id_attribute
                    }, { transaction: t });
                    logger.debug('Создана характеристика:', spec);
                }
            }

            if (additional_images && additional_images.length) {
                if (!Array.isArray(additional_images)) {
                    logger.error('2024-05-04 17:30:40:3040 error: Дополнительные изображения не являются массивом');
                    return next(ApiError.badRequest('Additional images are not an array'));
                }
                if (additional_images.some(image => !image)) {
                    logger.error('2024-05-04 17:30:40:3040 error: Одно из дополнительных изображений отсутствует');
                    return next(ApiError.badRequest('One of the additional images is missing'));
                }
                logger.debug('Обработка дополнительных изображений:', additional_images.map(image => image.name));
                for (const image of additional_images) {
                    if (!image.mimetype.startsWith('image/')) {
                        logger.error(`2024-05-04 17:30:40:3040 error: Файл ${image.name} не является изображением`);
                        continue; // Пропустить этот файл и перейти к следующему
                    }
                    let imageFilename = uuid.v4() + path.extname(image.name);
                    logger.debug(`2024-05-04 17:30:40:3040 debug: Сохранение дополнительного изображения с именем файла: ${imageFilename}`);
                    await image.mv(path.resolve(__dirname, '..', 'static', imageFilename))
                    await Product_image.create({
                        url_image: imageFilename,
                        id_product: product.id_product
                    }, { transaction: t });
                    logger.debug('2024-05-04 17:30:40:3040 debug: Дополнительное изображение сохранено:', imageFilename);
                }
            }
            await t.commit();
            logger.debug('Транзакция завершена успешно');
            return res.json(product)
        } catch (e) {
            await t.rollback();
            logger.error('Ошибка при создании продукта:', e.message);
            next(ApiError.badRequest(e.message))
        }
    }

    async search(req, res, next) {
        try {
            const {keyword} = req.query;

            if (!keyword) {
                return next(ApiError.badRequest('Keyword is missing'))
            }

            const products = await Product.findAll({
                where: {
                    [Op.or]: [
                        { name_product: { [Op.iLike]: `%${String(keyword)}%` } },
                        { article_product: { [Op.iLike]: `%${String(keyword)}%` } },
                        { description_product: { [Op.iLike]: `%${String(keyword)}%` } },
                    ]
                },

            });

            return res.json(products);
        } catch (e) {
            logger.error(e);
            next(ApiError.badRequest(e.message));
        }
    }

    async getAll(req, res) {
        try {
            // Извлекаем параметры фильтрации из запроса
            let { id_category, id_collection, price_min, price_max, rating_min, name_attribute_group, name_attribute, value_specification, limit, page } = req.query;

            // Устанавливаем значения по умолчанию для страницы и лимита, если они не были предоставлены
            const pageValue = page || 1; // Значение по умолчанию для страницы
            const limitValue = limit || 5; // Значение по умолчанию для лимита
            const offsetValue = (pageValue - 1) * limitValue; // Вычисляем смещение для пагинации

            let whereConditions = []; // Массив для хранения условий SQL

            // Обрабатываем фильтр по категории
            if (id_category) {
                whereConditions.push(`id_category = '${id_category}'`); // Добавляем фильтр по id категории
            }
            if (typeof id_collection === 'string') {
                const collectionIds = id_collection.split(',');
                whereConditions.push(`id_collection IN (${collectionIds.map(id => `'${id}'`).join(',')})`);
            } else if (Array.isArray(id_collection)) {
                // Если переменная уже является массивом, просто используем её
                whereConditions.push(`id_collection IN (${id_collection.map(id => `'${id}'`).join(',')})`);
            }
            // Обрабатываем фильтры по ценовому диапазону
            if (price_min) {
                whereConditions.push(`price_product >= ${price_min}`)
            }
            if (price_max) {
                whereConditions.push(`price_product <= ${price_max}`)
            }
            // Обрабатываем фильтр по минимальному рейтингу
            if (rating_min) {
                whereConditions.push(`rating >= ${rating_min}`) // Добавляем фильтр по рейтингу
            }

            if (name_attribute_group) {
                const attributeGroups = name_attribute_group.split(',').map(value => `'${value.trim()}'`);
                whereConditions.push(`ag.name_attribute_group IN (${attributeGroups})`);
            }
            // Обрабатываем фильтр по имени атрибута
            if (name_attribute) {
                const attributes = name_attribute.split(',').map(value => `'${value.trim()}'`);
                whereConditions.push(`a.name_attribute IN (${attributes})`);
            }
            // Обрабатываем фильтр по значению спецификации
            if (value_specification) {
                const specifications = value_specification.split(',').map(value => `'${value.trim()}'`);
                whereConditions.push(`s.value_specification IN (${specifications})`);
            }

            const whereClause = whereConditions.length ? 'WHERE ' + whereConditions.join(' AND ') : '';

            const sqlCount = `SELECT COUNT(*) AS total_count FROM (
                SELECT p.id_product FROM products p
                LEFT JOIN specifications s ON p.id_product = s.id_product
                LEFT JOIN attributes a ON s.id_attribute = a.id_attribute
                LEFT JOIN attribute_groups ag ON a.id_attribute_group = ag.id_attribute_group
                ${whereClause}
            ) AS subquery`;

            const sqlProducts = `
                SELECT p.*, 
                ARRAY_AGG(DISTINCT a.name_attribute) as attributes,
                ARRAY_AGG(DISTINCT ag.name_attribute_group) as attribute_groups,
                ARRAY_AGG(DISTINCT s.value_specification) as specifications,
                ARRAY_AGG(DISTINCT pi.url_image) as images
                FROM products p
                LEFT JOIN specifications s ON p.id_product = s.id_product
                LEFT JOIN attributes a ON s.id_attribute = a.id_attribute
                LEFT JOIN attribute_groups ag ON a.id_attribute_group = ag.id_attribute_group
                LEFT JOIN product_images pi ON p.id_product = pi.id_product
                ${whereClause}
                GROUP BY p.id_product
            `;

            const countResult = await sequelize.query(sqlCount, { type: QueryTypes.SELECT });
            const total_count = countResult[0].total_count;
            const products = await sequelize.query(sqlProducts, { type: QueryTypes.SELECT });

            return res.json({
                count: parseInt(total_count, 10),
                rows: products
            });
        } catch (e) {
            return res.status(500).json({ message: "Ошибка при получении списка товаров: " + e.message });
        }
    }
    async getOne(req, res, next) {
        try {
            const { id } = req.params;
            const product = await Product.findOne(
                {
                    where: {id_product: id},
                    include: [
                        {
                            model: Specification,
                            as: 'specifications',
                            include: [{
                                model: Attribute,
                                as: 'attribute',
                                include: [{
                                    model: Attribute_group,
                                    as: 'attribute_group',
                                }]
                            }],
                        },
                        {
                            model: Product_image, // Модель изображения продукта
                        }
                    ]
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

    async getProductData(id) {
        const product = await Product.findByPk(id)

        if (!product) {
            throw new Error(`Product with id ${id} not found`);
        }
        return product;
    }

    async update(req, res, next) {
        // const t = await sequelize.transaction();
        try {
            const {id} = req.params
            let {article_product, name_product, price_product, description_product, count_product, is_enabled, id_category, id_collection } = req.body
            let {url_main_image_product} = req.files || {}

            const product = await Product.findByPk(id)
            logger.debug("Found product for update:", product);

            if(!product) {
                return next(ApiError.badRequest({message: `Product with id ${id} not found`}))
            }

            // Обновление основного изображения если оно есть
            if (url_main_image_product) {
                const filename = uuid.v4() + '.jpg'
                await url_main_image_product.mv(path.resolve(__dirname, '..', 'static', filename));
                product.url_main_image_product = filename;
            }

            await product.update({
                article_product,
                name_product,
                price_product,
                description_product,
                count_product,
                is_enabled,
                id_category,
                id_collection,
                url_main_image_product: product.url_main_image_product,
            });

            logger.debug("Product after update:", product);

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

