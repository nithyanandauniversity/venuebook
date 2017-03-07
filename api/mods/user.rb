module Venuebook
	class UserAPI < Grape::API
		namespace "users" do

			before do
				authenticate!
			end

			get '/current_user' do
				current_user
			end

			post do
				if authorize! :create, User
					user = User.create(params[:user])
					user
				end
			end

		end
	end
end