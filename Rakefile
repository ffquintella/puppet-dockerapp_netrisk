# frozen_string_literal: true

# This module is developed and tested with Regent (https://github.com/felipe-quintella/regent),
# a self-contained PDK alternative. Prefer the `regent` CLI for day-to-day work:
#
#   regent validate   # parse manifests + metadata.json, lint
#   regent test       # run the rspec-puppet specs through the embedded runner
#   regent build      # produce a Forge-ready tarball in pkg/
#
# This Rakefile is kept only as a thin convenience wrapper for environments that
# already have a Ruby toolchain available. It does not depend on PDK or Bundler.

require 'rspec/core/rake_task'

begin
  require 'rubocop/rake_task'
  RuboCop::RakeTask.new(:rubocop) do |task|
    task.patterns = ['lib/**/*.rb', 'spec/**/*.rb']
  end
rescue LoadError
  # rubocop is optional
end

desc 'Run RSpec tests'
RSpec::Core::RakeTask.new(:spec) do |t|
  t.rspec_opts = '--color --format documentation'
  t.pattern = 'spec/**/*_spec.rb'
  t.fail_on_error = true
end

desc 'Run all tests'
task test: [:spec]

task default: [:spec]
