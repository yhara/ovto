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
