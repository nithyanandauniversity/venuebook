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
		user = self.find(email: params.email)
		user && user.password == params.password
	end

end
