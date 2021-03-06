RACK_ENV = 'test' unless defined?(RACK_ENV)
require File.expand_path(File.dirname(__FILE__) + "/../config/boot")
Dir[File.expand_path(File.dirname(__FILE__) + "/../app/helpers.rb")].each(&method(:require))

RSpec.configure do |config|
	config.mock_with :rspec
	config.include Rack::Test::Methods
	config.color = true

	# Use color not only in STDOUT but also in pagers and files
	config.tty = true

	# Use the specified formatter
	config.formatter = :documentation
end

# You can use this method to custom specify a Rack app
# you want rack-test to invoke:
#
#   app Venuebook::App
#   app Venuebook::App.tap { |a| }
#   app(Venuebook::App) do
#     set :foo, :bar
#   end
#
def app(app = nil, &blk)
  @app ||= block_given? ? app.instance_eval(&blk) : app
  @app ||= Padrino.application
end
