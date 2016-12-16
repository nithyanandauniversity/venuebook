class Event < Sequel::Model
	self.plugin :timestamps
	one_to_many :event_venue
end
