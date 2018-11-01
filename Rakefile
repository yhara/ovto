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

namespace :release do
  task :prepare_commit do
    sh "git ci -am v#{Ovto::VERSION}"
    sh "git tag v#{Ovto::VERSION}"
  end

  task :push_commit do
    sh "git push origin master --tags"
  end

  task :push_gem do
    sh "gem build ovto"
    sh "gem push ovto"
  end
end
