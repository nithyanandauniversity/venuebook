require 'spec_helper'

describe 'Participant' do

	before(:all) do
		User.dataset.all { |u| u.destroy }
		user = User.create(first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", password: "123123", role: 1)

		post "/api/v1/sessions/login", {auth: {
			email: "sgsaravana@gmail.com",
			password: "123123"
		}}

		response = JSON.parse(last_response.body)
		@token   = response['token']
	end

	it "should be able to search participant by name" do
		Participant.delete_all
		sleep(1.5)

		user1 = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})
		user2 = Participant.create({participant: {first_name: "Senthuran", last_name: "Ponnampalam", email: "psenthu@gmail.com", gender: "Male"}})

		get "/api/v1/participants", {search: {
			page: 1,
			limit: 10,
			keyword: 'Senthuran'
		}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)[0]['participants']

		expect(response.length).to eql 1
		expect(response[0]['first_name']).to eql "Senthuran"
	end

	it "should be able to search participant by email address" do
		Participant.delete_all
		sleep(1.5)

		user1 = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male", center_code: "122"}})
		user2 = Participant.create({participant: {first_name: "Senthuran", last_name: "Ponnampalam", email: "psenthu@gmail.com", gender: "Male", center_code: "122"}})
		user3 = Participant.create({participant: {first_name: "Dinesh", last_name: "Gupta", email: "sri.sadhana@innerawakening.org", other_names: "Sri Nithya Sadhanananda", gender: "Male", center_code: "123"}})
		user4 = Participant.create({participant: {first_name: "Kamleshwari", last_name: "V", email: "leshlesh76@gmail.com", other_names: "Ma Nithya Nishpapananda", gender: "Female", center_code: "123"}})

		get "/api/v1/participants", {search: {
			page: 1,
			limit: 10,
			keyword: 'psenthu'
		}}, {'HTTP_TOKEN' => @token}

		response1 = JSON.parse(last_response.body)[0]['participants']

		expect(response1.length).to eql 1
		expect(response1[0]['email']).to eql "psenthu@gmail.com"

		get "/api/v1/participants", {search: {
			page: 1,
			limit: 10,
			keyword: 'Kaml'
		}}, {'HTTP_TOKEN' => @token}

		response2 = JSON.parse(last_response.body)[0]['participants']

		expect(response2.length).to eql 1
		expect(response2[0]['email']).to eql "leshlesh76@gmail.com"

		center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore", code: "123")
		de1    = User.create(first_name: "Data entry1", email: "dataentry1@gmail.com", password: "123123", role: 5, center_id: center.id)

		post "/api/v1/sessions/login", {auth: {
			email: "dataentry1@gmail.com",
			password: "123123"
		}}

		token = JSON.parse(last_response.body)['token']

		get "/api/v1/participants", {search: {
			page: 1,
			limit: 10,
			keyword: "gmail"
		}}, {'HTTP_TOKEN' => token}

		response3 = JSON.parse(last_response.body)[0]['participants']

		expect(response3.length).to eql 1
		expect(response3[0]['first_name']).to eql "Kamleshwari"
	end

	it "should be able to get participant by member_id" do
		user1 = Participant.create({participant: {first_name: "Saravana", last_name: "Balaraj", email: "sgsaravana@gmail.com", gender: "Male"}})

		get "/api/v1/participants/#{user1['member_id']}", nil, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['member_id']).to eql user1['member_id']
		expect(response['first_name']).to eql "Saravana"
	end

	it "should be able to create participant" do
		post '/api/v1/participants',
			{
				participant: {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"},
				addresses: [
					{street: "some road", city: "City", country: "SG"},
					{street: "another one", city: "SG", country: "SG"}
				 ],
				 contacts: [
					{contact_type: "Home", value: "3342453", is_default: false},
					{contact_type: "Mobile", value: "454625363", is_default: true}
				 ]
			}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		participant = Participant.get(response['member_id'])

		expect(response['first_name']).to eql "Saravana"
		expect(response['last_name']).to eql "Balaraj"
		expect(response['gender']).to eql "Male"
		expect(response['member_id']).not_to eql nil
		expect(response['member_id'].split('-')[0]).to eql Time.parse(response['created_at']).strftime('%Y%m%d')

		expect(participant['addresses'].length).to eql 2
		expect(participant['contacts'].length).to eql 2

		expect(participant['contacts'][1]['id']).to eql participant['default_contact']
	end

	it "should not allow data entry user to create participant" do
		center = Center.create(name: "Yogam", state: "Singapore", country: "Singapore", code: "123")
		de1    = User.create(first_name: "Data entry1", email: "dataentry1@gmail.com", password: "123123", role: 5, center_id: center.id)

		post "/api/v1/sessions/login", {auth: {
			email: "dataentry1@gmail.com",
			password: "123123"
		}}

		token = JSON.parse(last_response.body)['token']

		post '/api/v1/participants',
			{
				participant: {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"},
				addresses: [
					{street: "some road", city: "City", country: "SG"},
					{street: "another one", city: "SG", country: "SG"}
				 ],
				 contacts: [
					{contact_type: "Home", value: "3342453", is_default: false},
					{contact_type: "Mobile", value: "454625363", is_default: true}
				 ]
			}, {'HTTP_TOKEN' => token}

		response = JSON.parse(last_response.body)

		expect(response['status']).to eql 403
		expect(response['message']).to eql "Access Denied"
	end

	it "should be able to delete contact number for participant" do
		post '/api/v1/participants',
			{
				participant: {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"},
				addresses: [
					{street: "some road", city: "City", country: "SG"},
					{street: "another one", city: "SG", country: "SG"}
				 ],
				 contacts: [
					{contact_type: "Home", value: "3342453"},
					{contact_type: "Mobile", value: "454625363", is_default: true}
				 ]
			}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		participant    = Participant.get(response['member_id'])
		participant_id = participant['member_id']

		expect(participant['addresses'].length).to eql 2
		expect(participant['contacts'].length).to eql 2

		contact_id = participant['contacts'][1]['id']

		delete "/api/v1/participants/#{participant_id}/contacts/#{contact_id}", nil, {'HTTP_TOKEN' => @token}

		new_participant = Participant.get(response['member_id'])

		expect(new_participant['addresses'].length).to eql 2
		expect(new_participant['contacts'].length).to eql 1

		address_id = participant['addresses'][1]['id']

		delete "/api/v1/participants/#{participant_id}/addresses/#{address_id}", nil, {'HTTP_TOKEN' => @token}

		new_participant = Participant.get(response['member_id'])

		expect(new_participant['addresses'].length).to eql 1
		expect(new_participant['contacts'].length).to eql 1

	end

	it "should be able to edit participant" do
		participant = Participant.create({participant: {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"}})

		put "api/v1/participants/#{participant['member_id']}", {participant: {last_name:"B"}}, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['first_name']).to eql "Saravana"
		expect(response['last_name']).to eql "B"
		expect(response['gender']).to eql "Male"
	end

	it "should be able to delete participant" do
		participant = Participant.create({participant: {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"}})

		delete "api/v1/participants/#{participant['member_id']}", nil, {'HTTP_TOKEN' => @token}

		response = JSON.parse(last_response.body)

		expect(response['id']).to eql participant['id']
	end


	it "should be able to merge multiple participants to one and all its associations" do
		participant = Participant.create(participant: {first_name: "Saravana", last_name: "B", email: "sgsaravana@gmail.com", gender: "Male"})

		puts participant
		# response = JSON.parse(last_response.body)

		# expect(response['id']).to eql participant['id']
	end

end
