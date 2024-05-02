//controller.js
const {Product, Attribute, Attribute_group, Specification} = require('../models/association')
const {Op, Sequelize, QueryTypes} = require("sequelize");
const ApiError = require('../error/ApiError')
const sequelize = require('../db')
const uuid = require("uuid");
const path = require("path");
const logger = require('../utils/logger')
const ExcelJS = require('exceljs')
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

            const products = await Product.findAll({
                attributes: { exclude: ['id_product'] },
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

    async exportToExcel(req, res, next) {
        try {
            // Подготавливаем данные для экспорта
            const products = await Product.findAll({
                // Включаем связанные данные, если они необходимы в вашем Excel файле
                include: [
                    {
                        model: Specification,
                        as: 'specifications',
                        include: [{
                            model: Attribute,
                            as: 'attribute'
                        }]
                    }
                ]
            });

            // Создаем экземпляр рабочей книги и листа
            const workbook = new ExcelJS.Workbook();
            const worksheet = workbook.addWorksheet('Products');

            // Добавляем заголовки столбцов
            worksheet.columns = [
                { header: 'ID', key: 'id_product', width: 10 },
                { header: 'Article', key: 'article_product', width: 20 },
                { header: 'Name', key: 'name_product', width: 30 },
                { header: 'Price', key: 'price_product', width: 15 },
                { header: 'Description', key: 'description_product', width: 50 },
                { header: 'Count', key: 'count_product', width: 10 },
                { header: 'Enabled', key: 'is_enabled', width: 10 },
                // Добавляйте другие столбцы в соответствии с вашими данными
            ];

            // Добавляем строки с данными
            products.forEach(product => {
                worksheet.addRow(product.dataValues);
            });

            // Устанавливаем стили, если необходимо
            worksheet.getRow(1).font = { bold: true };

            // Подготавливаем файл для отправки
            res.setHeader('Content-Type', 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
            res.setHeader('Content-Disposition', 'attachment; filename=' + 'products.xlsx');

            // Записываем Excel файл в ответ
            await workbook.xlsx.write(res);

            // Завершаем ответ
            res.end();
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async getAll(req, res) {
        try {
            // Извлекаем параметры фильтрации из запроса
            let { id_category, id_collection, price_min, price_max, rating_min, name_attribute_group, name_attribute, value_specification, limit, page } = req.query;

            // Устанавливаем значения по умолчанию для страницы и лимита, если они не были предоставлены
            const pageValue = page || 1; // Значение по умолчанию для страницы
            const limitValue = limit || 9; // Значение по умолчанию для лимита
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
                ARRAY_AGG(DISTINCT s.value_specification) as specifications
                FROM products p
                LEFT JOIN specifications s ON p.id_product = s.id_product
                LEFT JOIN attributes a ON s.id_attribute = a.id_attribute
                LEFT JOIN attribute_groups ag ON a.id_attribute_group = ag.id_attribute_group
                ${whereClause}
                GROUP BY p.id_product
                LIMIT ${limitValue}
                OFFSET ${offsetValue};
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
    // async getAll(req, res) {
    //     // Извлекаем параметры фильтрации из запроса
    //     let { id_category, id_collection, price_min, price_max, rating_min, specifications, limit, page } = req.query;
    //
    //     console.log("Параметры запроса:", req.query); // Логирование полученных параметров
    //
    //     // Устанавливаем значения по умолчанию для страницы и лимита, если они не были предоставлены
    //     page = page || 1;
    //     limit = limit || 9;
    //     let offset = page * limit - limit; // Вычисляем смещение для пагинации
    //
    //     let filters = {}; // Объект для фильтрации товаров по данной категории, цене и рейтингу
    //     let searchQuery = {}
    //
    //     // Обрабатываем фильтр по категории
    //     if (id_category) {
    //         filters.id_category = id_category; // Добавляем фильтр по id категории
    //     }
    //     if (id_collection) {
    //         filters.id_collection = id_collection; // Добавляем фильтр по id категории
    //     }
    //     // Обрабатываем фильтры по ценовому диапазону
    //     if (price_min || price_max) {
    //         filters.price_product = {};
    //         if (price_min) filters.price_product[Op.gte] = price_min; // Добавляем минимальную цену
    //         if (price_max) filters.price_product[Op.lte] = price_max; // Добавляем максимальную цену
    //     }
    //     // Обрабатываем фильтр по минимальному рейтингу
    //     if (rating_min) {
    //         filters.rating = { [Op.gte]: rating_min }; // Добавляем фильтр по рейтингу
    //     }
    //
    //
    //     // Пытаемся получить список товаров, учитывая заданные фильтры
    //     try {
    //         let products = await Product.findAndCountAll({
    //             where: {
    //                 ...filters,
    //                 // ...searchQuery
    //             },
    //             include: [{
    //                 model: Specification,
    //                 as: 'specifications',
    //                 include: [{
    //                     model: Attribute,
    //                     as: 'attribute',
    //                 }],
    //             }],
    //             limit, // Ограничение количества товаров в ответе
    //             offset, // Смещение для пагинации
    //             distinct: true // Это нужно для корректного подсчёта общего количества товаров
    //         });
    //
    //         return res.json(products);
    //     } catch (e) {
    //         return res.status(500).json({ message: "Ошибка при получении списка товаров: " + e.message });
    //     }
    // }
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
                            }]
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

