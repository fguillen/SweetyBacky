# require 'bundler/gem_tasks'

require 'rake'
require 'rake/testtask'
require 'bundler'

Bundler::GemHelper.install_tasks

task :default => :test

Rake::TestTask.new do |t|
  t.libs << '.'
  t.test_files = FileList['test/*_test.rb']
  t.verbose = true
end

namespace :test do
  
  desc "run s3 test in real"
  task :s3 do
    test_task = 
      Rake::TestTask.new("s3_tests") do |t|
        t.libs << '.'
        t.test_files = FileList['test/s3/*_test.rb']
        t.verbose = true
      end
  
    task("s3_tests").execute
  end
  
end