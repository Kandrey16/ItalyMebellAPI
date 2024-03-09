const ApiError = require('../error/ApiError')
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken')
const {User_profile} = require('../models/index')

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

        if(!email_user || !password_user) {
            return next(ApiError.badRequest('Некорректный email или пароль'))
        }
        const candidate = await User_profile.findOne({where: {email_user}})
        if (candidate) {
            return next(ApiError.badRequest('Пользователь с таким email уже существует'))
        }
        const hashPassword = await bcrypt.hash(password_user, 5)
        const user = await  User_profile.create(
            {email_user, password_user: hashPassword, role_user})
        const token = generateJwt(user.id, user.email_user, user.role_user)
        return res.json({token})
    }

    async login(req, res, next) {
        const {email_user, password_user} = req.body

        if (!email_user || !password_user) {
            return next(ApiError.badRequest('Некорректный email или пароль'));
        }

        try {
            const user = await User_profile.findOne({ where: { email_user } });

            if (!user) {
                return next(ApiError.badRequest('Пользователь с таким email не найден'));
            }

            const passwordMatch = await bcrypt.compare(password_user, user.password_user);

            if (!passwordMatch) {
                return next(ApiError.badRequest('Неверный пароль'));
            }

            const token = generateJwt(
                user.email_user,
                user.first_name_user,
                user.second_name_user,
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
}

module.exports = new User_profileController()