require 'rake'
require 'rake/rdoctask'

desc 'Default: generate rdoc'
task :default => :rdoc

desc 'Generate documentation for the DiscogsApi plugin.'
Rake::RDocTask.new(:rdoc) do |rdoc|
  rdoc.rdoc_dir = 'rdoc'
  rdoc.title    = 'DiscogsApi'
  rdoc.options << '--line-numbers' << '--inline-source'
  rdoc.rdoc_files.include('README.rdoc')
  rdoc.rdoc_files.include('lib/**/*.rb')
end