require 'html-proofer'

# Path to Tailwind CLI (downloaded or local)
TAILWIND_CLI = ENV['TAILWIND_CLI'] || './tailwindcss'

task default: [:serve]

desc 'Download Tailwind CLI if not present'
task :tailwind_setup do
	unless File.exist?(TAILWIND_CLI)
		platform = case RUBY_PLATFORM
		when /darwin.*arm64/ then 'macos-arm64'
		when /darwin/ then 'macos-x64'
		when /linux.*arm64/ then 'linux-arm64'
		else 'linux-x64'
		end
		sh "curl -sLO https://github.com/tailwindlabs/tailwindcss/releases/download/v4.1.18/tailwindcss-#{platform}"
		sh "chmod +x tailwindcss-#{platform}"
		sh "mv tailwindcss-#{platform} #{TAILWIND_CLI}"
	end
end

desc 'Build Tailwind CSS'
task :tailwind_build => :tailwind_setup do
	sh "#{TAILWIND_CLI} -i source/assets/css/input.css -o source/assets/css/main.css --minify"
end

desc 'Watch Tailwind CSS'
task :tailwind_watch => :tailwind_setup do
	sh "#{TAILWIND_CLI} -i source/assets/css/input.css -o source/assets/css/main.css --watch"
end

desc 'Serve Jekyll site locally with Tailwind'
task :serve => :tailwind_build do
	# Run Tailwind watcher in background, then Jekyll
	tailwind_pid = Process.spawn("#{TAILWIND_CLI} -i source/assets/css/input.css -o source/assets/css/main.css --watch")
	begin
		sh "bundle exec jekyll serve --drafts --livereload"
	ensure
		Process.kill('TERM', tailwind_pid) rescue nil
	end
end

desc 'Clean Jekyll site'
task :clean do
	sh "bundle exec jekyll clean"
end

desc 'Validate generated site through HTML proofer'
task :proofer do
	options = {
		:assume_extension => true,
		:http_status_ignore => [999],
		:url_ignore => ["https://jekyllrb.com", "https://www.websiteplanet.com/webtools/favicon-generator"],
		:typhoeus => {
			:ssl_verifypeer => false,
			:ssl_verifyhost => 0
		}
	}
	HTMLProofer.check_directory("./_site", options).run
end
