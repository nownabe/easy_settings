require "bundler/gem_tasks"
require "rspec/core/rake_task"

task default: :spec

desc "Run all test"
task spec: ["spec:unit", "spec:rails"]

namespace :spec do
  RSpec::Core::RakeTask.new(:unit) do |t|
    t.exclude_pattern = "./spec/easy_settings_test/**/*_spec.rb"
  end

  desc "Test for rails integration"
  task :rails do
    rails_root = File.expand_path("../spec/easy_settings_test", __FILE__)
    Bundler.with_clean_env do
      system("cd #{rails_root} && bundle install") || abort("Failed bundle install")
      system("cd #{rails_root} && bundle exec rspec") || abort("Failed test in Rails app")
    end
  end
end
