require 'spec_helper'

describe "Events" do
	
	it "should be able to CRUD events" do
		post '/api/v1/event', event: {start_date: Date.today, end_date: Date.tomorrow}
		
		res = JSON.parse(last_response.body)

		expect(Event.find(id:res["id"]).start_date).to eql Date.today
		expect(Event.find(id:res["id"]).end_date).to eql Date.tomorrow
	end

	it "should be able to add venue to events" do
		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")
		post "/api/v1/event/#{event.id}/venue", venue: {venue_id: venue.id, user_id: 32}

		expect(Event.find(id: event.id).event_venue[0].venue.name).to eql "Yogam"
	end

	it "should be able to edit venue to events" do
		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")

		post "/api/v1/event/#{event.id}/venue", venue: {venue_id: venue.id, user_id: 32}

		expect(Event.find(id: event.id).event_venue[0].venue.name).to eql "Yogam"
		expect(Event.find(id: event.id).event_venue[0].user_id).to eql 32

		venue_id = Event.find(id: event.id).event_venue[0].id

		put "/api/v1/event/#{event.id}/venue/#{venue_id}", venue: {user_id: 34}

		expect(Event.find(id: event.id).event_venue[0].user_id).to eql 34
		expect(Event.find(id: event.id).event_venue[0].event_id).to eql event.id
		expect(Event.find(id: event.id).event_venue[0].venue_id).to eql venue.id
	end

	it "should be able to remove venue from events" do
		event = Event.create(start_date: Date.today, end_date: Date.tomorrow)
		venue = Venue.create(name: "Yogam")

		post "/api/v1/event/#{event.id}/venue", venue: {venue_id: venue.id, user_id: 32}

		expect(Event.find(id: event.id).event_venue.length).to eql 1

		delete "api/v1/event/#{event.id}/venue/#{venue.id}"
		
		expect(Event.find(id: event.id).event_venue.length).to eql 0
	end

	it "should be able to edit events" do
		post '/api/v1/event', event: {start_date: Date.today, end_date: Date.tomorrow}

		res = JSON.parse(last_response.body)
		put "/api/v1/event/#{res['id']}", event: {start_date: Date.tomorrow}

		response = JSON.parse(last_response.body)
		expect(Event.find(id:response['id']).start_date).to eql Date.tomorrow
	end

	it "should be able to delete events" do
		venue = Venue.create(name: "Yogam")
		post '/api/v1/event', event: {start_date: Date.today, end_date: Date.tomorrow}

		res = JSON.parse(last_response.body)

		expect(Event.find(id: res['id']).start_date).to eql Date.today

		delete "/api/v1/event/#{res['id']}"

		expect(Event.find(id: res['id'])).to eql nil
	end

end
	  
