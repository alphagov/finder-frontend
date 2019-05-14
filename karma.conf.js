module.exports = function (config) {
  config.set({
    frameworks: ['jasmine', 'chai', 'browserify', 'jquery-1.12.4'],
    files: ['spec/javascripts/**/*.js'],
    preprocessors: {
      'spec/javascripts/**/*.js': [ 'browserify' ] // to process `require` calls
    },
    plugins: ['karma-jasmine', 'karma-chai', 'karma-chrome-launcher', 'karma-browserify', 'karma-jquery'],
    reporters: ['progress'],
    port: 9876, // karma web server port
    colors: true,
    logLevel: config.LOG_INFO,
    browsers: ['ChromeHeadless'],
    autoWatch: false,
    concurrency: Infinity
  })
}
