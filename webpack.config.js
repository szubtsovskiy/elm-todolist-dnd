// Code borrowed shamelessly from https://github.com/moarwick/elm-webpack-starter

var webpack = require('webpack');
var merge = require('webpack-merge');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var autoprefixer = require('autoprefixer');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CopyWebpackPlugin = require('copy-webpack-plugin');
require('dotenv').config();

// determine build env
var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'production' : 'development';

// common webpack config
var commonConfig = {

  output: {
    path: './dist',
    filename: '[hash].js',
  },

  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.elm']
  },

  module: {
    loaders: [
      {
        test :/\.js$/,
        exclude: /node_modules/,
        loader: 'babel?presets=es2015'
      },
      {
        test: /\.(eot|ttf|woff|woff2|svg)(\?.+)?$/,
        loader: 'file'
      }
    ]
  },

  plugins: [
    new webpack.EnvironmentPlugin([
      'FIREBASE_API_KEY',
      'FIREBASE_AUTH_DOMAIN',
      'FIREBASE_DB_URL',
      'FIREBASE_STORAGE_BUCKET',
      'FIREBASE_MESSAGING_SENDER_ID'
    ]),
    new HtmlWebpackPlugin({
      template: 'app/src/index.html',
      inject: 'body',
      filename: 'index.html'
    })
  ],

  postcss: [autoprefixer({browsers: ['last 2 versions']})],

};

// additional webpack settings for local env (when invoked by 'npm start')
if (TARGET_ENV === 'development') {
  console.log('Serving locally...');

  module.exports = merge(commonConfig, {

    entry: [
      'webpack-dev-server/client?http://localhost:8080',
      './app/src/index.js',
      '!style!css!postcss!elm-css-webpack!./app/src/elm/Stylesheets.elm'
    ],

    devServer: {
      inline: true,
      progress: true
    },

    module: {
      loaders: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/],
          loader: 'elm-hot!elm-webpack?verbose=true&warn=true&cache=false'
        }
      ]
    }

  });
}

// additional webpack settings for prod env (when invoked via 'npm run build')
if (TARGET_ENV === 'production') {
  console.log('Building for prod...');

  module.exports = merge(commonConfig, {

    entry: [
      './app/src/index.js',
      './app/src/elm/Stylesheets.elm'
    ],

    module: {
      loaders: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/, /Stylesheets.elm/],
          loader: 'elm-webpack'
        },
        {
          test: /Stylesheets.elm$/,
          loader: ExtractTextPlugin.extract('style', [
            'css',
            'postcss',
            'elm-css-webpack'
          ])
        }
      ]
    },

    plugins: [
      new CopyWebpackPlugin([
        {
          from: 'app/images/',
          to: 'images/'
        },
        {
          from: 'app/images/favicon.ico'
        },
      ]),

      new webpack.optimize.OccurenceOrderPlugin(),

      // extract CSS into a separate file
      new ExtractTextPlugin('./[hash].css', {allChunks: true}),

      // minify & mangle JS/CSS
      new webpack.optimize.UglifyJsPlugin({
        minimize: true,
        compressor: {warnings: false}
        // mangle:  true
      })
    ]

  });
}
