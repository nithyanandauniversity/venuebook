class Address < Sequel::Model
	self.plugin :timestamps
	many_to_one :venue
end
