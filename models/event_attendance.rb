class EventAttendance < Sequel::Model
	self.plugin :timestamps
	many_to_one :event

	REGISTERED                  = 1
	REGISTERED_AND_ATTENDED     = 2
	NOT_REGISTERED_AND_ATTENDED = 3

	def self.all_attendances(event_id)
		return [] unless event_id

		attendances = JSON.parse(EventAttendance.where(event_id: event_id).to_json())

		event_attendances = attendances.collect { |attendance|
			attendance['participant'] = Participant.get(attendance['member_id'])
			attendance['venue']       = Venue.find(id: attendance['venue_id'])
			attendance
		}

		event_attendances
	end
end
