require 'yaml'

task :default => "blahg:build_and_run"

namespace :blahg do
	desc "Compile Sass into CSS"
	task :compile_sass do
		fname = "legwarmers"
		puts "Compliling Sass..."
		sh "sass css/#{fname}.scss:css/#{fname}.css"
	end

	desc "Start Development Server"
	task :start_server do
		puts "Starting devel server..."
		sh "jekyll --server"
	end

	desc "Pull in files from dropbox folder"
	task :dropbox_pull do
		puts "check dropbox for new posts"
		
		dir = Dir.new("/Users/rob/Dropbox/posts")
		dir.each do |entry|
			# check for files that look like posts
			if entry =~ /(w|-)*\.(md|html)/	
				posts_dir = Dir.new("_posts")
				if posts_dir.entries.include?(entry)
					# post already exists
					fname = entry + "_conflict"

					FileUtils.cp "#{dir.path}/#{entry}", "#{posts_dir.path}/#{fname}"
					puts "Post conflict: #{entry}"
					puts "Conflicted copy: #{fname}"
				else
					# copy
					FileUtils.cp "#{dir.path}/#{entry}", posts_dir.path
					puts "New post: #{entry}"
				end

				# remove the file
				FileUtils.rm "#{dir.path}/#{entry}"
			end
		end
	end

	desc "Build and Run"
	task :build_and_run do
		# make sure that we are set for test, compile sass, start local server
		# set url for test
		config = YAML.load_file("_config.yml")	
		config["url"] = "http://localhost:4000"

		File.open("_config.yml", "w") do |f|
			f.puts(config.to_yaml)
		end

		Rake::Task["blahg:compile_sass"].invoke
		Rake::Task["blahg:start_server"].invoke
	end

	desc "Build"
	task :build do
		# compiles sass and generates the html pages
		Rake::Task["blahg:compile_sass"].invoke
		sh "jekyll"
	end

	desc "Publish"
	task :publish do
		# set url for publishing
		config = YAML.load_file("_config.yml")	
		config["url"] = "http://robu3.github.com"

		File.open("_config.yml", "w") do |f|
			f.puts(config.to_yaml)
		end

		# now build
		Rake::Task["blahg:build"].invoke
	end
end
