module Venuebook
	class UserAPI < Grape::API
		namespace "users" do

			before do
				authenticate!
			end

			post do
				user = User.create(params[:user])
				user
			end

		end
	end
end