require('coffee-script').register();

exports.config = {
  // The file path to the selenium server jar.
  seleniumServerJar: './node_modules/protractor/selenium/selenium-server-standalone-2.39.0.jar',
  chromeOnly: false,
  capabilities: {
    browserName: 'firefox'
  },
  specs: ['src/tests/integration/**/*.coffee'],
  baseUrl: 'http://localhost:8001',
  framework: 'mocha',
  mochaOpts: {
    ui: 'bdd',
    reporter: 'list'
  }
};
