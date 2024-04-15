const ApiError = require('../error/ApiError')
const bcrypt = require('bcrypt')
const jwt = require('jsonwebtoken')
const {User_profile, Product, Category} = require('../models/association')
const uuid = require("uuid");
const path = require("path");

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
        const token = generateJwt(user.email_user, user.role_user)
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

    async getOne(req, res, next) {
        try {
            const { email_user } = req.params;
            const user_profile = await User_profile.findOne({
                where: { email_user: email_user }
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

            if(!user_profile) {
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
}

module.exports = new User_profileController()