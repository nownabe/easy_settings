require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec) do |t|
  t.exclude_pattern = "./spec/easy_settings_test/**/*_spec.rb"
end
task default: :spec

