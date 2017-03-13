module Venuebook
	class UserAPI < Grape::API
		namespace "users" do

			before do
				authenticate!
			end

			get '/current_user' do
				current_user
			end

			get do
				if params[:search_coordinators] && current_user['role'] < 5
					if authorize! :read, User
						users = User.where('role > 3').where('role < 6')
						[{users: users}]
					end
				end
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