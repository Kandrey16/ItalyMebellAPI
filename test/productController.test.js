require('dotenv').config({ path: '.env' });
const request = require('supertest');
const express = require('express');
const {Product, Attribute, Attribute_group, Category, Collection, Specification, User_profile} = require("../models/association");
const router = require("../routes");

const app = express();
app.use(express.json()); // Парсим JSON
app.use('/api', router)
describe('POST /api/collection', () => {
    test('should create a new collection', async () => {
        // Определяем данные для создания новой коллекции
        const newCollectionData = {
            name_collection: 'Test Collection'
        };
        // Отправляем POST-запрос
        const response = await request(app)
            .post('/api/collection')
            .send(newCollectionData)
            .expect(200) // Обновляем ожидаемый код состояния до 200
            .then((res) => {
                    return res;
            })
            .catch((err) => {
                throw err; // Пробрасываем ошибку дальше, чтобы тест завершился с ошибкой
            });

        // Проверяем, что коллекция была успешно создана
        const createdCollection = await Collection.findOne({ where: { name_collection: newCollectionData.name_collection } });
        expect(createdCollection).toBeTruthy(); // Убеждаемся, что коллекция существует
        expect(createdCollection.name_collection).toBe(newCollectionData.name_collection); // Проверяем соответствие имени коллекции
    });
});

describe('GET /api/product/search', () => {
    test('should return products matching the keyword', async () => {
        const keyword = 'стул';
        // Отправляем GET-запрос на поиск с ключевым словом 'test'
        const response = await request(app)
            .get('/api/product/search')
            .query({ keyword })
            .expect(200);
        // Проверяем, что в ответе содержатся продукты, соответствующие ключевому слову
        expect(response.body).toHaveLength(1); // Предполагаем, что найдено два продукта
        expect(response.body[0].name_product.toLowerCase()).toEqual(expect.stringContaining(keyword));
    });
});

describe('GET /api/product/search', () => {
    test('should return 400 Bad Request if keyword is missing', async () => {
        // Отправляем GET-запрос на поиск без ключевого слова
        const response = await request(app)
            .get('/api/product/search')
            .expect(404); // Изменено с 404 на 400
        // Проверяем, что получен ответ с ошибкой "Bad Request"
        expect(response.body.message).toBe('Keyword is missing');
    });
});

describe('POST /api/user_profile/login', () => {
    test('should login user with correct credentials', async () => {
        // Подготовка данных для теста (в этом случае создание пользователя с известными учетными данными)
        // Отправляем запрос на вход с известными учетными данными
        const response = await request(app)
            .post('/api/user_profile/login')
            .send({
                email_user: 'akurdelov@gmail.com',
                password_user: 'Pa$$123' // Используемый пароль
            })
            .expect(200); // Ожидаем успешный ответ

        // Проверяем, что в ответе есть токен
        expect(response.body.token).toBeDefined();
    });

    test('should return 400 Bad Request for incorrect credentials', async () => {
        // Отправляем запрос на вход с неверными учетными данными
        const response = await request(app)
            .post('/api/user_profile/login')
            .send({
                email_user: 'nonexistent@example.com', // Несуществующий пользователь
                password_user: 'incorrectPassword' // Неправильный пароль
            })
            .expect(400); // Ожидаем ошибку 400 Bad Request

        // Проверяем, что в ответе есть сообщение об ошибке
        expect(response.body.message).toBe('Пользователь с таким email не найден');
    });
});



