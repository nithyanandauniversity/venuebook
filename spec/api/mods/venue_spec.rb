require 'spec_helper'

describe 'Venue API' do
	it "should create venue" do
		post '/api/v1/venue', {name: "Yogam Center 1", center:1, country: 'Singapore', capacity: 56}

		resp = last_response.body

		resp= JSON.parse(resp)

		expect(resp["name"]).to eql "Yogam Center 1"

		expect(Venue.last.name).to eql resp["name"]
	end

	it "should be able to edit venue" do
		venue = Venue.create({name: "Yogam Center Main", center:1, country: "Singapore", capacity: 56})

		expect(Venue.find(id: venue.id).name).to eql "Yogam Center Main"
		expect(Venue.find(id: venue.id).capacity).to eql 56

		put "/api/v1/venue/#{venue.id}", venue: {name: "Yogam Center Main Hall", capacity: 50}

		expect(Venue.find(id: venue.id).name).to eql "Yogam Center Main Hall"
		expect(Venue.find(id: venue.id).capacity).to eql 50
	end

	it "should be able to delete venue" do
		venue = Venue.create({name: "Yogam Center Main", center:1, country: "Singapore", capacity: 56})

		expect(Venue.find(id: venue.id).name).to eql "Yogam Center Main"

		delete "/api/v1/venue/#{venue.id}"

		expect(Venue.find(id: venue.id)).to eql nil
	end

end
