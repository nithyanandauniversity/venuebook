require 'spec_helper'

describe 'Event Attendance' do

	before(:all) do
      User.dataset.all { |u| u.destroy }
      user = User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)

      post "/api/v1/sessions/login", auth: {
         email: "sgsaravana@gmail.com",
         password: "123123"
      }

      response = JSON.parse(last_response.body)
      @token   = response['token']
   end

	it "should be able to create event registration" do
		# Participant.delete_all
		participant = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)
		center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
		event  = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue  = Venue.create(name: "Yogam", center_id: center.id)

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 32

		post "/api/v1/event_attendances/", {attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: participant['member_id'],
			attendance: 1
		}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['event_id']).to eql event.id
		expect(response['venue_id']).to eql venue.id
		expect(response['attendance']).to eql EventAttendance::REGISTERED
		expect(response['member_id']).to eql participant['member_id']
	end

	it "should be able to create event registration and respond with all attendance data if needed" do
		# Participant.delete_all
		participant = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)
		center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam", center_id: center.id)

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 32

		post "/api/v1/event_attendances/", {
			attendance: {
				event_id: event.id,
				venue_id: venue.id,
				member_id: participant['member_id'],
				attendance: 1
			},
			send_all: true
		}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)['event_attendances']

		expect(response.length).to eql 1
	end

	it "should be able to get all attendances for the event" do
		participant = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)
		center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam", center_id: center.id)

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 32

		post "/api/v1/event_attendances/", {
			attendance: {
				event_id: event.id,
				venue_id: venue.id,
				member_id: participant['member_id'],
				attendance: 1
			},
			send_all: true
		}, {'HTTP_TOKEN' => @token}

		get "/api/v1/events/#{event.id}/event_attendances", nil, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)[0]['event_attendances']

		expect(response.length).to eql 1
	end

	it "should mark attendance as REGISTERED_AND_ATTENDED if already registered" do
		participant = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)
		center    = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
		event     = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue     = Venue.create(name: "Yogam", center_id: center.id)
		member_id = participant['member_id'];

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 32

		post "/api/v1/event_attendances/", {attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: member_id,
			attendance_date: event.start_date,
			attendance: 1
		}}, {'HTTP_TOKEN' => @token}

		response   = JSON.parse(last_response.body)
		attendance = EventAttendance.find(id: response['id'])

		event.reload
		expect(event.event_attendances.length).to eql 1

		post "/api/v1/event_attendances/", {attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: member_id,
			attendance_date: event.start_date,
			attendance: 3
		}}, {'HTTP_TOKEN' => @token}

		response   = JSON.parse(last_response.body)

		event.reload
		expect(event.event_attendances.length).to eql 1

	end

	it "should mark attendance as REGISTERED_AND_ATTENDED if already registered for day 1 and attending day2" do
		participant = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)

		center    = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
		event     = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue     = Venue.create(name: "Yogam", center_id: center.id)
		member_id = participant['member_id'];

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 32

		post "/api/v1/event_attendances/", {attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: member_id,
			attendance_date: event.start_date,
			attendance: 1
		}}, {'HTTP_TOKEN' => @token}

		response   = JSON.parse(last_response.body)
		attendance = EventAttendance.find(id: response['id'])

		event.reload
		expect(event.event_attendances.length).to eql 1

		post "/api/v1/event_attendances/", {attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: member_id,
			attendance_date: event.end_date,
			attendance: 3
		}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		event.reload
		expect(event.event_attendances.length).to eql 1
		expect(event.event_attendances[0].attendance).to eql 2
	end

	it "should ignore duplicate entries for same date or same attendance type" do
		participant = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)

		center    = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
		event     = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue     = Venue.create(name: "Yogam", center_id: center.id)
		member_id = participant['member_id'];

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 32

		post "/api/v1/event_attendances/", {attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: member_id,
			attendance_date: event.start_date,
			attendance: 1
		}}, {'HTTP_TOKEN' => @token}

		response   = JSON.parse(last_response.body)
		attendance = EventAttendance.find(id: response['id'])

		event.reload
		expect(event.event_attendances.length).to eql 1

		post "/api/v1/event_attendances/", {attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: member_id,
			attendance_date: event.start_date,
			attendance: 1
		}}, {'HTTP_TOKEN' => @token}

		response   = JSON.parse(last_response.body)
		attendance = EventAttendance.find(id: response['id'])

		event.reload
		expect(event.event_attendances.length).to eql 1
	end

	it "should mark record as registered attendee if he is a registered attendee on previous day" do
		participant = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)

		center    = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
		event     = Event.create(start_date: Date.today, end_date: Date.today + 2.day)
		venue     = Venue.create(name: "Yogam", center_id: center.id)
		member_id = participant['member_id'];

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 32

		post "/api/v1/event_attendances/", {attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: member_id,
			attendance_date: event.start_date,
			attendance: 1
		}}, {'HTTP_TOKEN' => @token}

		response   = JSON.parse(last_response.body)
		attendance = EventAttendance.find(id: response['id'])

		event.reload
		expect(event.event_attendances.length).to eql 1

		post "/api/v1/event_attendances/", {attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: member_id,
			attendance_date: Date.today + 1.day,
			attendance: 3
		}}, {'HTTP_TOKEN' => @token}

		event.reload
		expect(event.event_attendances.length).to eql 1
		# expect(event.event_attendances.first.)
	end

	it "should be able to add an attendance without registering" do
		# Participant.delete_all
		# user = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		# sleep(1.5)

		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 32

		post "/api/v1/event_attendances/", {attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: '20170201-2352hwed3',
			attendance: 3
		}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['event_id']).to eql event.id
		expect(response['venue_id']).to eql venue.id
		expect(response['attendance']).to eql EventAttendance::NOT_REGISTERED_AND_ATTENDED
		expect(response['member_id']).to eql '20170201-2352hwed3'
	end

	it "should be able to mark a registration as attended" do
		# Participant.delete_all
		# user = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		# sleep(1.5)

		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 32

		event_attendance = EventAttendance.create({
			event_id: event.id,
			venue_id: venue.id,
			member_id: '20170201-2352hwfth',
			attendance: 1
		})

		expect(event_attendance.attendance).to eql EventAttendance::REGISTERED

		put "/api/v1/event_attendances/#{event_attendance.id}", {
			attendance: {attendance: 2}
		}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['attendance']).to eql EventAttendance::REGISTERED_AND_ATTENDED
		expect(response['member_id']).to eql '20170201-2352hwfth'
	end

	it "should be able to edit an event attendance record" do
		# Participant.delete_all
		# user = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		# sleep(1.5)

		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue1 = Venue.create(name: "Yogam")
		venue2 = Venue.create(name: "MGM")

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue1.id, user_id: 32}}, {'HTTP_TOKEN' => @token}
		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue2.id, user_id: 33}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[1].venue.name).to eql "MGM"

		event_attendance = EventAttendance.create({
			event_id: event.id,
			venue_id: venue1.id,
			member_id: '20170201-2352hwed11',
			attendance: 1
		})

		expect(event_attendance.attendance).to eql EventAttendance::REGISTERED
		expect(event_attendance.venue_id).to eql venue1.id

		put "/api/v1/event_attendances/#{event_attendance.id}", {attendance: {venue_id: venue2.id}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['venue_id']).to eql venue2.id
	end

	it "should be able to remove an event attendance record" do
		# Participant.delete_all
		# user = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		# sleep(1.5)

		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue1 = Venue.create(name: "Yogam")
		venue2 = Venue.create(name: "MGM")

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue1.id, user_id: 32}}, {'HTTP_TOKEN' => @token}
		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue2.id, user_id: 33}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[1].venue.name).to eql "MGM"

		event_attendance = EventAttendance.create({
			event_id: event.id,
			venue_id: venue1.id,
			member_id: '20170201-2352hweddsgr',
			attendance: 1
		})

		expect(event_attendance.attendance).to eql EventAttendance::REGISTERED
		expect(event_attendance.venue_id).to eql venue1.id

		delete "/api/v1/event_attendances/#{event_attendance.id}", nil, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)
		puts response
		expect(EventAttendance.find(id: event_attendance.id)).to eql nil
		expect(response['event_attendances'].length).to eql 0
	end

end
