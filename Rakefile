# frozen_string_literal: true

require "bundler/setup"
require "bundler/gem_tasks"
require "rake/testtask"

Rake::TestTask.new(:test) do |t|
  t.libs << "test"
  t.test_files = FileList["test/lib/**/*_test.rb"]
  t.ruby_opts = ["-r test_helper"]
end

Rake::TestTask.new("test:integration") do |t|
  t.test_files = FileList["test/integration/minitest/*_test.rb"]
end

task default: %i[test test:integration]
