Dir["#{File.dirname(__FILE__)}/mods/**/*.rb"].each { |f| require f; }
require "#{File.dirname(__FILE__)}/audit.rb"

module Venuebook
   class API < Grape::API
      use Audits
      version 'v1', using: :path
      format :json

      helpers do
         def hmac_secret
            'my$ecretK3y'
         end

         def rsa_private
            OpenSSL::PKey::RSA.generate 2048
         end

         def rsa_public
            rsa_private.public_key
         end

         def current_user
            token = authenticated
            return token ? token[0] : nil
         end

         def authorize!(*args)
            ::Ability.new(current_user).authorize!(*args)
         end

         def authenticated
            token = request.headers['Token']
            if token
               begin
                  decoded_token = JWT.decode token, hmac_secret, true, { :algorithm => 'HS256' }
                  if decoded_token
                     return decoded_token
                  else
                     return false
                  end
               rescue Exception => e
                  return false
               end
            end
         end

         def authenticate!
            token = request.headers['Token']

            if token
               begin
                  decoded_token = JWT.decode token, hmac_secret, true, { :algorithm => 'HS256' }
               rescue Exception => e
                  puts e.inspect
                  error!({status: 401, message: "401 Unauthorized"}, 401)
               end
            else
               error!({status: 401, message: "401 Unauthorized"}, 401)
            end
         end

      end

      rescue_from CanCan::AccessDenied do | exception |
         error!({status: 403, message: "Access Denied"}, 403)
      end

      get do
         "Hello api"
      end

      mount Venuebook::SessionAPI
      mount Venuebook::UserAPI
      mount Venuebook::ParticipantAPI
      mount Venuebook::CenterAPI
      mount Venuebook::ProgramAPI
      mount Venuebook::VenueAPI
      mount Venuebook::EventAPI
      mount Venuebook::EventAttendanceAPI
      mount Venuebook::SettingAPI
   end
end
