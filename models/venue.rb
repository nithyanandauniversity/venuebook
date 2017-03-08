class Venue < Sequel::Model
	self.plugin :timestamps
	many_to_one :center
	one_to_many :addresses
	one_to_many :event_venue

	def address
		if addresses.length
			addresses[0]
		else
			nil
		end
	end

end
