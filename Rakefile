require 'assert/rake_tasks'
include Assert::RakeTasks

require 'bundler'
Bundler::GemHelper.install_tasks

if RUBY_VERSION =~ /^1.8/
  require 'rcov/rcovtask'
  Rcov::RcovTask.new('coverage') do |t|
    t.test_files = FileList['test/**/*_test.rb']
    t.rcov_opts << "--no-html"
    t.verbose = true
  end
else
  task :coverage do
    ENV['COVERAGE'] = "true"
    Rake::Task['test'].execute
  end
end
