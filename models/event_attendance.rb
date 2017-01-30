class EventAttendance < Sequel::Model
	self.plugin :timestamps
	many_to_one :event
	many_to_one :participant

	REGISTERED                  = 1
	REGISTERED_AND_ATTENDED     = 2
	NOT_REGISTERED_AND_ATTENDED = 3
end
