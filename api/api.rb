Dir["#{File.dirname(__FILE__)}/mods/**/*.rb"].each { |f| require f; }

module Venuebook
   class API < Grape::API
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

         def authenticated
            token = request.headers['Token']
            if token
               begin
                  decoded_token = JWT.decode token, hmac_secret, true, { :algorithm => 'HS256' }
                  if decoded_token
                     return true
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

      get do
         "Hello api"
      end

      mount Venuebook::SessionAPI
      mount Venuebook::UserAPI
      mount Venuebook::VenueAPI
      mount Venuebook::CenterAPI
      mount Venuebook::EventAPI
      mount Venuebook::ParticipantAPI
      mount Venuebook::EventAttendanceAPI
   end
end
