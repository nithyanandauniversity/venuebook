module Venuebook
	class UserAPI < Grape::API
		namespace "users" do

			before do
				authenticate!
			end

			get '/current_user' do
				current_user
			end

			get '/:id' do
				if authorize! :read, User
					user = User.find(id: params[:id])
					JSON.parse(user.to_json({
						:include => [:center, :user_permissions, :allowed_centers],
						:except => [:encrypted_password]
					}))
				end
			end

			get do
				if params[:search_coordinators] && current_user['role'] < 5
					if authorize! :read, User

						center_id = params[:center_id] || current_user['center_id']
						users     = User.where('center_id = ?', center_id)
							.where(role: [3,4])

						if current_user['role'] < 3

							center = Center.find(id: center_id)

							ids = []
							center.leads[:area].each { |u| ids << u['id'] }
							center.leads[:country].each { |u| ids << u['id'] }
							center.leads[:center].each { |u| ids << u['id'] }

							users = users.or('id IN ?', ids)
							users = users.or('center_id = ?', center_id) if current_user['role'] == 1
						end

						[{users: JSON.parse(users.to_json(:except => [:encrypted_password]))}]
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
					unless User.find_by_email(params[:user].email)
						user = User.create(params[:user])

						user.update(center_id: user.allowed_centers.first.id) if user.role == 2 && user.allowed_centers && user.allowed_centers.count > 0

						JSON.parse(user.to_json({:include => [:user_permissions]}))
					else
						error!({status: 409, message: "409 Email Conflict"}, 409)
					end
				end
			end

			put '/:id' do
				if authorize! :update, User
					user = User.find(id: params[:id])
					user.update(params[:user])
					JSON.parse(user.to_json({:include => [:user_permissions]}))
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

			put '/set_default_center/:id' do
				user = User.find(id: params[:id])

				puts user.email
				puts current_user['email']
				puts params[:center_id]

				if user.email == current_user['email'] && params[:center_id]
					user.update(center_id: params[:center_id])
					user
				else
					error!({status: 401, message: "401 Unauthorized"}, 401)
				end
			end

		end
	end
end

