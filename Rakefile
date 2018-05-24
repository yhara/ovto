require 'opal/rspec/rake_task'
Opal.append_path "./opal"
Opal.append_path "./spec"
Opal.use_gem "ovto"

Opal::RSpec::RakeTask.new(:default) do |server, task|
  task.pattern = 'spec/**/*_spec.rb'
end

namespace :doc do
  desc "build docs"
  task :build do
    cd "book" do
      sh "gitbook build . ../doc"
    end
    sh "yardoc -o doc/api"
  end

  desc "start gitbook server"
  task :serve do
    cd "book" do
      sh "gitbook serve"
    end
  end
end
