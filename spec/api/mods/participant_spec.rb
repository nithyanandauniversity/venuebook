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
		post '/api/v1/participants', participant: {first_name:"Saravana", last_name:"Balaraj", email:"sgsaravana@gmail.com", gender:"Male"}

		response = JSON.parse(last_response.body)

		expect(response['first_name']).to eql "Saravana"
		expect(response['last_name']).to eql "Balaraj"
		expect(response['gender']).to eql "Male"
		expect(response['member_id']).not_to eql nil
		expect(response['member_id'].split('-')[0]).to eql Time.parse(response['created_at']).strftime('%Y%m%d')
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
