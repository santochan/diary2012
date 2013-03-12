# -*- encoding : utf-8 -*-
require "redis"

@redis = @redis = Redis.new(:host => "127.0.0.1", :port => 6379)

user_keys = @redis.keys "user:*"

user_keys.each do |user_key|
  uid= user_key.split(':')[1]
  uname = @redis.get(user_key)
  puts "#{uid}--#{uname}"
  @redis.set("user_name:#{uname}",uid)
end

name_keys= @redis.keys "user_name:*"

name_keys.each do |user_name|
  uname = user_name.split(':')[1]
  uid = @redis.get(user_name)
  puts "#{uname}-----#{uid}"
end
