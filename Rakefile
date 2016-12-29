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
