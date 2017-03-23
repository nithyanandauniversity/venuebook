class Setting < Sequel::Model
	self.plugin :timestamps

	def obj
		JSON.parse(value) if value
	end

end
