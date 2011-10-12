require 'rubygems'
require 'bundler'
Bundler.require

require 'twitter/json_stream'
require './secret' if File.exist?("./secret.rb")

CONSUMER_KEY    ||= ENV['CONSUMER_KEY']
CONSUMER_SECRET ||= ENV['CONSUMER_SECRET']
ACCESS_KEY      ||= ENV['ACCESS_KEY']
ACCESS_SECRET   ||= ENV['ACCESS_SECRET']
TRACK           ||= ENV['TRACK']

Pusher.app_id   ||= ENV['PUSHER_ID']
Pusher.key      ||= ENV['PUSHER_KEY']
Pusher.secret   ||= ENV['PUSHER_SECRET']

EventMachine::run {
  stream = Twitter::JSONStream.connect(
    :path    => "/1/statuses/filter.json?track=#{TRACK}",
    :oauth => {
      :consumer_key    => CONSUMER_KEY,
      :consumer_secret => CONSUMER_SECRET,
      :access_key      => ACCESS_KEY,
      :access_secret   => ACCESS_SECRET
    },
    :ssl => true
  )

  stream.each_item do |item|
    $stdout.print "item: #{item}\n"
    $stdout.flush
    Pusher['twitter'].trigger('new-post', item)
  end

  stream.on_error do |message|
    $stdout.print "error: #{message}\n"
    $stdout.flush
  end

  stream.on_reconnect do |timeout, retries|
    $stdout.print "reconnecting in: #{timeout} seconds\n"
    $stdout.flush
  end
  
  stream.on_max_reconnects do |timeout, retries|
    $stdout.print "Failed after #{retries} failed reconnects\n"
    $stdout.flush
  end
}

