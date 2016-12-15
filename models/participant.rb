class Participant < Sequel::Model
	self.plugin :timestamps
	one_to_many :event_attendances
end
