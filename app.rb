require 'rubygems'
require 'bundler'
Bundler.require

require 'twitter/json_stream'

EventMachine::run {
  stream = Twitter::JSONStream.connect(
    :path    => '/1/statuses/filter.json?track=ruby',
    :auth    => 'USERNAME:PASSWORD',
    :ssl => true
  )

  stream.each_item do |item|
    $stdout.print "item: #{item}\n"
    $stdout.flush
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

