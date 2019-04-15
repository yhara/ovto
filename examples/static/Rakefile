desc 'compile into js'
task :default do
  sh 'bundle exec opal -c -g ovto app.rb > app.js'
end

desc 'start auto-compiling'
task :watch do
  sh 'ifchanged app.rb -d "bundle exec rake"'
end
