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
      sh "gitbook build . ../docs"
    end
    sh "yardoc -o docs/api"
  end

  desc "start gitbook server"
  task :serve do
    cd "book" do
      sh "gitbook serve"
    end
  end
end

desc "git ci, git tag and git push"
task :release do
  load 'lib/ovto/version.rb'
  sh "git diff"
  v = "v#{Ovto::VERSION}"
  puts "release as #{v}? [y/N]"
  break unless $stdin.gets.chomp == "y"

  sh "bundle exec rake docs:build"
  sh "git ci -am '#{v}'"
  sh "git tag '#{v}'"
  sh "git push origin master --tags"
  sh "gem build ovto"
  sh "gem push ovto-#{Ovto::VERSION}.gem"
end
