require 'spec_helper'

describe 'Event Attendance' do

	it "should be able to create event registration" do
		Participant.delete_all
		user = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)

		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")

		post "/api/v1/event/#{event.id}/venue", venue: {venue_id: venue.id, user_id: 32}

		expect(Event.find(id: event.id).event_venue[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venue[0].user_id).to eql 32

		post "/api/v1/event_attendance/", attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: user['member_id'],
			attendance: 1
		}

		response = JSON.parse(last_response.body)

		expect(response['event_id']).to eql event.id
		expect(response['venue_id']).to eql venue.id
		expect(response['attendance']).to eql EventAttendance::REGISTERED
		expect(response['member_id']).to eql user['member_id']
	end

	it "should be able to add an attendance without registering" do
		Participant.delete_all
		user = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)

		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")

		post "/api/v1/event/#{event.id}/venue", venue: {venue_id: venue.id, user_id: 32}

		expect(Event.find(id: event.id).event_venue[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venue[0].user_id).to eql 32

		post "/api/v1/event_attendance/", attendance: {
			event_id: event.id,
			venue_id: venue.id,
			member_id: user['member_id'],
			attendance: 3
		}

		response = JSON.parse(last_response.body)

		expect(response['event_id']).to eql event.id
		expect(response['venue_id']).to eql venue.id
		expect(response['attendance']).to eql EventAttendance::NOT_REGISTERED_AND_ATTENDED
		expect(response['member_id']).to eql user['member_id']
	end

	it "should be able to mark a registration as attended" do
		Participant.delete_all
		user = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)

		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")

		post "/api/v1/event/#{event.id}/venue", venue: {venue_id: venue.id, user_id: 32}

		expect(Event.find(id: event.id).event_venue[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venue[0].user_id).to eql 32

		event_attendance = EventAttendance.create({
			event_id: event.id,
			venue_id: venue.id,
			member_id: user['member_id'],
			attendance: 1
		})

		expect(event_attendance.attendance).to eql EventAttendance::REGISTERED

		put "/api/v1/event_attendance/#{event_attendance.id}", attendance: {attendance: 2}

		response = JSON.parse(last_response.body)

		expect(response['attendance']).to eql EventAttendance::REGISTERED_AND_ATTENDED
		expect(response['member_id']).to eql user['member_id']
	end

	it "should be able to edit an event attendance record" do
		Participant.delete_all
		user = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)

		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue1 = Venue.create(name: "Yogam")
		venue2 = Venue.create(name: "MGM")

		post "/api/v1/event/#{event.id}/venue", venue: {venue_id: venue1.id, user_id: 32}
		post "/api/v1/event/#{event.id}/venue", venue: {venue_id: venue2.id, user_id: 33}

		expect(Event.find(id: event.id).event_venue[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venue[1].venue.name).to eql "MGM"

		event_attendance = EventAttendance.create({
			event_id: event.id,
			venue_id: venue1.id,
			member_id: user['member_id'],
			attendance: 1
		})

		expect(event_attendance.attendance).to eql EventAttendance::REGISTERED
		expect(event_attendance.venue_id).to eql venue1.id

		put "/api/v1/event_attendance/#{event_attendance.id}", attendance: {venue_id: venue2.id}

		response = JSON.parse(last_response.body)

		expect(response['venue_id']).to eql venue2.id
	end

	it "should be able to remove an event attendance record" do
		Participant.delete_all
		user = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		sleep(1.5)

		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue1 = Venue.create(name: "Yogam")
		venue2 = Venue.create(name: "MGM")

		post "/api/v1/event/#{event.id}/venue", venue: {venue_id: venue1.id, user_id: 32}
		post "/api/v1/event/#{event.id}/venue", venue: {venue_id: venue2.id, user_id: 33}

		expect(Event.find(id: event.id).event_venue[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venue[1].venue.name).to eql "MGM"

		event_attendance = EventAttendance.create({
			event_id: event.id,
			venue_id: venue1.id,
			member_id: user['member_id'],
			attendance: 1
		})

		expect(event_attendance.attendance).to eql EventAttendance::REGISTERED
		expect(event_attendance.venue_id).to eql venue1.id

		delete "/api/v1/event_attendance/#{event_attendance.id}"

		response = JSON.parse(last_response.body)

		expect(EventAttendance.find(id: event_attendance.id)).to eql nil
	end

end
