require 'bcrypt'

class User < Sequel::Model
	self.plugin :timestamps
	include BCrypt

	def password
		@password ||= Password.new(encrypted_password)
	end

	def password=(new_password)
		@password = Password.create(new_password)
		self.encrypted_password = @password
	end

	def self.authenticate(params)
		user = self.find(email: params.email)
		user.password == params.password
	end

end
