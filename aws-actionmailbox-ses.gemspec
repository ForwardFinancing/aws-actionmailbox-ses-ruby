# frozen_string_literal: true

version = File.read(File.expand_path('VERSION', __dir__)).strip

Gem::Specification.new do |spec|
  spec.name         = 'aws-actionmailbox-ses'
  spec.version      = version
  spec.author       = 'Amazon Web Services'
  spec.email        = ['aws-dr-rubygems@amazon.com']
  spec.summary      = 'ActionMailbox integration with SES'
  spec.description  = 'Amazon Simple Email Service as an ActionMailbox router'
  spec.homepage     = 'https://github.com/aws/aws-actionmailbox-ses-ruby'
  spec.license      = 'Apache-2.0'
  spec.files        = Dir['LICENSE', 'CHANGELOG.md', 'VERSION', 'lib/**/*', 'app/**/*', 'config/*']

  # Require these versions for user_agent_framework configs
  spec.add_dependency('aws-sdk-s3', '~> 1', '>= 1.123.0')
  spec.add_dependency('aws-sdk-sns', '~> 1', '>= 1.61.0')

  spec.add_dependency('actionmailbox', '~> 7.0')

  spec.required_ruby_version = '>= 2.7'
end
