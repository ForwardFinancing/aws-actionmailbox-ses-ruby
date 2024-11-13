# frozen_string_literal: true

require 'rails'
require 'action_mailbox/engine'

require 'aws-actionmailbox-ses'

# @api private
module Dummy
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = true
    config.secret_key_base = 'secret'

    config.active_storage.service = :test
    config.action_mailbox.ingress = :ses
    config.action_mailbox.ses.subscribed_topic = 'arn:aws:sns:us-west-2:012345678910:example-topic'
  end
end
