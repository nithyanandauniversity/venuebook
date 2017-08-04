require 'bcrypt'

class User < Sequel::Model
	self.plugin :timestamps
	include BCrypt

	def center_code
		if center_id
			center = Center.find(id: center_id)
			center.code
		else
			nil
		end
	end

	def password
		@password ||= Password.new(encrypted_password)
	end

	def password=(new_password)
		@password = Password.create(new_password)
		self.encrypted_password = @password
	end

	def self.authenticate(params)
		user = self.find(email: params[:email])
		user && user.password == params[:password]
	end

	def center
		Center.find(id: center_id) if center_id
	end

	def self.find_by_email(email)
		User.find(email: email)
	end

	def user_permissions
		JSON.parse(permissions) if role == 2 && permissions
	end

	def is_allowed(center_id)
		allowed_centers.include? center_id
	end

	def allowed_centers
		if role == 2 && permissions
			allowed_center_list.all
		end
	end

	def allowed_center_list
		if user_permissions['areas']
			centers = Center.where(area: user_permissions['areas'])
		elsif user_permissions['countries']
			centers = Center.where(country: user_permissions['countries'])
		elsif user_permissions['centers']
			centers = Center.where(id: user_permissions['centers'])
		end
	end

	def self.search(params)
		# puts params.inspect
		size       = params && params[:limit].to_i || 10
		page       = params && params[:page].to_i || 1
		keyword    = params && params[:keyword] || nil
		attributes = params && params[:attributes] || nil

		if (keyword && !keyword.blank?) || (attributes && !attributes.blank?)
			# SEARCH
			if !keyword.blank?
				users = User.order(:role)
				if attributes && !attributes.blank?
					users = users.where(center_id: attributes.center_id) if attributes.center_id
					users = users.where(role: attributes.roles) if attributes.roles
					users = users.where(
						(Sequel.ilike(:first_name, "%#{keyword}%")) |
						(Sequel.ilike(:last_name, "%#{keyword}%")) |
						(Sequel.ilike(:email, "%#{keyword}%"))
					).paginate(page, size)
				else
					users = users.where(
						(Sequel.ilike(:first_name, "%#{keyword}%")) |
						(Sequel.ilike(:last_name, "%#{keyword}%")) |
						(Sequel.ilike(:email, "%#{keyword}%"))
					).paginate(page, size)
				end
			else
				users = User.order(:role)
				users = users.where(center_id: attributes.center_id) if attributes.center_id
				users = users.where(role: attributes.roles) if attributes.roles
				users = users.paginate(page, size)
			end
		else
			# ALL
			users = User.order(:role).paginate(page, size)
		end

		[{
			users: JSON.parse(users.to_json({
				:include => [:center, :user_permissions],
				:except => [:encrypted_password]
			})),
			page_count: users.page_count,
			page_size: users.page_size,
			page_range: users.page_range,
			current_page: users.current_page,
			pagination_record_count: users.pagination_record_count,
			current_page_record_count: users.current_page_record_count,
			current_page_record_range: users.current_page_record_range,
			first_page: users.first_page?,
			last_page: users.last_page?
		}]
	end

end
