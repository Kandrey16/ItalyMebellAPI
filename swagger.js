//swagger.js
const swaggerAutogen = require('swagger-autogen')();
const doc = require('./swagger.config')

const outputFile = './swagger_output.json';
const endpointsFiles = ['./routes/*.js'];

swaggerAutogen(outputFile, endpointsFiles, doc);
