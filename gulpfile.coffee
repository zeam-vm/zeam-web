gulp = require 'gulp'
rev = require 'gulp-rev'
revReplace = require 'gulp-rev-replace'
revDel = require 'rev-del'
sequence = require 'run-sequence'
del = require 'del'
vinylPaths = require 'vinyl-paths'


gulp.task 'rev', () ->
  gulp.src ['build/**/*.+(js|css|png|gif|jpg|jpeg|svg|woff|ico)', '!build/**/*-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]*.+(js|css|png|gif|jpg|jpeg|svg|woff|ico)']
    .pipe rev()
    .pipe gulp.dest 'build/'
    .pipe rev.manifest('manifest.json')
    .pipe revDel({ dest: 'build/'})
    .pipe gulp.dest('build/')

gulp.task 'rev:replace', () ->
  manifest = gulp.src 'build/manifest.json'
  gulp.src 'build/**/*.+(html|css|js)'
    .pipe revReplace(manifest: manifest)
    .pipe gulp.dest('build/')

gulp.task 'rev:clean', () ->
  gulp.src ['build/**/*.+(js|css|png|gif|jpg|jpeg|svg|woff|ico)', '!build/**/*-[0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f][0-9a-f]*.+(js|css|png|gif|jpg|jpeg|svg|woff|ico)']
    .pipe(vinylPaths(del))

gulp.task 'post', () ->
  sequence 'rev', 'rev:replace', 'rev:clean'

