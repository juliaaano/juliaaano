task default: [
	:serve
]

require 'html-proofer'

desc 'Clean Jekyll site'
task :clean do
	sh "bundle exec jekyll clean"
end

desc 'Build Jekyll site'
task :build do
	sh "bundle exec jekyll build"
end

desc 'Serve Jekyll site locally'
task :serve do
	sh "bundle exec jekyll serve"
end

desc 'Validate generated side through HTML proofer'
task :proofer do
	sh "JEKYLL_ENV=production bundle exec jekyll build"
	HTMLProofer.check_directory("./_site").run
end
