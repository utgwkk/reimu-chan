#!/usr/bin/env ruby
require 'open-uri'
require 'slack'
require 'twitter'
require 'tweetstream'
require_relative './methods'

USERNAME = 'Reimu-chan'
DOWNLOAD_DIR = './imgs/'
CHANNEL = '#utgw-memo'
ICON_EMOJI = ':reimu:'

options = {:channel => CHANNEL, :text => '', :username => USERNAME, :icon_emoji => ICON_EMOJI}

begin
  YOUR_SCREEN_NAME = Twitter::REST::Client.new do |config|
    config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
    config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
    config.access_token        = ENV['TWITTER_ACCESS_TOKEN_KEY']
    config.access_token_secret = ENV['TWITTER_ACCESS_SECRET']
  end.verify_credentials.screen_name
rescue
  YOUR_SCREEN_NAME = 'utgwkk'
end

TweetStream.configure do |config|
  config.consumer_key        = ENV['TWITTER_CONSUMER_KEY']
  config.consumer_secret     = ENV['TWITTER_CONSUMER_SECRET']
  config.oauth_token         = ENV['TWITTER_ACCESS_TOKEN_KEY']
  config.oauth_token_secret  = ENV['TWITTER_ACCESS_SECRET']
  config.auth_method         = :oauth
end

client = TweetStream::Client.new

Slack.configure do |config|
  config.token = ENV['SLACK_TOKEN']
end

client.on_inited do
  puts 'ちょっと場所を借りるわ'
end

options[:text] = 'ちょっと場所を借りるわ'
Slack.chat_postMessage(options)

client.on_event(:favorite) do |event|
  source = event[:source]
  target_object = event[:target_object]
  if source[:screen_name] == YOUR_SCREEN_NAME && target_object[:extended_entities]
    url = create_twitter_url(target_object[:id], target_object[:user][:screen_name])
    puts url
    options[:text] = url
    Slack.chat_postMessage(options)
    target_object[:extended_entities][:media].each do |media|
      download_url = media[:media_url_https]
      download_filepath = File.join(DOWNLOAD_DIR, File::basename(download_url))
      body = open(download_url, &:read)
      File.binwrite(download_filepath, body)
    end
  end
end

begin
  client.userstream
rescue Interrupt
  options[:text] = 'おやすみなさい'
  Slack.chat_postMessage(options)
rescue Exception => e
  options[:text] = "画像を保存していたらエラーが発生したわ\nTraceBackを貼っておくから修正しておいてよね\n```"
  options[:text] += e.to_s + "\n"
  options[:text] += e.backtrace.join("\n")
  options[:text] += "\n```\nじゃあ、私は失礼するわね"
  Slack.chat_postMessage(options)
end
