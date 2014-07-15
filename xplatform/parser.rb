#!/usr/bin/ruby
# Ava Gailliot

require 'net/http'
require 'uri'

IO.foreach("yahoo-disclosure.txt") do |line|
    user = line.split(":")[1].split("@")[0]
    pass = line.split(":")[2]
    email = line.split(":")[1]
    begin
        uri = URI.parse("http://#{user}.imgur.com")
        res = Net::HTTP.get_response(uri)
    rescue URI::InvalidURIError => err
        next
    end
    puts "#{user} #{pass} #{email}\n" if res.code.eql? "200"
