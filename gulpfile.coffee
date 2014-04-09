# PLUGINS ------------------------------------------
gulp = require 'gulp'
gutil = require 'gulp-util'

# Load plugins automatically from package.jso
# Access them using $.pluginName
$ = require('gulp-load-plugins')()
sass = require 'gulp-ruby-sass'
runSequence = require 'run-sequence'
protractor = require('gulp-protractor').protractor
webdriver_update = require('gulp-protractor').webdriver_update
browserSync = require 'browser-sync'

# CONFIG -------------------------------------------

# Pass the env by using: gulp --type ENV_NAME
isDist = gutil.env.type is 'dist'

# File sources, both origin and destinations
sources =
  sass: 'src/style/**/*.scss'
  coffee: 'src/**/*.coffee'
  app: ['src/**/*.ts', '!src/**/*.tests.coffee']
  templates: 'src/templates/**/*.html'
  index: 'src/index.html'
  integration: 'src/tests/integration/**/*.coffee'
  assets: ['src/assets/**/*.png', 'src/assets/**/*.jpg']

distFolderName = if isDist then 'dist' else 'build'
destinations =
  css: "#{ distFolderName }/style"
  assets: "#{ distFolderName }/assets"
  js: "#{ distFolderName }/src"
  libs: "#{ distFolderName }/libs"
  index: "#{ distFolderName }"


# 3rd party libs, needs to be updated everytime we add a lib
libs =
  dev: [
    'libs/angular/angular.js',
    'libs/angular-ui-router/release/angular-ui-router.js',
  ]
  dist: [
    'libs/angular/angular.min.js',
    'libs/angular-ui-router/release/angular-ui-router.min.js',
  ]

# The gulp plugin for karma needs the files to load here instead of in the
# karma.config.coffee
testFiles = libs.dev;
testFiles = testFiles.concat [
  'libs/angular-mocks/angular-mocks.js',
  'build/src/templates.js',
  'src/**/*.coffee',
  '!src/tests/integration/**/*.coffee'
]

# JS/CSS to inject in index.html
# Order is important when injecting them into index.html
injectPaths = [
  "#{ destinations.libs }/angular.#{ if isDist then 'min.' else '' }js"
  "#{ destinations.libs }/angular-ui-router.#{ if isDist then 'min.' else '' }js"
  "#{ destinations.js }/**/*.js"
  "#{ destinations.css }/*.css"
]

# TASKS ----------------------------------------------------------------------

# Compiles SASS with ruby sass for now to a compressed output
# Switch to libsass when it supports sass 3.3
gulp.task 'style', ->
  gulp.src(sources.sass)
  .pipe(sass({style: 'nested'}))
  .pipe(gulp.dest(destinations.css))

gulp.task 'lint-typescript', ->
  gulp.src(sources.app)
  .pipe($.tslint())
  .pipe($.tslint.report('prose', {emitError: false}))

gulp.task 'typescript', ->
  stream = gulp.src(sources.app)
  .pipe($.tsc({ emitError: false }))

  # On dist env, we only want one uglified file for the whole app
  if isDist
    stream = stream.pipe($.concat('app.js')).pipe($.uglify())

  stream.pipe(gulp.dest(destinations.js))

# Transforms the templates to js using html2js to a single file and minify it
gulp.task 'templates', ->
  gulp.src(sources.templates)
  .pipe($.minifyHtml(
      empty: true
      spare: true
      quotes: true
  ))
  .pipe($.ngHtml2js({moduleName: 'templates'}))
  .pipe($.concat('templates.js'))
  .pipe(if isDist then $.uglify() else gutil.noop())
  .pipe(gulp.dest(destinations.js))

# Copy the 3rd party libs over
gulp.task 'libs', ->
  gulp.src(if isDist then libs.dist else libs.dev)
  .pipe(gulp.dest(destinations.libs))

# Copy .png and .jpg only for now
gulp.task 'assets', ->
  gulp.src(sources.assets)
  .pipe(gulp.dest(destinations.assets))

# Injects js/css tags into index.html
gulp.task 'index', ->
  gulp.src(injectPaths, {read: false})
  .pipe($.inject(sources.index, {ignorePath: distFolderName, addRootSlash: false}))
  .pipe(gulp.dest(destinations.index))

# Run tests only once with karma
gulp.task 'karma', ->
  gulp.src(testFiles)
  .pipe($.karma(
    configFile: 'karma.conf.coffee'
    action: 'run'
  ))
  .on 'error', (err) ->
    throw err

# Run karma and tell it to run the tests on filechanges
gulp.task 'test-continuous', ->
  gulp.src(testFiles)
  .pipe($.karma(
    configFile: 'karma.conf.coffee'
    action: 'watch'
  ))

# Setting up the protractor test task
gulp.task 'webdriver_update', webdriver_update
gulp.task 'protractor', ['webdriver_update'], ->
  gulp.src(sources.integration)
  .pipe(protractor(configFile: 'protractor.conf.js'))
  .on 'error', (e) -> throw e

gulp.task 'ci', ['karma', 'protractor']

# Deletes build/ and dist/
gulp.task 'clean', ->
  gulp.src(['dist/', 'build/'], {read: false}).pipe($.clean())

# Reloads the page for us
gulp.task 'browser-sync', ->
  browserSync.init [
    'build/*.html'
    'build/**/*.js'
    'build/style/*.css'
  ],
    server:
      baseDir: './build'
    open: false

# By default, we first want to build the project, then start karma runner and
# the watchers
gulp.task 'default', ['build'], ->
  runSequence 'browser-sync', ['watch', 'test-continuous']

# Build the project
gulp.task 'build', ->
  runSequence 'clean', ['style', 'assets', 'lint-typescript', 'typescript', 'templates', 'libs'], 'index'

# Setup watchers for the different files
gulp.task 'watch', ->
  gulp.watch sources.sass, ['style']
  gulp.watch sources.app, ['lint-typescript', 'typescript']
  gulp.watch sources.templates, ['templates']
  gulp.watch sources.index, ['index']
  gulp.watch sources.assets, ['assets']
