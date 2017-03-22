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
						users = User.where('role < 5').where('role >= 3')
						users = users.where('center_id = ?', current_user['center_id'] || params[:center_id])

						users = users.or('role = 1') if current_user['role'] == 1

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

