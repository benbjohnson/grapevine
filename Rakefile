lib = File.expand_path('lib', File.dirname(__FILE__))
$:.unshift lib unless $:.include?(lib)

require 'rubygems'
require 'rake'
require 'rake/rdoctask'
require 'rspec/core/rake_task'
require 'grapevine'

#############################################################################
#
# Standard tasks
#
#############################################################################

require 'rcov/rcovtask'
Rcov::RcovTask.new do |t|
  t.libs << "spec"
  t.test_files = FileList['spec/**/*_spec.rb']
  t.rcov_opts = ['--exclude', 'gems\/,spec\/']
  t.verbose = true
end

Rake::RDocTask.new do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title = "Grapevine #{Grapevine::VERSION}"
  rdoc.rdoc_files.include('README*')
  rdoc.rdoc_files.include('lib/**/*.rb')
end

task :console do
  sh "irb -rubygems -r ./lib/grapevine.rb"
end


#############################################################################
#
# Packaging tasks
#
#############################################################################

task :release do
  puts ""
  print "Are you sure you want to relase Grapevine #{Grapevine::VERSION}? [y/N] "
  exit unless STDIN.gets.index(/y/i) == 0
  
  unless `git branch` =~ /^\* master$/
    puts "You must be on the master branch to release!"
    exit!
  end
  
  # Build gem and upload
  sh "gem build grapevine.gemspec"
  sh "gem push grapevine-#{Grapevine::VERSION}.gem"
  sh "rm grapevine-#{Grapevine::VERSION}.gem"
  
  # Commit
  sh "git commit --allow-empty -a -m 'v#{Grapevine::VERSION}'"
  sh "git tag v#{Grapevine::VERSION}"
  sh "git push origin master"
  sh "git push origin v#{Grapevine::VERSION}"
end
