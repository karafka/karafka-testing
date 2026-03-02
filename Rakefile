# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"

require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/test_helper.rb", "test/**/*_test.rb"]
    .exclude("test/integration/**/*")
end

task default: :test
