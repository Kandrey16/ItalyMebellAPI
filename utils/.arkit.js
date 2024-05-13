module.exports = {
    input: [
        'src/models/**/*.js',
        'src/controllers/**/*.js',
        'src/routes/**/*.js'
        // Добавьте другие пути к файлам, которые вы хотите визуализировать
    ],
    output: {
        path: 'architecture.svg',
        groups: {
            models: {
                include: 'src/models/**/*.js'
            },
            controllers: {
                include: 'src/controllers/**/*.js'
            },
            routes: {
                include: 'src/routes/**/*.js'
            }
            // Создайте группы для других категорий файлов, если это необходимо
        }
    }
}