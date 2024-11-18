## Amazon Simple Email Service (SES) as an ActionMailbox Ingress

[![Gem Version](https://badge.fury.io/rb/aws-actionmailbox-ses.svg)](https://badge.fury.io/rb/aws-actionmailbox-ses)
[![Build Status](https://github.com/aws/aws-actionmailbox-ses-ruby/workflows/CI/badge.svg)](https://github.com/aws/aws-actionmailbox-ses-ruby/actions)
[![Github forks](https://img.shields.io/github/forks/aws/aws-actionmailbox-ses-ruby.svg)](https://github.com/aws/aws-actionmailbox-ses-ruby/network)
[![Github stars](https://img.shields.io/github/stars/aws/aws-actionmailbox-ses-ruby.svg)](https://github.com/aws/aws-actionmailbox-ses-ruby/stargazers)

This gem contains an [ActionMailbox](https://guides.rubyonrails.org/action_mailbox_basics.html)
ingress using Amazon SES, SNS, and S3.

## Installation

Add this gem to your Rails project's Gemfile:

```ruby
gem 'aws-sdk-rails', '~> 4'
gem 'aws-actionmailbox-ses', '~> 0'
```

Then run `bundle install`.

This gem also brings in the following AWS gems:

* `aws-sdk-s3`
* `aws-sdk-sns`

You will have to ensure that you provide credentials for the SDK to use. See the
latest [AWS SDK for Ruby Docs](https://docs.aws.amazon.com/sdk-for-ruby/v3/api/index.html#Configuration)
for details.

If you're running your Rails application on Amazon EC2, the AWS SDK will
check Amazon EC2 instance metadata for credentials to load. Learn more:
[IAM Roles for Amazon EC2](http://docs.aws.amazon.com/AWSEC2/latest/UserGuide/iam-roles-for-amazon-ec2.html)

## Configuration

### Amazon SES/SNS

1. [Configure SES](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-notifications.html)
to [save emails to S3](https://docs.aws.amazon.com/ses/latest/dg/receiving-email-action-s3.html)
or to send them as raw messages.

2. [Configure the SNS topic for SES or for the S3 action](https://docs.aws.amazon.com/ses/latest/DeveloperGuide/receiving-email-action-sns.html)
to send notifications to +/rails/action_mailbox/ses/inbound_emails+. For example,
if your website is hosted at https://www.example.com then configure _SNS_ to
publish the _SES_ notification topic to this _HTTP_ endpoint:
https://example.com/rails/action_mailbox/ses/inbound_emails

### Rails

1. Configure _ActionMailbox_ to accept emails from Amazon SES:

    ```ruby
    # config/environments/production.rb
    config.action_mailbox.ingress = :ses
    ```

2. Configure which _SNS_ topic will be accepted and what region.

    Note: The bucket's region, which stores the emails, does not need to match
    the SNS topic's region.
    
    ```ruby
    # config/environments/production.rb
    config.action_mailbox.ses.subscribed_topic = 'arn:aws:sns:us-west-2:012345678910:example-topic-1'
    config.action_mailbox.ses.s3_client_options = { region: 'us-east-1' }
    ```

SNS Subscriptions will now be auto-confirmed and messages will be automatically
handled via _ActionMailbox_.

Note: Even if you manually confirm subscriptions, you will still need to provide
a list of subscribed topics; messages from unrecognized topics will be ignored.

See [ActionMailbox documentation](https://guides.rubyonrails.org/action_mailbox_basics.html) for full usage information.

## Testing

Two _RSpec_ _request spec_ helpers are provided to facilitate testing
_Amazon SNS/SES_ notifications in your application:

* `action_mailbox_ses_deliver_subscription_confirmation`
* `action_mailbox_ses_deliver_email`

Include the `Aws::ActionMailbox::SES::RSpec` extension in your tests:

```ruby
# spec/rails_helper.rb

require 'aws/action_mailbox/ses/rspec'

RSpec.configure do |config|
  config.include Aws::ActionMailbox::SES::RSpec
end
```

Configure your _test_ environment to accept the default topic used by the provided helpers:

```ruby
# config/environments/test.rb
config.action_mailbox.ses.subscribed_topic = 'topic:arn:default'
```

### Example Usage

```ruby
# spec/requests/amazon_emails_spec.rb
RSpec.describe 'amazon emails', type: :request do
  it 'delivers a subscription notification' do
    action_mailbox_ses_deliver_subscription_confirmation
    expect(response).to have_http_status :ok
  end

  it 'delivers an email notification' do
    action_mailbox_ses_deliver_email(mail: Mail.new(to: 'user@example.com'))
    expect(ActionMailbox::InboundEmail.last.mail.recipients).to eql ['user@example.com']
  end
end
```

You may also pass the following keyword arguments to both helpers:

* `topic`: The _SNS_ topic used for each notification (default: `topic:arn:default`).
* `authentic`: The `Aws::SNS::MessageVerifier` class is stubbed by these helpers;
set `authentic` to `true` or `false` to define how it will verify
incoming notifications (default: `true`).
