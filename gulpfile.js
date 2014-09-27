var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');
var mocha = require('gulp-mocha');
var sass = require('gulp-sass');

var paths = {
    // client: [''],
    tests: ['./test/client/*/*.coffee'],
    adminUnitTest: ['./controllers/admin.coffee',
        './controllers/admin/*.coffee',
        './views/board/*.jade',
        './views/board/*/*.jade',
        './test/client/admin/*.js'],
    sass: ['./public/scss/*.scss', './public/scss/*/*.scss']
};

// gulp.task('coffee-client', function () {
//     gulp.src(paths.client)
//         .pipe(coffee({bare: true}).on('error', gutil.log))
//         .pipe(gulp.dest('./public/js/admin/scripts'));
// });

gulp.task('coffee-tests', function () {
    gulp.src(paths.tests)
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest('./test/client'));
});

gulp.task('unit-test-admin', function () {
    gulp.src('./test/client/admin/*.js')
        .pipe(mocha());
});

gulp.task('sass', function () {
    gulp.src(paths.sass)
        .pipe(sass({errLogToConsole: true}))
        .pipe(gulp.dest('./public/css'));
});

gulp.task('watch', function () {
    // gulp.watch(paths.client, ['coffee-client']);
    gulp.watch(paths.tests, ['coffee-tests']);
    gulp.watch(paths.adminUnitTest, ['unit-test-admin']);
    gulp.watch(paths.sass, ['sass']);
});