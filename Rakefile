# frozen_string_literal: true

require 'rspec/core/rake_task'
require 'rubocop/rake_task'

Dir.glob('tasks/**/*.rake').each do |task_file|
  load task_file
end

RuboCop::RakeTask.new

RSpec::Core::RakeTask.new

desc 'Reset and migrate the database. Called before running tests.'
task :db_migrate_reset do
  Dir.chdir('spec/dummy') do
    version = ENV.delete('VERSION') # ActiveRecord uses this
    puts 'Dropping database...'
    `bundle exec bin/rails db:drop`
    puts 'Migrating database...'
    `bundle exec bin/rails db:migrate`
    ENV['VERSION'] = version
  end
end

task test: [:sign_aws_fixtures, :db_migrate_reset, :spec]
task 'release:test' => :test
