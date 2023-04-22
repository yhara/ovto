require 'opal/rspec/rake_task'
Opal.append_path "./opal"
Opal.append_path "./spec"
Opal.use_gem "ovto"

Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.pattern = 'spec/**/*_spec.rb'
end

namespace :docs do
  desc "build docs"
  task :build do
    cd "book" do
      sh "mdbook build"
    end
    sh "yardoc -o docs/api"
  end
end

desc "git ci, git tag and git push"
task :release do
  cd('examples/sinatra'){ sh 'bundle update' }
  cd('examples/static'){ sh 'bundle update' }
  load 'lib/ovto/version.rb'
  sh "git diff HEAD"
  v = "v#{Ovto::VERSION}"
  puts "release as #{v}? [y/N]"
  break unless $stdin.gets.chomp == "y"

  sh "gem build ovto"  # First, make sure we can build gem
  sh "bundle exec rake docs:build"
  sh "git ci -am '#{v}'"
  sh "git tag '#{v}'"
  sh "git push origin master --tags"
  sh "gem push ovto-#{Ovto::VERSION}.gem"
end
