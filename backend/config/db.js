// const { Sequelize } = require('sequelize');

// require('dotenv').config();

// const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASS, {
//   host: process.env.DB_HOST,
//   dialect: 'postgres',
// });

// module.exports = sequelize;


const { Sequelize } = require('sequelize');
const path = require('path');

// 👇 FORCE dotenv to read backend/.env
require('dotenv').config({
  path: path.resolve(__dirname, '../.env'),
});

console.log("DB USER:", process.env.DB_USER);

const sequelize = new Sequelize(
  process.env.DB_NAME,
  process.env.DB_USER,
  String(process.env.DB_PASSWORD),
  {
    host: process.env.DB_HOST,
    port: process.env.DB_PORT || 5432,
    dialect: 'postgres',
    logging: false,
  }
);

module.exports = sequelize;

