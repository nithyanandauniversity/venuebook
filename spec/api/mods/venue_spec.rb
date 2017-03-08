require 'spec_helper'

describe 'Venue API' do

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

	it "should create venue" do
		post '/api/v1/venues', {venue: {
			name: "Yogam Center 1",
			center_id:1,
			capacity: 56
		}}, {'HTTP_TOKEN' => @token}

		resp = JSON.parse(last_response.body)

		expect(resp["name"]).to eql "Yogam Center 1"

		expect(Venue.last.name).to eql resp["name"]
	end

	it "should be able to create venue and address" do
		post '/api/v1/venues', {
			venue: {
				name: "Yogam Center 1",
				center_id:1,
				capacity: 56
			},
			address: {
				street:"11 Street",
				city:"Singapore",
				country: "Singapore"
			}
		}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)
		venue    = Venue.find(id: response['id'])

		expect(venue.name).to eql "Yogam Center 1"
		expect(venue.address).not_to eql nil
	end

	it "should list all venue for center" do
		Venue.dataset.all { |v| v.destroy }
		center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
      	Venue.create(name: "Yogam Center", center_id: center.id)
      	Venue.create(name: "Yogam Center1", center_id: 23)
      	Venue.create(name: "Yogam Center2", center_id: 65)
      	Venue.create(name: "Yogam Center3", center_id: center.id)

      	ca1    = User.create(first_name: "Center admin1", email: "centeradmin1@gmail.com", password: "123123", role: 3, center_id: center.id)

		post "/api/v1/sessions/login", {auth: {
			email: "centeradmin1@gmail.com",
			password: "123123"
		}}

		token = JSON.parse(last_response.body)['token']

      	get "/api/v1/venues/", {center_id: center.id}, {'HTTP_TOKEN' => token}

      	response = JSON.parse(last_response.body)[0]['venues']

      	expect(response.length).to eql 2
	end

	it "should be able to get venue by id" do
		center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
      	venue  = Venue.create(name: "Yogam Center", center_id: center.id)

      	get "/api/v1/venues/#{venue.id}", nil, {'HTTP_TOKEN' => @token}

      	response = JSON.parse(last_response.body)

      	expect(response['venue']['id']).to eql venue.id
	end

	it "should be able to add address" do

      center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
      venue  = Venue.create(name: "Yogam Center", center_id: center.id)

      post "/api/v1/venues/#{venue.id}/address", {address: {street:"11 Street", city:"Singapore", country: "Singapore"}}, {'HTTP_TOKEN' => @token}

      resp = JSON.parse(last_response.body)

      expect(resp["street"]).to eql "11 Street"

      expect(Address.find(id:resp["id"]).venue[:name]).to eql "Yogam Center"
   end

	it "should be assigned to a center" do
		center = Center.create(name: "Yogam", state: "Singapore")

		post '/api/v1/venues', {venue: {
			name: "Yogam Center 1",
			center_id:center.id,
			capacity: 56
		}}, {'HTTP_TOKEN' => @token}

		resp = JSON.parse(last_response.body)

		venue = Venue.find({id: resp['id']})

		expect(venue.center.id).to eql center.id
	end

	it "should be able to edit venue" do
		venue = Venue.create({name: "Yogam Center Main", center_id:1, capacity: 56})

		expect(Venue.find(id: venue.id).name).to eql "Yogam Center Main"
		expect(Venue.find(id: venue.id).capacity).to eql 56

		put "/api/v1/venues/#{venue.id}", {venue: {name: "Yogam Center Main Hall", capacity: 50}}, {'HTTP_TOKEN' => @token}

		expect(Venue.find(id: venue.id).name).to eql "Yogam Center Main Hall"
		expect(Venue.find(id: venue.id).capacity).to eql 50
	end

	it "should be able to edit venue address" do

      center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
      venue = Venue.create(name: "Yogam Center", center_id: center.id)

      post "/api/v1/venues/#{venue.id}/address", {address: {street:"11 Street", city:"Singapore", country: "Singapore"}}, {'HTTP_TOKEN' => @token}

      address = JSON.parse(last_response.body)

      put "/api/v1/venues/#{venue.id}/address/#{address['id']}", {address: {street: "411 Race course Road", city: "Singapore", country: "Singapore"}}, {'HTTP_TOKEN' => @token}

      response = JSON.parse(last_response.body)

      expect(response["street"]).to eql "411 Race course Road"
      expect(response["city"]).to eql "Singapore"

      expect(Address.find(id:response["id"]).venue[:name]).to eql "Yogam Center"
   end

	it "should be able to delete venue" do
		venue = Venue.create({name: "Yogam Center Main", center_id:1, capacity: 56})

		expect(Venue.find(id: venue.id).name).to eql "Yogam Center Main"

		delete "/api/v1/venues/#{venue.id}", nil, {'HTTP_TOKEN' => @token}

		expect(Venue.find(id: venue.id)).to eql nil
	end

	it "should be able to delete venue address" do
      center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore")
      venue = Venue.create(name: "Yogam Center", center_id: center.id)

      post "/api/v1/venues/#{venue.id}/address", {address: {street:"11 Street", city:"Singapore", country: "Singapore"}}, {'HTTP_TOKEN' => @token}

      address = JSON.parse(last_response.body)
      expect(Venue.find(id: venue.id).addresses.length).to eql 1

      delete "/api/v1/venues/#{venue.id}/address/#{address['id']}", nil, {'HTTP_TOKEN' => @token}

      expect(Venue.find(id: venue.id).addresses.length).to eql 0
   end

end
