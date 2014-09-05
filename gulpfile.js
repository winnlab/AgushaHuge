var gulp = require('gulp');
var gutil = require('gulp-util');
var coffee = require('gulp-coffee');

var paths = {
    coffee: ['./_client-dev/*.coffee', './_client-dev/*/*.coffee']
};

gulp.task('coffee', function () {
    gulp.src(paths.coffee)
        .pipe(coffee({bare: true}).on('error', gutil.log))
        .pipe(gulp.dest('./public/js/admin/scripts'));
});

gulp.task('watch', function () {
    gulp.watch(paths.coffee, ['coffee']);
});