Dir["#{File.dirname(__FILE__)}/mods/**/*.rb"].each { |f| require f; }

module Venuebook
   class API < Grape::API
      version 'v1', using: :path
      format :json

      helpers do
         def rsa_private
            OpenSSL::PKey::RSA.generate 2048
         end

         def rsa_public
            rsa_private.public_key
         end

      #    def warden
      #       puts "WARDEN !"
      #       puts env['warden']
      #       env['warden']
      #    end

      #    def current_user
      #       warden.user
      #    end

      #    def authenticate!
      #       unless current_user
      #          puts "current_user: #{current_user.inspect}"
      #          # Rack::Response.new({status: 401, message: '401 Unauthorized'}.to_json, 401, { 'Content-type' => 'text/error' }).finish
      #          error!({status: 401, message: "401 Unauthorized"}, 401)
      #       end
      #    end
      end

      get do
         "Hello api"
      end

      mount Venuebook::SessionAPI
      mount Venuebook::VenueAPI
      mount Venuebook::CenterAPI
      mount Venuebook::EventAPI
      mount Venuebook::ParticipantAPI
      mount Venuebook::EventAttendanceAPI
   end
end
