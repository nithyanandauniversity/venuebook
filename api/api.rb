Dir["#{File.dirname(__FILE__)}/mods/**/*.rb"].each { |f| require f; puts f }

module Venuebook
   class API < Grape::API
      version 'v1', using: :path
      format :json
      get do
	 "Hello api"
      end

      mount Venuebook::Venue
   end
end
