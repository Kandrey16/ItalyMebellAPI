const Router = require('express')
const router = new Router()
const categoryController = require('../controllers/category_controller')
const check = require("../middleware/checkRoleMiddleware");

/**
 * @swagger
 * /:
 *   post:
 *     summary: Создание категории
 *     description: Создает новую категорию
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name_category:
 *                 type: string
 *     responses:
 *       200:
 *         description: Категория успешно создана
 *       400:
 *         description: Ошибка при создании категории
 */
router.post('/', categoryController.create)

/**
 * @swagger
 * /:
 *   get:
 *     summary: Получение всех категорий
 *     description: Возвращает список всех категорий
 *     responses:
 *       200:
 *         description: Успешное получение списка категорий
 */
router.get('/',categoryController.getAll)

/**
 * @swagger
 * /{id}:
 *   get:
 *     summary: Получение категории по ID
 *     description: Возвращает категорию по ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID категории
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Успешное получение категории
 *       400:
 *         description: Категория не найдена
 */
router.get('/:id', categoryController.getOne)

/**
 * @swagger
 * /{id}:
 *   put:
 *     summary: Обновление категории
 *     description: Обновляет категорию по ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID категории
 *         schema:
 *           type: integer
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name_category:
 *                 type: string
 *     responses:
 *       200:
 *         description: Категория успешно обновлена
 *       400:
 *         description: Ошибка при обновлении категории
 */
router.put('/:id', check('ADMIN'), categoryController.update)

/**
 * @swagger
 * /{id}:
 *   delete:
 *     summary: Удаление категории
 *     description: Удаляет категорию по ID
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         description: ID категории
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Категория успешно удалена
 *       400:
 *         description: Ошибка при удалении категории
 */
router.delete('/:id', check('ADMIN'), categoryController.delete)

module.exports = router
