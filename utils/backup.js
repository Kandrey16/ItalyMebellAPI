const { spawn } = require('child_process');
const path = require('path');
const fs = require('fs');

function backupDatabase() {
    const backupDir = path.resolve(__dirname, 'backups');
    const dateTime = new Date().toISOString().replace(/[:.-]/g, '');
    const backupFilename = `backup_${dateTime}.sql`;

    if (!fs.existsSync(backupDir)) {
        fs.mkdirSync(backupDir);
    }

    const backupPath = path.join(backupDir, backupFilename);
    const env = 'development'; // or 'production' or 'test'
    const config = require('../config/config.json')[env];

    // Устанавливаем значение переменной окружения с паролем
    process.env.PGPASSWORD = config.password;

    // Формирование аргументов для `pg_dump`
    const dumpArgs = [
        '-U', config.username,
        '-d', config.database,
        '-h', config.host,
        '-f', backupPath
        // '-W' или '--password' не указываем
    ];

    // Создание процесса `pg_dump`
    const dumpProcess = spawn('pg_dump', dumpArgs);

    dumpProcess.stdout.on('data', (data) => {
        console.log(`STDOUT: ${data}`);
    });

    dumpProcess.stderr.on('data', (data) => {
        console.error(`STDERR: ${data}`);
    });

    dumpProcess.on('exit', (code) => {
        // Сбрасываем переменную окружения PGPASSWORD
        delete process.env.PGPASSWORD;

        if (code === 0) {
            console.log(`Бэкап базы данных успешно создан: ${backupPath}`);
        } else {
            console.error(`Процесс завершился с кодом ошибки: ${code}`);
            // Проверяем, существует ли файл бэкапа перед его удалением
            if (fs.existsSync(backupPath)) {
                fs.unlinkSync(backupPath);
            }
        }
    });
}

module.exports = { backupDatabase };