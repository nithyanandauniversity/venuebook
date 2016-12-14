class EventAttendance < Sequel::Model
   many_to_one :event
   many_to_one :participant
end
