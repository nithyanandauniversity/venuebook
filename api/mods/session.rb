module Venuebook

	class SessionAPI < Grape::API
		namespace "sessions" do

			get '/authenticate' do
				if authenticated
					return {status: true}
				else
					return {status: false}
				end
			end

			post '/login' do

				if User.authenticate(params.auth)
					user = User.find(email: params.auth.email)

					payload = {
						:id => user.id,
						:first_name => user.first_name,
						:last_name => user.last_name,
						:role => user.role,
						:email => user.email,
						:center_id => user.center_id,
						:center_code => user.center.code
					}

					# token = JWT.encode payload, rsa_private, 'RS256'
					token = JWT.encode payload, hmac_secret, 'HS256'

					{
						token: token,
						current_user: payload,
						allowed_centers: user.allowed_centers,
						center: user.center
					}
				else
					{}
				end

			end

		end
	end

end

