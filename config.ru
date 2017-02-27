#!/usr/bin/env rackup
# encoding: utf-8

# This file can be used to start Padrino,
# just execute it from the command line.

require File.dirname(__FILE__) + '/lib/warden_initializer.rb'

use Rack::Session::Cookie, :secret => ENV['SESSION_SECRET']

use Warden::Manager do |manager|
	manager.default_strategies :jwt
	manager.failure_app = Padrino.application
end

require File.expand_path("../config/boot.rb", __FILE__)

run Padrino.application
