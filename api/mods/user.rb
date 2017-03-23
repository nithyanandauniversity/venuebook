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
				elsif params[:email]
					if authorize! :read, User
						[{user: User.find_by_email(params[:email])}]
					end
				elsif params[:search]
					return User.search(params[:search])
				end
			end

			post do
				if authorize! :create, User
					user = User.create(params[:user])
					user
				end
			end

			put '/change_password/:id' do
				user = User.find(id: params[:id])

				if User.authenticate({email: user.email, password: params[:user][:old_password]})
					user.update(password: params[:user][:password])
					user
				else
					error!({status: 401, message: "401 Unauthorized"}, 401)
				end
			end

		end
	end
end

