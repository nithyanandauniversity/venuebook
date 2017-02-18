require 'spec_helper'

describe 'Participant' do

	it "should be able to search participant by name" do
		Participant.delete_all
		sleep(1.5)

		user1 = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})
		user2 = Participant.create({participant: {first_name: "Senthuran", last_name: "Ponnampalam", email: "psenthu@gmail.com", gender: "Male"}})

		get "/api/v1/participants", search: {
			page: 1,
			limit: 10,
			keyword: 'sara'
		}

		response = JSON.parse(last_response.body)

		expect(response.length).to eql 1
		expect(response[0]['first_name']).to eql "Saravana"
	end

	it "should be able to get participant by id" do
		user1 = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		get "/api/v1/participants/#{user1['id']}"

		response = JSON.parse(last_response.body)

		expect(response['id']).to eql user1['id']
		expect(response['first_name']).to eql "Saravana"
	end

	it "should be able to search participant by email address" do
		Participant.delete_all
		sleep(1.5)

		user1 = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})
		user2 = Participant.create({participant: {first_name: "Senthuran", last_name: "Ponnampalam", email: "psenthu@gmail.com", gender: "Male"}})

		get "/api/v1/participants", search: {
			page: 1,
			limit: 10,
			keyword: 'psenthu'
		}

		response = JSON.parse(last_response.body)

		expect(response.length).to eql 1
		expect(response[0]['email']).to eql "psenthu@gmail.com"
	end

	it "should be able to create participant" do
		post '/api/v1/participants',
			participant: {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"},
			addresses: [
				{street: "some road", city: "City", country: "SG"},
				{street: "another one", city: "SG", country: "SG"}
			 ],
			 contacts: [
				{contact_type: "Home", value: "3342453", default: false},
				{contact_type: "Mobile", value: "454625363", default: true}
			 ]

		response = JSON.parse(last_response.body)

		participant = Participant.get(response['id'])

		expect(response['first_name']).to eql "Saravana"
		expect(response['last_name']).to eql "Balaraj"
		expect(response['gender']).to eql "Male"
		expect(response['member_id']).not_to eql nil
		expect(response['member_id'].split('-')[0]).to eql Time.parse(response['created_at']).strftime('%Y%m%d')

		expect(participant['addresses'].length).to eql 2
		expect(participant['contacts'].length).to eql 2

		expect(participant['contacts'][1]['id']).to eql participant['default_contact']
	end

	it "should be able to delete contact number for participant" do
		post '/api/v1/participants',
			participant: {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"},
			addresses: [
				{street: "some road", city: "City", country: "SG"},
				{street: "another one", city: "SG", country: "SG"}
			 ],
			 contacts: [
				{contact_type: "Home", value: "3342453"},
				{contact_type: "Mobile", value: "454625363", default: true}
			 ]

		response = JSON.parse(last_response.body)

		participant    = Participant.get(response['id'])
		participant_id = participant['id']

		expect(participant['addresses'].length).to eql 2
		expect(participant['contacts'].length).to eql 2

		contact_id = participant['contacts'][1]['id']

		delete "/api/v1/participants/#{participant_id}/contact/#{contact_id}"

		new_participant = Participant.get(response['id'])

		expect(new_participant['addresses'].length).to eql 2
		expect(new_participant['contacts'].length).to eql 1

		address_id = participant['addresses'][1]['id']

		delete "/api/v1/participants/#{participant_id}/address/#{address_id}"

		new_participant = Participant.get(response['id'])

		expect(new_participant['addresses'].length).to eql 1
		expect(new_participant['contacts'].length).to eql 1

	end

	it "should be able to edit participant" do
		participant = Participant.create({participant: {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"}})

		put "api/v1/participants/#{participant['id']}", participant: {last_name:"B"}

		response = JSON.parse(last_response.body)

		expect(response['first_name']).to eql "Saravana"
		expect(response['last_name']).to eql "B"
		expect(response['gender']).to eql "Male"
	end

	it "should be able to delete participant" do
		participant = Participant.create({participant: {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"}})

		delete "api/v1/participants/#{participant['id']}"

		expect(last_response.status).to eql 200
	end

end
