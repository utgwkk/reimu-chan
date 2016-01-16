#!/usr/bin/env ruby
require 'slack'
require 'twitter'

YOUR_SCREEN_NAME = Twitter::REST::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN_KEY']
  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
end.verify_credentials.screen_name

client = Twitter::Streaming::Client.new do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.access_token        = ENV['TWITTER_ACCESS_TOKEN_KEY']
  config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
end

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

client.user do |data|
  puts data
end