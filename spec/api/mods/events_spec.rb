require 'spec_helper'

describe "Events" do

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

	it "should be able to CRUD events" do
		post '/api/v1/events', {event: {start_date: Date.today, end_date: Date.tomorrow}}, {'HTTP_TOKEN' => @token}

		res   = JSON.parse(last_response.body)
		event = Event.find(id: res['id'])

		expect(event.start_date).to eql Date.today
		expect(event.end_date).to eql Date.tomorrow
		expect(event.uuid).not_to eql nil
	end

	it "should be able to get upcoming events" do
		Event.dataset.all { |e| e.destroy }
		Event.create(start_date: Date.today, end_date: Date.tomorrow)
		Event.create(start_date: Date.tomorrow, end_date: Date.tomorrow + 1.day)
		Event.create(start_date: Date.today - 4.day, end_date: Date.today - 3.day)

		expect(Event.count).to eql 3

		get "/api/v1/events", {upcoming: true}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)[0]['events']

		expect(response.length).to eql 2
	end

	it "should be able to get past events" do
		Event.dataset.all { |e| e.destroy }
		Event.create(start_date: Date.today, end_date: Date.tomorrow)
		Event.create(start_date: Date.tomorrow, end_date: Date.tomorrow + 1.day)
		Event.create(start_date: Date.today - 4.day, end_date: Date.today - 3.day)
		Event.create(start_date: Date.today - 6.day, end_date: Date.today - 5.day)

		expect(Event.count).to eql 4

		get "/api/v1/events", {past: {
			page: 1,
			limit: 10
		}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)[0]['events']

		expect(response.length).to eql 2
	end

	it "should be able to get event by id" do
		center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
		ca1    = User.create(first_name: "Center admin1", email: "centeradmin1@gmail.com", password: "123123", role: 3, center_id: center.id)

		post "/api/v1/sessions/login", {auth: {
			email: "centeradmin1@gmail.com",
			password: "123123"
		}}

		token = JSON.parse(last_response.body)['token']

		venue1 = Venue.create(name: "Yogam")
		venue2 = Venue.create(name: "Yogam2")

		post '/api/v1/events', {
			event: {start_date: Date.today, end_date: Date.tomorrow, center_id: center.id},
			venues: [
				{venue_id: venue1.id, user_id: 33},
				{venue_id: venue2.id, user_id: 34},
			]
		}, {'HTTP_TOKEN' => token}

		res   = JSON.parse(last_response.body)
		event = Event.find(id: res['id'])

		get "/api/v1/events/#{event.id}", nil, {'HTTP_TOKEN' => token}

		response = JSON.parse(last_response.body)

		expect(response['event']['id']).to eql event.id
		expect(response['event_venues'].length).to eql 2
	end

	it "should be able to find past events" do
	end

	it "should be able to create event with multiple venues" do
		post '/api/v1/events', {
			event: {start_date: Date.today, end_date: Date.tomorrow},
			venues: [
				{venue_id: 12, user_id: 33},
				{venue_id: 16, user_id: 34},
			]
		}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		event = Event.find(id: response['id'])

		expect(event.event_venues.length).to eql 2
	end

	it "should be able to add venue to events" do
		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
	end

	it "should be able to edit venue to events" do
		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 32

		venue_id = Event.find(id: event.id).event_venues[0].id

		put "/api/v1/events/#{event.id}/venue/#{venue_id}", {venue: {user_id: 34}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues[0].user_id).to eql 34
		expect(Event.find(id: event.id).event_venues[0].event_id).to eql event.id
		expect(Event.find(id: event.id).event_venues[0].venue_id).to eql venue.id
	end

	it "should be able to remove venue from events" do
		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")

		post "/api/v1/events/#{event.id}/venue", {venue: {venue_id: venue.id, user_id: 32}}, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues.length).to eql 1

		delete "api/v1/events/#{event.id}/venue/#{venue.id}", nil, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: event.id).event_venues.length).to eql 0
	end

	it "should be able to edit events" do
		post '/api/v1/events', {event: {start_date: Date.today, end_date: Date.tomorrow}}, {'HTTP_TOKEN' => @token}

		res = JSON.parse(last_response.body)
		put "/api/v1/events/#{res['id']}", {event: {start_date: Date.tomorrow}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)
		expect(Event.find(id:response['id']).start_date).to eql Date.tomorrow
	end

	it "should be able to delete events" do
		venue = Venue.create(name: "Yogam")
		post '/api/v1/events', {event: {start_date: Date.today, end_date: Date.tomorrow}}, {'HTTP_TOKEN' => @token}

		res = JSON.parse(last_response.body)

		expect(Event.find(id: res['id']).start_date).to eql Date.today

		delete "/api/v1/events/#{res['id']}", nil, {'HTTP_TOKEN' => @token}

		expect(Event.find(id: res['id'])).to eql nil
	end

end

