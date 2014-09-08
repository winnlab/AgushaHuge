var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var mochaPhantomJS = require('gulp-mocha-phantomjs');

var paths = {
    client: ['./_client-dev/*.coffee', './_client-dev/*/*.coffee'],
    tests: ['./test/client/*/*.coffee'],
    adminUnitTest: [
        './controllers/admin.coffee',
        './controllers/admin/*.coffee',
        './views/board/*.jade',
        './views/board/*/*.jade'
    ]
};

gulp.task('coffee-client', function () {
    gulp.src(paths.client)
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest('./public/js/admin/scripts'));
});

gulp.task('coffee-tests', function () {
    gulp.src(paths.tests)
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest('./test/client'));
});

gulp.task('unit-test-admin', function () {
    return gulp
        .src('test/client/test-admin.html')
        .pipe(mochaPhantomJS());
});

gulp.task('watch', function () {
    gulp.watch(paths.client, ['coffee-client']);
    gulp.watch(paths.tests, ['coffee-tests']);
    gulp.watch(paths.adminUnitTest, ['unit-test-admin']);
});