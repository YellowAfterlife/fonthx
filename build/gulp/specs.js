var gulp = require('gulp');
var exec = require('child_process').exec;

gulp.task("specs", function(cb) {
	exec('haxe build/spec/specs.hxml', function (err, stdout, stderr) {
		console.log(stdout);
		console.log(stderr);
		cb(err);
	});
});

gulp.task("specs-watch", function() {
	gulp.watch(["src/**/*.hx", "spec/**/*.hx"], ["specs"]);
});

