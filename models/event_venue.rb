class EventVenue < Sequel::Model
	self.plugin :timestamps
	many_to_one :event
	many_to_one :venue
	many_to_one :user, :select => [:id, :first_name, :email]
end
