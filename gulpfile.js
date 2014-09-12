var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var mocha = require('gulp-mocha');

var paths = {
    client: ['./_client-dev/*.coffee', './_client-dev/*/*.coffee'],
    tests: ['./test/client/*/*.coffee'],
    adminUnitTest: ['./controllers/admin.coffee',
        './controllers/admin/*.coffee',
        './views/board/*.jade',
        './views/board/*/*.jade',
        './test/client/admin/*.js']
};

gulp.task('coffee-client', function () {
    return gulp.src(paths.client)
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest('./public/js/admin/scripts'));
});

gulp.task('coffee-tests', function () {
    return gulp.src(paths.tests)
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest('./test/client'));
});

gulp.task('unit-test-admin', function () {
    return gulp.src('./test/client/admin/*.js')
        .pipe(mocha());
});

gulp.task('watch', function () {
    gulp.watch(paths.client, ['coffee-client']);
    gulp.watch(paths.tests, ['coffee-tests']);
    gulp.watch(paths.adminUnitTest, ['unit-test-admin']);
});