class Venue < Sequel::Model
	one_to_many :events
end
