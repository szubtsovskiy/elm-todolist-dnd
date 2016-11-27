// Code borrowed shamelessly from https://github.com/moarwick/elm-webpack-starter

var path = require('path');
var webpack = require('webpack');
var merge = require('webpack-merge');
var HtmlWebpackPlugin = require('html-webpack-plugin');
var autoprefixer = require('autoprefixer');
var ExtractTextPlugin = require('extract-text-webpack-plugin');
var CopyWebpackPlugin = require('copy-webpack-plugin');

// determine build env
var TARGET_ENV = process.env.npm_lifecycle_event === 'build' ? 'production' : 'development';

// common webpack config
var commonConfig = {

  output: {
    path: path.resolve(__dirname, 'dist/'),
    filename: '[hash].js',
  },

  resolve: {
    modulesDirectories: ['node_modules'],
    extensions: ['', '.js', '.elm']
  },

  module: {
    loaders: [
      {
        test: /\.(eot|ttf|woff|woff2|svg)(\?.+)?$/,
        loader: 'file-loader'
      }
    ]
  },

  plugins: [
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
      path.join(__dirname, 'app/src/index.js')
    ],

    devServer: {
      inline: true,
      progress: true
    },

    module: {
      loaders: [
        {
          test: /\.elm$/,
          exclude: [/elm-stuff/, /node_modules/, /Stylesheets.elm/],
          loader: 'elm-hot!elm-webpack?verbose=true&warn=true&cache=false'
        },
        {
          test: /Stylesheets.elm$/,
          loader: 'style!css!postcss!elm-css-webpack'
        },
        {
          test: /\.(css|scss)$/,
          exclude: p => p.startsWith(path.resolve('app/styles')),
          loaders: [
            'style-loader',
            'css-loader?modules&localIdentName=[name]__[local]',
            'postcss-loader',
            'sass-loader'
          ]
        },
        {
          test: /\.(css|scss)$/,
          include: p => p.startsWith(path.resolve('app/styles')),
          loaders: [
            'style-loader',
            'css-loader',
            'postcss-loader',
            'sass-loader'
          ]
        }
      ]
    }

  });
}

// additional webpack settings for prod env (when invoked via 'npm run build')
if (TARGET_ENV === 'production') {
  console.log('Building for prod...');

  module.exports = merge(commonConfig, {

    entry: path.join(__dirname, 'app/src/index.js'),

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
        },
        {
          test: /\.(css|scss)$/,
          exclude: p => p.startsWith(path.resolve('app/styles')),
          loader: ExtractTextPlugin.extract('style-loader', [
            'css-loader?modules&localIdentName=[name]__[local]',
            'postcss-loader',
            'sass-loader'
          ])
        },
        {
          test: /\.(css|scss)$/,
          include: p => p.startsWith(path.resolve('app/styles')),
          loader: ExtractTextPlugin.extract('style-loader', [
            'css-loader',
            'postcss-loader',
            'sass-loader'
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
