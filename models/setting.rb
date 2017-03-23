class Setting < Sequel::Model
	self.plugin :timestamps

	def obj
		# puts JSON.parse(value)
		JSON.parse(value) if value
	end

end
