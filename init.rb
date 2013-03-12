# -*- encoding : utf-8 -*-
require 'bundler/setup'

Bundler.require
# redis client
$redis = Redis.new(host: '127.0.0.1', port: 6379)

