require 'spec_helper'

describe "Events" do
	
	it "should be able to CRUD events" do
		venue = Venue.create(name: "Yogam")
		post '/api/v1/event', event: {venue:venue[:id], start_date: Date.today, end_date: Date.tomorrow}

		res = JSON.parse(last_response.body)
		expect(Event.find(id:res["id"]).venue[:name]).to eql "Yogam"
	end

	it "should be able to edit events" do
		venue = Venue.create(name: "Yogam")
		post "/api/v1/event", event: {venue:venue[:id], start_date: Date.today, end_date: Date.tomorrow}

		res = JSON.parse(last_response.body)
		put "/api/v1/event/#{res['id']}", event: {start_date: Date.tomorrow}

		response = JSON.parse(last_response.body)
		expect(Event.find(id:response['id']).start_date).to eql Date.tomorrow
	end

	it "should be able to delete events" do
		venue = Venue.create(name: "Yogam")
		post '/api/v1/event', event: {venue:venue[:id], start_date: Date.today, end_date: Date.tomorrow}

		res = JSON.parse(last_response.body)

		expect(Event.find(id: res['id']).venue[:name]).to eql "Yogam"

		delete "/api/v1/event/#{res['id']}"

		expect(Event.find(id: res['id'])).to eql nil
	end

end
	  
