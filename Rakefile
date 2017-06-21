require 'html-proofer'

task default: [
	:serve
]

desc 'Serve Jekyll site locally'
task :serve do
	sh "bundle exec jekyll serve --drafts"
end

desc 'Clean Jekyll site'
task :clean do
	sh "bundle exec jekyll clean"
end

desc 'Build Jekyll for production'
task :build do
	sh "JEKYLL_ENV=production bundle exec jekyll build"
end

desc 'Validate generated side through HTML proofer'
task :proofer do
	options = {
		:assume_extension => true,
		:http_status_ignore => [999]
	}
	HTMLProofer.check_directory("./_site", options).run
end
