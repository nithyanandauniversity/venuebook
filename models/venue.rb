class Venue < Sequel::Model
	self.plugin :timestamps
	one_to_many :events
end
