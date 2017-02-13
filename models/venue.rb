class Venue < Sequel::Model
	self.plugin :timestamps
	many_to_one :center
	one_to_many :addresses
	one_to_many :event_venue
end
