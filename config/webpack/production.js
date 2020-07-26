process.env.NODE_ENV = process.env.NODE_ENV || 'production'

const environment = require('./environment')
const UglifyJsPlugin = require('uglifyjs-webpack-plugin')

environment.config.set('optimization.minimizer', [new UglifyJsPlugin()])

module.exports = environment.toWebpackConfig()
