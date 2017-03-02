module Venuebook

	class SessionAPI < Grape::API
		namespace "sessions" do

			post '/login' do

				if User.authenticate(params.auth)
					user = User.find(email: params.auth.email)

					payload = {
						:first_name => user.first_name,
						:last_name => user.last_name,
						:role => user.role
					}

					token = JWT.encode payload, rsa_private, 'RS256'

					{token: token}
				else
					{}
				end

			end

		end
	end

end

