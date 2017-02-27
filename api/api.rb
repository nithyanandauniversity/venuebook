Dir["#{File.dirname(__FILE__)}/mods/**/*.rb"].each { |f| require f; puts f }

module Venuebook
   class API < Grape::API
      version 'v1', using: :path
      format :json

      helpers do
         def warden
            puts "WARDEN !"
            puts env['warden']
            env['warden']
         end

         def current_user
            warden.user
         end

         def authenticate!
            unless current_user
               puts "current_user: #{current_user.inspect}"
               error!({status: 401, message: "401 Unauthorized"}, 401)
            end
         end
      end

      rescue_from :all do |e|
         puts "E :: #{e.inspect}\n"
         Rack::Response.new([ e.message ], 500, { 'Content-type' => 'text/error' }).finish
      end

      get do
         "Hello api"
      end

      # get '/unauthenticated' do
      #    puts "\nUNAUTHENTICATED!\n"
      #    Rack::Response.new({status: 401, message: '401 Unauthorized'}, 401, { 'Content-type' => 'text/json' }).finish
      #    # {status: 401, message: '401 Unauthorized'}
      # end

      mount Venuebook::VenueAPI
      mount Venuebook::CenterAPI
      mount Venuebook::EventAPI
      mount Venuebook::ParticipantAPI
      mount Venuebook::EventAttendanceAPI
   end
end
