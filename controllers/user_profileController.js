const ApiError = require('../error/ApiError')
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken')
const {User_profile} = require('../models/association')
const uuid = require("uuid");
const path = require("path");
const {sendConfirmationCodeEmail} = require("../utils/mailer");
const logger = require('../utils/logger')
const confirmationCodes = {};

const generateJwt = (email_user, role_user) => {
    return jwt.sign(
        {email_user, role_user},
        process.env.SECRET_KEY,
        {expiresIn: '24h'}
    )
}
class User_profileController {
    async registration(req, res, next) {
        const {email_user, password_user, role_user} = req.body

        if (!email_user || !password_user) {
            return next(ApiError.badRequest('Некорректный email или пароль'))
        }
        const candidate = await User_profile.findOne({where: {email_user}})
        if (candidate) {
            return next(ApiError.badRequest('Пользователь с таким email уже существует'))
        }
        const hashPassword = await bcrypt.hash(password_user, 5)
        const user = await User_profile.create(
            {email_user, password_user: hashPassword, role_user})
        const token = generateJwt(user.email_user, user.role_user)
        return res.json({token})
    }

    async login(req, res, next) {
        const {email_user, password_user} = req.body

        if (!email_user || !password_user) {
            return next(ApiError.badRequest('Некорректный email или пароль'));
        }

        try {
            const user = await User_profile.findOne({where: {email_user}});

            if (!user) {
                return next(ApiError.badRequest('Пользователь с таким email не найден'));
            }

            const passwordMatch = await bcrypt.compare(password_user, user.password_user);

            if (!passwordMatch) {
                return next(ApiError.badRequest('Неверный пароль'));
            }

            const token = generateJwt(
                user.email_user,
                user.role_user,
            )
            return res.json({token})
        } catch (e) {
            return next(ApiError.internal('Ошибка при аудентификации'))
        }
    }


    async check(req, res, next) {
        const token = generateJwt(req.user.email_user, req.user.role_user)
        return res.json({token})
    }

    async getAll(req, res) {
        const user_profiles = await User_profile.findAll()
        return res.json(user_profiles)
    }

    async getOne(req, res, next) {
        try {
            const {email_user} = req.params;
            const user_profile = await User_profile.findOne({
                where: {email_user: email_user}
            });

            if (!user_profile) {
                return next(ApiError.badRequest(`User profile with email_user ${email_user} not found`));
            }
            return res.json(user_profile);
        } catch (e) {
            next(ApiError.badRequest(e.message));
        }
    }

    async update(req, res, next) {
        try {
            const {email_user} = req.params
            const {password_user, role_user, first_name_user, second_name_user, phone_number_client} = req.body
            const {image_user_profile} = req.files || {}

            const user_profile = await User_profile.findByPk(email_user)

            if (!user_profile) {
                return next(ApiError.badRequest({message: `User with email ${email_user} not found`}))
            }

            let filename = user_profile.image_user_profile;
            if (image_user_profile) {
                filename = uuid.v4() + path.extname(image_user_profile.name);
                await image_user_profile.mv(path.resolve(__dirname, '..', 'static', 'user_photo', filename))
            }

            let updatedFields = {
                role_user,
                first_name_user,
                second_name_user,
                phone_number_client,
                image_user_profile: filename
            };

            if (password_user) {
                const hashPassword = await bcrypt.hash(password_user, 5);
                updatedFields.password_user = hashPassword;
            }

            await user_profile.update(updatedFields);
            return res.json(user_profile);
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    async changePassword(req, res, next) {
        try {
            const { email_user, old_password, new_password, confirm_password } = req.body;
            if (typeof old_password !== 'string' || typeof new_password !== 'string' || typeof confirm_password !== 'string') {
                return next(ApiError.badRequest('Пароли должны быть строками'));
            }
            const user = await User_profile.findOne({ where: { email_user } });

            if (!user) {
                return next(ApiError.badRequest('Пользователь не найден'));
            }

            const passwordMatch = await bcrypt.compare(old_password, user.password_user);
            if (!passwordMatch) {
                return next(ApiError.badRequest('Старый пароль неверен'));
            }

            if (new_password !== confirm_password) {
                return next(ApiError.badRequest('Новый пароль и его подтверждение не совпадают'));
            }

            const hashPassword = await bcrypt.hash(new_password, 5);
            await user.update({ password_user: hashPassword });

            return res.json({ message: 'Пароль успешно изменен' });
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }
    async resetPassword(req, res, next) {
        try {
            const { email_user, code, new_password, confirm_password } = req.body;

            // Получение пользователя по email
            const user = await User_profile.findOne({ where: { email_user } });

            if (!user) {
                return next(ApiError.badRequest('Пользователь не найден'));
            }

            // Проверка верности кода подтверждения
            if (code !== confirmationCodes[email_user]) {
                return next(ApiError.badRequest('Неверный код подтверждения'));
            }

            // Проверка совпадения нового пароля и его подтверждения
            if (new_password !== confirm_password) {
                return next(ApiError.badRequest('Новый пароль и его подтверждение не совпадают'));
            }

            // Хеширование нового пароля
            const hashPassword = await bcrypt.hash(new_password, 5);

            // Обновление пароля пользователя
            await user.update({ password_user: hashPassword });

            // Очистка кода подтверждения
            delete confirmationCodes[email_user];

            return res.json({ message: 'Пароль успешно изменен' });
        } catch (e) {
            next(ApiError.badRequest(e.message))
        }
    }

    // Отправка кода подтверждефния на почту
    async sendResetPasswordCode(req, res, next) {
        try {
            const { email_user } = req.body;
            logger.debug('Получен запрос на отправку кода подтверждения для:', email_user);
            // Генерация случайного кода подтверждения
            const code = Math.floor(100000 + Math.random() * 900000).toString();
            // Отправка кода подтверждения на почту
            await sendConfirmationCodeEmail(email_user, code);
            logger.debug('Код подтверждения отправлен на почту:', email_user);
            // Сохранение кода подтверждения в объекте
            confirmationCodes[email_user] = code;

            return res.json({ message: 'Код подтверждения отправлен на почту' });
        } catch (e) {
            logger.debug('Ошибка при обработке запроса на отправку кода:', e);
            next(ApiError.badRequest(e.message))
        }
    }
}

module.exports = new User_profileController()

    // async confirmPasswordChange(req, res, next) {
    //     const {email_user, confirmationCode, newPassword} = req.body;
    //
    //     try {
    //         // Поиск кода подтверждения в таблице ConfirmationCode
    //         const confirmationEntry = await Confirmation_code.findOne({
    //             where: {
    //                 email_user: email_user,
    //                 code: confirmationCode
    //             }
    //         });
    //
    //         if (!confirmationEntry) {
    //             throw new Error('Invalid confirmation code');
    //         }
    //
    //         // Поиск пользователя в таблице User_profile
    //         const user = await User_profile.findOne({
    //             where: {
    //                 email_user: email_user
    //                 // Удаление `confirmation_code`, так как его нет в `User_profile`
    //             }
    //         });
    //
    //         if (user) {
    //             // Обработка логики изменения пароля
    //             user.password_user = newPassword; // Пример обновления пароля, предполагается, что перед сохранением пароль будет должным образом хэшироваться
    //             await user.save();
    //             // Отправка ответа об успешном изменении пароля
    //         } else {
    //             // Обработка ошибки: пользователь не найден
    //             throw new Error('User not found');
    //         }
    //     } catch (error) {
    //         // Обработка прочих ошибок
    //         console.error('Error in confirmPasswordChange:', error);
    //         throw error;
    //     }
    // }
            // const user = await User_profile.findOne({where: email_user});
            //
            // if (!user) {
            //     return next(ApiError.badRequest('Пользователь с таким email не найден'))
            // }
            //
            // const code = Math.floor(100000 + Math.random() * 900000)
            //
            // await sendConfirmationCodeEmail(email_user, code);
            //
            // logger.debug(`Код подтверждения ${code} отправлен на email`);
            //
            // if(await checkConfirmationCode(email_user, confirmationCode)) {
            //     // Если код подтверждения верен, обновим пароль
            //
            //     const hashPassword = await bcrypt.hash(newPassword, 5);
            //     await User_profile.update(
            //         { password_user: hashPassword },
            //         { where: { email_user } }
            //     );
            //
            //     return res.json({ message: 'Пароль успешно изменен' });
            // } else {
            //     return next(ApiError.badRequest('Неверный код подтверждения'));
            // }

            // return res.json({message: 'Код подтверждения отправлен на email'});
        // } catch (e) {
        //     next(ApiError.badRequest(e.message));
        // }


// async function checkConfirmationCode(email_user, confirmationCode) {
//     try {
//         const codeEntry = await Confirmation_code.findOne({
//             where: {
//                 email_user: email_user,
//                 code: confirmationCode,
//                 // Здесь вы можете добавить дополнительные условия,
//                 // например, проверку на время жизни кода
//             }
//         });
//
//         if (!codeEntry) {
//             // Запись с кодом не найдена
//             return false;
//         }
//
//         // Проверка на время жизни кода, если это необходимо
//         // (например, код должен быть использован в течение 15 минут после отправки)
//         const expirationTime = 15 * 60 * 1000; // 15 минут в миллисекундах
//         if (new Date() - codeEntry.createdAt > expirationTime) {
//             // Если код истек
//             await codeEntry.destroy(); // Удаляем устаревший код из базы данных
//             return false;
//         }
//
//         // Код подтверждения совпадает и не истек, удаляем его из базы данных
//         await codeEntry.destroy();
//         return true; // Успешная проверка кода
//     } catch (e) {
//         throw new Error('Ошибка при проверке кода подтверждения');
//     }
// }

