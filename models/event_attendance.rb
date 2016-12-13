class EventAttendance < Sequel::Model
   has_one :event
   has_one :participant
end
